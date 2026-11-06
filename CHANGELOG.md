# Changelog

All notable changes to the MWPA app are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] (build 15) – 2026-11-06

All changes since 1.0.12. Version 1.1.0 (build 14) was only an internal
intermediate version and was not released; its changes are included here.

### Added

**Languages**
- The app is available in English (default), German and Spanish. Switch the
  language with the flag menu in the app bar (list, login, consent and
  introduction pages); the choice is saved.

**Map and tour**
- The Tour tab shows the map full screen; the tour card and the quick
  actions float on top of it.
- The route of the running tour is drawn on the map as a line.
- Zoom buttons (+/−) and a "My location" button at the right edge of the
  map. The map follows the GPS position until you move it yourself.
- Current position and number of recorded points shown in a small tab below
  the tour card.
- Map areas you have looked at are kept for offline use (up to 500 MB) and
  are no longer lost when Android clears the app cache.
- "Keep screen on" switch in the settings.
- Warning banner when the battery is at 20 % or lower during a tour and the
  phone is not charging.
- GPS status icon in the app bar (OK / searching / off) and a banner when
  GPS is switched off.
- A home-area tour continues after an app restart on the same day instead
  of starting a new tour.

**Sightings**
- The sightings tab groups the sightings by tour, with date, time, duration,
  distance travelled, number of sightings, animals and species.
- Summary dialog after "Tour End".
- Sighting cards with a status stripe, sync status icon and badges (sub
  groups, calves, photo); button for the end position directly on the card.
- Edit Sighting shows which required fields are still empty (summary card
  at the top and a hint under each field). Saving is never blocked.
- Plausibility hints in Edit Sighting: sighting time outside the tour, end
  before begin, tour over midnight, date in the future, and begin/end
  position more than 1 km away from the recorded route.
- Number of sightings shown as a badge on the sightings tab.

**Sync**
- Automatic background sync: on app start, when the network comes back and
  every 15 minutes (when logged in and something is open, or the data is
  older than 6 hours). Failed syncs are retried after 1, 5 and 15 minutes.
- Status line on the sightings tab: time of the last sync, number of open
  entries, errors with details and a sync button.
- Pull down the sightings list to sync.
- Clear error messages for "server unreachable", "connection timeout",
  "please sign in again" and a refused login, instead of "Internal Error".

**Login**
- Quick Connect: sign in by scanning a single-use QR code from the MWPA web
  portal instead of typing email and password.

**Help and information**
- Help page (menu → Help) explaining the colors and symbols of the list,
  tour and home area, sync and offline use, GPS/battery/screen and the
  quick entry.
- Short three-page introduction on the first start; it can be skipped and
  opened again from the help page.
- About page (menu → About): app version, server and user, supported API
  versions, local sighting and sync counts, project links, map data credit,
  contributors, imprint and privacy policy, open source licenses.
- App log: "Share app log" on the About page sends a log of app events and
  errors (no passwords) for support.

**Appearance**
- New Material 3 design with dark mode (moon icon in the app bar).
- Branded launch screen and adaptive launcher icon (incl. themed icon).
- Centered app title with the whale tail icon.

### Changed
- Menu item "Set default Tour" is now called "Settings".
- Add Sighting / Add Tortoise are two large tiles on the Tour tab;
  "Tour End" has its own row below when enabled.
- Form inputs redesigned: searchable dropdowns for long lists, yes/no/unknown
  as segmented buttons, switch tiles, date picker opens on the stored date,
  inputs grouped into sections.
- The distance to the coast is entered and shown in nautical miles.
- Tags: chips with suggestions; tags from suggestions and separators are
  saved reliably, no duplicates, matching ignores upper/lower case.
- Coordinates show the hemisphere letter without a minus sign
  ("W: 122°" instead of "W: -122°").
- Deleting a sighting asks for confirmation.
- The Android back button/gesture on the edit pages asks before closing
  without saving (it previously did nothing).
- Logout also removes the default tour and the running home-area tour, and
  warns when sightings are not synced yet.
- The OpenStreetMap credit collapses into an (i) button after 5 seconds or
  on the first map gesture.
- Only new tour tracking points are uploaded during sync; a second sync is
  much faster (emulator test: 15.6 s → 2.4 s).
- Local tour tracking points are deleted 30 days after the server has
  confirmed them, so the local database no longer grows without limit.
- Fonts are bundled with the app, so text renders correctly offline.

### Fixed
- Slow "end position" confirmation on devices with many tracking points
  (database index).
- A distance to the coast typed in nautical miles was stored as meters.
- Photos could be lost before the next sync because they stayed in the
  cache folder; they are now copied into app storage.
- The location consent was reset on every start; "Back" in the permission
  dialog stored "not agreed" although the user had agreed.
- Add Tortoise crashed without a GPS fix and could create invalid tour ids
  without a tour date or start time.
- Missing required fields now take priority over "end missing" in the list
  status color.
- The map stayed on the world view instead of zooming to the first GPS fix.
- Location input crashed without a GPS fix.
- GPS tracking stopped for good after an error (e.g. location switched
  off); it now restarts by itself without asking for permission again.
- Network requests could hang without limit; they now time out after 30 s
  (photo upload 2 min).
- A rejected tracking upload is retried with the next sync instead of
  being skipped.
- Sync results could be overwritten by an open edit page; a stored server
  id or creator is never cleared by a local save.
- The login form flashed up briefly on start for logged-in users.
- Icon-only buttons were clipped; bottom content was hidden behind the
  gesture bar (edge-to-edge on Android 15).
- Buttons were hardly readable in dark mode.

### Security and privacy
- The password is stored in the encrypted secure storage instead of the
  normal app settings (moved automatically on the first start).
- The password and the map tile cache are excluded from Android Auto
  Backup. After restoring onto a new phone the app asks to sign in again.
- Release builds accept only valid server certificates (self-signed
  certificates only in debug builds).
- On Android 13 and newer the app asks for the notification permission, so
  the tracking notification is visible; tracking also works if it is denied.
- iOS: location usage descriptions added.

### Technical
- State management moved from GetX to provider/ChangeNotifier.
- Map moved to flutter_map 8 (OpenStreetMap tiles via HTTPS with the app's
  user agent, following the OSM tile policy).
- Unmaintained packages replaced or removed (get, get_storage, map,
  latlng, cached_network_image, flutter_icons_null_safety, switcher,
  textfield_tags, auto_size_text, flutter_staggered_animations,
  flutter_easyloading, google_fonts, latlong_to_osgrid, gpx, app_settings,
  connectivity, flutter_app_name, flutter_timezone).
- Dependencies updated (geolocator 14, connectivity_plus 7,
  device_info_plus 13, mobile_scanner 7, flutter_lints 6, …).
- Android toolchain: AGP 9.1, Kotlin 2.4, Gradle 9.3, Java 17 bytecode,
  target SDK 36; iOS deployment target 13.0.
- Database schema v11 → v13 (index on tour tracking, `synced` flag for
  tracking points); migration runs automatically.
- Form inputs split into one widget per input kind.
- Own logger with a rotating log file (512 KB) and capture of uncaught
  errors.
- 144 unit and widget tests; GitHub Actions CI runs analyze, tests and a
  debug APK build on pushes to `main` and on pull requests.
- Accepted server API versions are sets, so the app can work with several
  wire-compatible server versions.

### Notes for the update
- The stored dark mode choice is reset once (light mode is the default).
- The introduction is shown once after the update.
- The password is moved into the secure storage on the first start; no new
  login is needed.
- The existing map tile cache is taken over automatically.

## [1.0.12] – 2024-11-15

Last release before this changelog was started.
