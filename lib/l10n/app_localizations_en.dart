// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutAppSource => 'App source code';

  @override
  String get aboutConnection => 'Connection';

  @override
  String get aboutDevelopment => 'Software development';

  @override
  String get aboutLocalData => 'Data on this device';

  @override
  String get aboutMapData => 'Map data';

  @override
  String get aboutMwpaProject => 'MWPA project';

  @override
  String get aboutNotSynced => 'Not synced yet';

  @override
  String get aboutProject => 'Project';

  @override
  String get aboutProjectText =>
      'MWPA collects and analyses data of whale and dolphin watching. This app records sightings and tour tracks, also offline, and syncs them with an MWPA server. A project of M.E.E.R. e.V.';

  @override
  String get aboutServer => 'Server';

  @override
  String get aboutSightings => 'Sightings';

  @override
  String get aboutSupport => 'Support';

  @override
  String get aboutSupportText =>
      'If something does not work, share the app log with the MWPA team (e.g. by mail). It contains the app events and errors, but no passwords.';

  @override
  String get aboutSupportedApi => 'Supported server API';

  @override
  String get aboutUser => 'User';

  @override
  String accuracyMeters(int meters) {
    return 'Accuracy: $meters m';
  }

  @override
  String get add => 'Add';

  @override
  String get addSighting => 'Add Sighting';

  @override
  String get addSightingHint => 'Full form';

  @override
  String get addSightingTitle => 'Add Sighting';

  @override
  String get addTagHint => 'Add tag ...';

  @override
  String get addTortoise => 'Add Tortoise';

  @override
  String get addTortoiseHint => 'Quick entry';

  @override
  String get addTortoiseTitle => 'Add tortoise sighting';

  @override
  String addedSnack(String name) {
    return 'Added: $name';
  }

  @override
  String get allRequiredFilled => 'All required fields are filled in';

  @override
  String apiLoginChanged(String server, String accepted) {
    return 'The API for login has changed (server reports \'$server\', app accepts $accepted). Please update your app, the data will not be lost.';
  }

  @override
  String apiSyncChanged(String server, String accepted) {
    return 'The API for syncing has changed (server reports \'$server\', app accepts $accepted). Please update your app, the data will not be lost.';
  }

  @override
  String get appTagline => 'Mammal watching. Processing. Analysing.';

  @override
  String get atEndOfSighting => 'At the end of the sighting';

  @override
  String get back => 'Back';

  @override
  String get badgeCalves => 'Calves/newborns';

  @override
  String get badgePicture => 'Picture';

  @override
  String get badgeSubgroups => 'Subgroups';

  @override
  String batteryLowBanner(int level) {
    return 'Battery low ($level %) – connect a charger, the route recording stops when the phone switches off.';
  }

  @override
  String get camera => 'Camera';

  @override
  String get cancel => 'Cancel';

  @override
  String get choiceNo => 'No';

  @override
  String get choiceUnknown => 'Unknown';

  @override
  String get choiceYes => 'Yes';

  @override
  String get close => 'Close';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get currentTour => 'Current tour';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSightingQuestion =>
      'Delete this sighting from the device? Already synced data stays on the server.';

  @override
  String get deleteSightingTitle => 'Delete sighting';

  @override
  String get disclosureAccept => 'Ok, sure and save';

  @override
  String get disclosureHeading => 'How we use your location';

  @override
  String get disclosureReject => 'No, thanks and close';

  @override
  String get disclosureText1 =>
      'The MWPA app collects location data to auto-fill sighting data and track routes for movement activated even if the app is closed or not in use.';

  @override
  String get disclosureText2 =>
      'The app can only be used with position/location determination, otherwise the recorded data is useless. The data is only sent to the portal that is entered during login. For further questions you can contact or view the source code:';

  @override
  String get disclosureTitle => 'MWPA Disclosure';

  @override
  String get edit => 'Edit';

  @override
  String get editSightingTitle => 'Edit Sighting';

  @override
  String get error => 'Error';

  @override
  String get fieldBeginPosition => 'Position begin';

  @override
  String get fieldBeginTime => 'Sighting from';

  @override
  String get fieldCount => 'Number of animals';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldEndPosition => 'Position end';

  @override
  String get fieldTourEnd => 'End of trip';

  @override
  String get fieldTourStart => 'Start of trip';

  @override
  String fieldsStillEmpty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields still empty',
      one: '1 field still empty',
    );
    return '$_temp0';
  }

  @override
  String get gallery => 'Gallery';

  @override
  String get gpsOff => 'GPS is off: no position and no route recording.';

  @override
  String get gpsOffBanner =>
      'GPS is off - no position, the route is not recorded.';

  @override
  String get gpsOk => 'GPS is running, the route is recorded.';

  @override
  String get gpsSearching =>
      'GPS is running, but there is no current position fix (e.g. indoors).';

  @override
  String get gpsStatus => 'GPS status';

  @override
  String get groupDispersed => 'dispersed';

  @override
  String get groupLoose => 'loose';

  @override
  String get groupTight => 'tight';

  @override
  String get groupWidelyDispersed => 'widely dispersed';

  @override
  String get imageNotFound => 'Image not found';

  @override
  String get info => 'Info';

  @override
  String get internalError => 'Internal Error';

  @override
  String get labelAllowTourEnd =>
      'Allow tour end time button for all sightings';

  @override
  String get labelBeaufort => 'Wind/Sea-state (Beaufort)';

  @override
  String get labelBehaviour => 'Behaviour';

  @override
  String get labelBoat => 'Boat';

  @override
  String get labelCalves => 'Calves';

  @override
  String get labelDistanceCoast => 'Distance to nearest coast';

  @override
  String get labelEstimationNoGps => 'Estimation without GPS';

  @override
  String get labelFreqBehaviour => 'Frequent behaviours of individuals';

  @override
  String get labelGroupStructure => 'Group Structure';

  @override
  String get labelJuveniles => 'Juveniles';

  @override
  String get labelKeepScreenOn => 'Keep screen on';

  @override
  String get labelNewborns => 'Newborns';

  @override
  String get labelNote => 'Note';

  @override
  String get labelOther => 'Other';

  @override
  String get labelOtherBoats => 'Other boats present';

  @override
  String get labelOtherSpecies => 'Other Species';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelPhotosTaken => 'Photos taken';

  @override
  String get labelReaction => 'Reaction';

  @override
  String get labelRecAnimals => 'Recognizable animals';

  @override
  String get labelSightingFrom => 'Sighting duration: from';

  @override
  String get labelSkipper => 'Skipper';

  @override
  String get labelSpecies => 'Species';

  @override
  String get labelSubgroups => 'Subgroups';

  @override
  String get labelUntil => 'until';

  @override
  String get labelUrl => 'URL MWPA';

  @override
  String get labelUseHomeArea =>
      'Use Home Area auto-tracking tour start and end';

  @override
  String get labelUsername => 'Username / Email';

  @override
  String get language => 'Language';

  @override
  String get locationPermissionText =>
      'Please go to the system settings and allow the app access to the location.';

  @override
  String get locationPermissionTitle => 'Location permission required';

  @override
  String logShareFailed(String error) {
    return 'Log could not be shared: $error';
  }

  @override
  String get loginServerTimeout =>
      'The server did not respond in time. Please try again later.';

  @override
  String get loginServerUnreachable =>
      'No connection to the server. Please check the network and the MWPA URL.';

  @override
  String get loginTitle => 'MWPA Login';

  @override
  String get logout => 'Logout';

  @override
  String get logoutQuestion => 'Do you want to logout?';

  @override
  String logoutUnsynced(int count) {
    return '$count sighting(s) are not synced yet. Please sync before you logout, otherwise they are uploaded with the next login.\n\nLogout anyway?';
  }

  @override
  String get mapAttribution => 'Map attribution';

  @override
  String mapPositionPoints(String position, int count) {
    return '$position / Points: $count';
  }

  @override
  String get mapWaitForGps => 'wait for GPS ...';

  @override
  String get menu => 'Menu';

  @override
  String get myLocation => 'My Location';

  @override
  String get nauticalMilesUnit => 'nm';

  @override
  String get noGpsPositionYet => 'No GPS position available yet';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get noPosition => 'No position';

  @override
  String get noPositionLower => 'no position';

  @override
  String get noSightingsHint => 'Tap \"Add Sighting\" to record one.';

  @override
  String get noSightingsYet => 'No sightings yet';

  @override
  String get noUserInfo => 'No user information response from server!';

  @override
  String get notAMember => 'Not a Member? ';

  @override
  String get notAValidNumber => 'Not a valid number';

  @override
  String get notLoggedIn => 'not logged in';

  @override
  String get notSelected => 'not selected';

  @override
  String get notSet => 'not set';

  @override
  String get ok => 'Ok';

  @override
  String get openSettings => 'Open settings';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get positionFoundQuestion =>
      'At this time a position was found for the current tour. Should this be used as the position?';

  @override
  String get positionFoundTitle => 'Position is found';

  @override
  String get projectOfMeer => 'A project of the M.E.E.R. e.V. association.';

  @override
  String get qcIncomplete => 'Quick Connect payload is incomplete.';

  @override
  String get qcInvalidPayload =>
      'QR code is not a valid Quick Connect payload.';

  @override
  String get qcPointAtCode => 'Point at the QR code in the MWPA web portal.';

  @override
  String get qcUnsupportedVersion =>
      'Unsupported Quick Connect version. Please update the app.';

  @override
  String get quickConnect => 'Quick Connect';

  @override
  String get registerOnPortal => 'Register on your MWPA Portal!';

  @override
  String get remove => 'Remove';

  @override
  String get removeImage => 'Remove image';

  @override
  String get required => 'Required';

  @override
  String get save => 'Save';

  @override
  String get saveAnywayHint => 'You can save anyway and complete it later.';

  @override
  String get saveDefaultTour => 'Save default Tour';

  @override
  String get saveSighting => 'Save Sighting';

  @override
  String savedStillEmpty(String fields) {
    return 'Saved. Still empty: $fields';
  }

  @override
  String get sectionAnimals => 'Animals';

  @override
  String get sectionBehaviour => 'Behaviour & identification';

  @override
  String get sectionNotes => 'Further notes';

  @override
  String get sectionPicture => 'Picture';

  @override
  String get sectionSettings => 'Settings';

  @override
  String get sectionTimePosition => 'Time & position';

  @override
  String get sectionTour => 'Tour';

  @override
  String get selectEmptyList => '<empty list>';

  @override
  String get selectPlease => '<please select>';

  @override
  String selectUnknownId(String id) {
    return 'unknown by id: $id';
  }

  @override
  String get serverTimeout =>
      'The server did not respond in time. Please try again later. Your data stays on the device and is synced later.';

  @override
  String get serverUnreachable =>
      'No connection to the server. Please check the network and the server URL. Your data stays on the device and is synced later.';

  @override
  String get sessionNotStarted => 'User session is not started!';

  @override
  String get setDefaultTour => 'Set default Tour';

  @override
  String get setDefaultTourFirst =>
      'Please set the default tour with date and start time beforehand. The entry cannot be added until then.';

  @override
  String get setEndLocation => 'Set end location';

  @override
  String get setEndLocationQuestion =>
      'Do you want to set the end location/duration time for this sighting?';

  @override
  String get setEndLocationTitle => 'Set end location/duration';

  @override
  String get settings => 'Settings';

  @override
  String get shareAppLog => 'Share app log';

  @override
  String get sightingCloseQuestion =>
      'Close sighting without saving? All changes will be lost!';

  @override
  String get sightingCloseTitle => 'Sighting close';

  @override
  String get signIn => 'Sign In';

  @override
  String get speciesNotFound => 'Species not found';

  @override
  String get stateEndMissing => 'End missing';

  @override
  String get stateIncomplete => 'Incomplete';

  @override
  String get stateUnknownSpecies => 'Unknown species';

  @override
  String get stillOpenAtEnd => 'Still open - fill in at the end';

  @override
  String get switchCamera => 'Switch camera';

  @override
  String get switchToDarkTheme => 'Switch to dark theme';

  @override
  String get switchToLightTheme => 'Switch to light theme';

  @override
  String get syncAutoStopped => 'Automatic sync stopped – tap for details';

  @override
  String get syncChanged => 'Changed, waiting for sync';

  @override
  String get syncConnecting => 'Connecting ...';

  @override
  String get syncDone => 'Synced';

  @override
  String get syncFailedRetry =>
      'Sync failed, retrying automatically – tap for details';

  @override
  String syncLastDate(String date) {
    return 'Last synced $date';
  }

  @override
  String syncLastHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Synced $hours hours ago',
      one: 'Synced 1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get syncLastJustNow => 'Synced just now';

  @override
  String syncLastMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Synced $minutes minutes ago',
      one: 'Synced 1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get syncLoginRejected =>
      'The server rejected the login (password changed?). Please log out and sign in again. Your data stays on the device.';

  @override
  String get syncNotYet => 'Not synced yet';

  @override
  String syncOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open',
      one: '1 open',
    );
    return '$_temp0';
  }

  @override
  String get syncRunning => 'Syncing …';

  @override
  String get syncSignInAgain =>
      'No login data stored for the sync. Please log out and sign in again with your password.';

  @override
  String get syncStepBehaviouralStates => 'Behavioural states';

  @override
  String get syncStepEncounterCategories => 'Encounter categories';

  @override
  String get syncStepFinish => 'Finished';

  @override
  String get syncStepImages => 'Uploading photos';

  @override
  String get syncStepSightings => 'Uploading sightings';

  @override
  String get syncStepSpecies => 'Species';

  @override
  String syncStepTracking(String detail) {
    return 'Uploading tour track $detail';
  }

  @override
  String get syncStepVehicles => 'Boats and skippers';

  @override
  String get syncTitle => 'Syncing with server';

  @override
  String get syncWithServer => 'Sync with Server';

  @override
  String get tabSightings => 'Sightings';

  @override
  String get tabTour => 'Tour';

  @override
  String get toggleTorch => 'Toggle torch';

  @override
  String get tourCloseQuestion =>
      'Close tour without saving? All changes will be lost!';

  @override
  String get tourCloseTitle => 'Tour close';

  @override
  String get tourDateNotCurrent =>
      'The tour date is not current, please check!';

  @override
  String get tourDateNotSet => 'Tour: default date is not set';

  @override
  String get tourDateTitle => 'Tour date';

  @override
  String get tourEnd => 'Tour End';

  @override
  String get tourEndQuestion =>
      'Update the tour end time for all sighting entries from the current tour?';

  @override
  String tourLabel(String date, String start) {
    return 'Tour: $date - $start';
  }

  @override
  String get tourNotStartedHomeArea =>
      'The tour has not started yet (still in the home area). The entry cannot be added until then.';

  @override
  String get tourWaitingHomeArea => 'Tour: In Home-Area, wait for start';

  @override
  String get turtleGreen => 'Green sea turtle';

  @override
  String get turtleHawksbill => 'Hawksbill sea turtle';

  @override
  String get turtleLeatherback => 'Leatherback sea turtle';

  @override
  String get turtleLoggerhead => 'Loggerhead sea turtle';

  @override
  String get turtleSeaTurtle => 'Sea turtle';

  @override
  String get turtleUnknown => 'Unknown';

  @override
  String get useCurrentPosition => 'Use current position';

  @override
  String get userNeedsOrganization =>
      'Please update the user, all users need an organization.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get waitForGps => 'Please wait for the GPS signal.';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';
}
