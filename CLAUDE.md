# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter (Dart) mobile client for the [MWPA](https://github.com/M-E-E-R-e-V/mwpa) (Mammal Watching. Processing. Analysing.) backend. The app records cetacean sighting and tour-tracking data on Android — including offline — and syncs it back to a MWPA server. The Dart SDK constraint is `>=3.0.0 <4.0.0` (Dart 3, null-safe, exhaustive switches).

## Commands

```bash
flutter pub get                                   # fetch dependencies
flutter analyze                                   # lint (uses flutter_lints via analysis_options.yaml)
flutter test                                      # run all tests
flutter test test/path/to/file_test.dart          # run a single test file
flutter test --name "matches description"         # run a single test by name
flutter run                                       # run on attached device/emulator
flutter build apk                                 # build Android release APK

dart run flutter_launcher_icons                   # regenerate launcher icons (adaptive icon from assets/splash/)
dart run flutter_native_splash:create             # regenerate the native launch screen (Android 12+, older Android, iOS)
```

The `flutter_launcher_icons` run is also configured as an External Tool in Android Studio (see README). Re-run it after changing the `flutter_launcher_icons:` section in `pubspec.yaml`; likewise `flutter_native_splash` after changing its section. The artwork (white/blue whale tail on transparent) lives in `assets/splash/` and was derived from `assets/images/logo_512.png`. The app's first route is decided in `MWPAApp.initialRoute` from the preloaded `PrefController` (disclosure → list/login). The app display name and id are set directly in `android/app/src/main/AndroidManifest.xml` (`android:label`) and `android/app/build.gradle` (`applicationId`).

Fonts: Lato is bundled under `assets/fonts/` (SIL OFL) and used via `kFontFamily` / `latoStyle()` in `lib/Ui/Fonts.dart` — `google_fonts` was removed so the app renders correctly offline.

## Architecture

### Offline-first sync model

The defining trait of this app is that all data flows through a local SQLite database, and the network is treated as a periodic sync target rather than a source of truth.

- `lib/Db/DBHelper.dart` owns the SQLite schema (`sqflite`). It's a singleton initialized in `main()` before `runApp`. The schema has explicit, hand-written version migrations (`_updateTableSightingVNtoVN+1`) — current `_version` is 13. **When adding/changing columns, bump `_version` and add a new `_updateTable...` migration branch in `onUpgrade`. Do not edit historical migrations.**
- `lib/Mwpa/MwpaAPI.dart` is the HTTP client for the MWPA backend. All endpoint paths are declared as `URL_*` constants at the top of the class. Auth is cookie-based: `login()` stores the cookie, subsequent calls send it via the `cookie` header.
- `lib/Services/SyncMwpaService.dart` orchestrates the full sync (login → fetch reference data → push local sightings/tour-tracks → pull remote updates). It reads credentials from `shared_preferences` and reports progress via an `update(int, String)` callback. Tracking points carry a local `synced` flag (DB v13): `uploadTourTracking` sends only unflagged points when the server reports a tour incomplete, and falls back to a full re-upload if everything is flagged but the server still disagrees (the server dedupes by uuid). `MwpaApi` keeps one `http.Client` per instance (connection reuse) — create it per sync and `close()` it afterwards.
- **API version gate:** `lib/Constants.dart` defines the accepted version sets `versionApiMobileLogin` and `versionApiMobileSync`. `SyncMwpaService.sync()` calls `api.getInfo()` and aborts if the server reports a version outside these sets. When the backend's mobile API changes, add the new version here only if it stays wire-compatible — the gate exists to refuse syncing against an incompatible server rather than corrupting data.

### Two parallel model layers

There are deliberately two sets of models — do not collapse them:

- `lib/Models/` — **local domain models** persisted to SQLite (e.g. `Sighting`, `TourTracking`, `Vehicle`, `Species`, `TrackingAreaHome`). These mirror DB rows.
- `lib/Mwpa/Models/` — **API DTOs** for request/response shapes (e.g. `LoginResponse`, `SightingSaveResponse`, `*Response` wrappers, `DefaultReturn`, `StatusCodes`). `SyncMwpaService` is the seam that translates between the two.

### State management — provider + ChangeNotifier

The app uses the `provider` package (GetX was removed — do not reintroduce it):

- Controllers live in `lib/Controllers/` (one per domain entity: `SightingController`, `VehicleController`, `SpeciesController`, `PrefController`, `LocationController`, `ThemeController`, etc.) and extend `ChangeNotifier`. Mutating methods call `notifyListeners()`.
- All controllers are registered once in `main()` via `MultiProvider`. `PrefController` and `ThemeController` are loaded before `runApp`; the others are created lazily on first `context.read`. `LocationController` gets `PrefController`/`SightingController` via its constructor and only starts tracking when the prominent disclosure is confirmed (`initIfConfirmed`).
- In widgets: `context.read<T>()` for one-off access (State fields use `late final _x = context.read<T>()`), `ListenableBuilder` / `Consumer<T>` / `context.watch<T>()` to rebuild on changes.
- Non-widget code (models, utils, services) must not look controllers up — pass what it needs as parameters (e.g. `Sighting.toJson(..., speciesById:)`, `SyncMwpaService(speciesController)`, `UtilSighting.setCurrentEndTour(sightingController, ...)`).
- Routing uses plain `MaterialApp(routes:)` registered in `lib/main.dart` (`/Login`, `/List`, `/Edit`, `/setTour`, `/ProminentDisclosure`). Navigate with `Navigator.of(context).pushNamed(...)`; after an `await`, check `mounted` first.
- Dark mode: `ThemeController` (persisted under `Preference.DARK_MODE`); for colors use `isDarkMode(context)` from `Constants.dart`.

### Preferences vs. DB

Two distinct persistence mechanisms — pick the right one:

- `shared_preferences` (keys centralized in `lib/Settings/Preference.dart`): credentials (URL/USERNAME/PASSWORD/USERID), the active tour, the prominent-disclosure consent flag, the dark-mode flag, and other small scalar settings.
- SQLite (`DBHelper`): sightings, tour tracks, and all cached reference data (vehicles, drivers, species, encounter categories, behavioural states, tracking-area-home polygons).

### Pages and navigation flow

`lib/Pages/` — Welcome → Login → ProminentDisclosure (Android location-tracking consent gate, required for Play Store compliance) → List (main screen with sighting list + `flutter_map` map in `Pages/List/ListMap.dart`, OSM tiles configured in `UtilTileServer`) → Edit (sighting/tour editors). The prominent-disclosure step must run before any background-location capability is activated.

### Form inputs

The edit pages build their forms from `lib/Components/Inputs/` (import the barrel `Inputs.dart`): one widget per input kind — `SelectInput` (Material `DropdownMenu`; long lists get a search filter, override with `searchable:`), `MultiSelectInput`, `DateInput`, `TimeInput`, `LocationInput`, `SwitchInput`, `YesNoUnknownInput`, `TextValueInput` (`TextValueKind.textarea/decimal/digits`), `DistanceInput`, `TagInput`, `ImageInput`. Inputs use the theme's `InputDecoration` (see `lib/Ui/Themes.dart`); `InputFrame` adds the title, `InputSection` groups inputs into titled cards on the page. Each takes a `DynInputValue` (mutable holder owned by the page; the input writes its own slot — `strValue`, `timeValue`, `intValue`, `posValue`, …) plus an optional `onChange`. The pages read values back from their `…Value` fields, not from the widgets. Add a new input kind as a new widget, not as a mode of an existing one.

- `distance_coast` is stored in **meters** (app GPS value, and the backend exports it as meters). `DistanceInput` shows/accepts nautical miles and converts via `UtilDistanceCoast.metersToNmText` / `nmTextToMeters` — never store a typed nm value directly.
- Photos: `ImageInput` copies the picked file into app storage with `UtilImage.persist` (image_picker returns cache files that Android may clear before the next sync); `EditSightingPage` also persists legacy cache paths on save.

### Utilities of note

`lib/Util/` contains pure helpers — `UtilPosition`, `UtilLocation`, `UtilDistanceCoast`, `UtilTourFId` (tour foreign-ID generation), `UtilTourTracking` (when local tracking points may be deleted after sync), `UtilTileServer` (map tile config), `UtilSighting`, `UtilDate`, `UtilCheckJson`, `UtilImage`. Prefer extending these over inlining geo/date logic in widgets or controllers.