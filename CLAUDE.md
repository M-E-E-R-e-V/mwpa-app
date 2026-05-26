# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter (Dart) mobile client for the [MWPA](https://github.com/M-E-E-R-e-V/mwpa) (Mammal Watching. Processing. Analysing.) backend. The app records cetacean sighting and tour-tracking data on Android — including offline — and syncs it back to a MWPA server. The Dart SDK constraint is `>=2.17.5 <3.0.0`, so this is a Flutter 3.x / Dart 2.x project, not Dart 3.

## Commands

```bash
flutter pub get                                   # fetch dependencies
flutter analyze                                   # lint (uses flutter_lints via analysis_options.yaml)
flutter test                                      # run all tests
flutter test test/path/to/file_test.dart          # run a single test file
flutter test --name "matches description"         # run a single test by name
flutter run                                       # run on attached device/emulator
flutter build apk                                 # build Android release APK

flutter pub run flutter_launcher_icons:main       # regenerate launcher icons from assets/images/logo.png
flutter pub run flutter_app_name                  # apply the configured app display name / id
```

The `flutter_launcher_icons` and `flutter_app_name` runs are also configured as External Tools in Android Studio (see README). Re-run them after changing the relevant `flutter_icons:` / `flutter_app_name:` sections in `pubspec.yaml`.

## Architecture

### Offline-first sync model

The defining trait of this app is that all data flows through a local SQLite database, and the network is treated as a periodic sync target rather than a source of truth.

- `lib/Db/DBHelper.dart` owns the SQLite schema (`sqflite`). It's a singleton initialized in `main()` before `runApp`. The schema has explicit, hand-written version migrations (`_updateTableSightingVNtoVN+1`) — current `_version` is 11. **When adding/changing columns, bump `_version` and add a new `_updateTable...` migration branch in `onUpgrade`. Do not edit historical migrations.**
- `lib/Mwpa/MwpaAPI.dart` is the HTTP client for the MWPA backend. All endpoint paths are declared as `URL_*` constants at the top of the class. Auth is cookie-based: `login()` stores the cookie, subsequent calls send it via the `cookie` header.
- `lib/Services/SyncMwpaService.dart` orchestrates the full sync (login → fetch reference data → push local sightings/tour-tracks → pull remote updates). It reads credentials from `shared_preferences` and reports progress via an `update(int, String)` callback.
- **API version gate:** `lib/Constants.dart` defines `versionApiMobileLogin` and `versionApiMobileSync`. `SyncMwpaService.sync()` calls `api.getInfo()` and aborts if the server reports different versions. When the backend's mobile API changes, these constants must be bumped in lockstep — they exist specifically to refuse syncing against an incompatible server rather than corrupting data.

### Two parallel model layers

There are deliberately two sets of models — do not collapse them:

- `lib/Models/` — **local domain models** persisted to SQLite (e.g. `Sighting`, `TourTracking`, `Vehicle`, `Species`, `TrackingAreaHome`). These mirror DB rows.
- `lib/Mwpa/Models/` — **API DTOs** for request/response shapes (e.g. `LoginResponse`, `SightingSaveResponse`, `*Response` wrappers, `DefaultReturn`, `StatusCodes`). `SyncMwpaService` is the seam that translates between the two.

### State management — GetX

The app uses the `get` package for DI, reactive state, and navigation:

- Controllers live in `lib/Controllers/` (one per domain entity: `SightingController`, `VehicleController`, `SpeciesController`, `PrefController`, etc.) and extend `GetxController`. They're typically registered with `Get.put(...)` and accessed via `Get.find()`.
- Routing uses `GetMaterialApp` with named routes registered in `lib/main.dart` (`/Login`, `/List`, `/Edit`, `/setTour`, `/ProminentDisclosure`). Navigate with `Get.toNamed(...)`.
- `PrefController` is the in-memory cache over `shared_preferences`; it's `Get.put` at app start in `main.dart` and holds login state, the prominent-disclosure flag, and the currently-active tour preferences.

### Preferences vs. DB

Two distinct persistence mechanisms — pick the right one:

- `shared_preferences` (keys centralized in `lib/Settings/Preference.dart`): credentials (URL/USERNAME/PASSWORD/USERID), the active tour, the prominent-disclosure consent flag, and other small scalar settings.
- SQLite (`DBHelper`): sightings, tour tracks, and all cached reference data (vehicles, drivers, species, encounter categories, behavioural states, tracking-area-home polygons).

### Pages and navigation flow

`lib/Pages/` — Welcome → Login → ProminentDisclosure (Android location-tracking consent gate, required for Play Store compliance) → List (main screen with sighting list + map under `Pages/List/Map/`) → Edit (sighting/tour editors). The prominent-disclosure step must run before any background-location capability is activated.

### Utilities of note

`lib/Util/` contains pure helpers — `UtilPosition`, `UtilLocation`, `UtilDistanceCoast`, `UtilTourFId` (tour foreign-ID generation), `UtilTileServer` (map tile config), `UtilSighting`, `UtilDate`, `UtilCheckJson`. Prefer extending these over inlining geo/date logic in widgets or controllers.