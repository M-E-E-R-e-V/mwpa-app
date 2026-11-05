import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutAppSource.
  ///
  /// In en, this message translates to:
  /// **'App source code'**
  String get aboutAppSource;

  /// No description provided for @aboutConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get aboutConnection;

  /// No description provided for @aboutDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Software development'**
  String get aboutDevelopment;

  /// No description provided for @aboutLocalData.
  ///
  /// In en, this message translates to:
  /// **'Data on this device'**
  String get aboutLocalData;

  /// No description provided for @aboutMapData.
  ///
  /// In en, this message translates to:
  /// **'Map data'**
  String get aboutMapData;

  /// No description provided for @aboutMwpaProject.
  ///
  /// In en, this message translates to:
  /// **'MWPA project'**
  String get aboutMwpaProject;

  /// No description provided for @aboutNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get aboutNotSynced;

  /// No description provided for @aboutProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get aboutProject;

  /// No description provided for @aboutProjectText.
  ///
  /// In en, this message translates to:
  /// **'MWPA collects and analyses data of whale and dolphin watching. This app records sightings and tour tracks, also offline, and syncs them with an MWPA server. A project of M.E.E.R. e.V.'**
  String get aboutProjectText;

  /// No description provided for @aboutServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get aboutServer;

  /// No description provided for @aboutSightings.
  ///
  /// In en, this message translates to:
  /// **'Sightings'**
  String get aboutSightings;

  /// No description provided for @aboutSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get aboutSupport;

  /// No description provided for @aboutSupportText.
  ///
  /// In en, this message translates to:
  /// **'If something does not work, share the app log with the MWPA team (e.g. by mail). It contains the app events and errors, but no passwords.'**
  String get aboutSupportText;

  /// No description provided for @aboutSupportedApi.
  ///
  /// In en, this message translates to:
  /// **'Supported server API'**
  String get aboutSupportedApi;

  /// No description provided for @aboutUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get aboutUser;

  /// No description provided for @accuracyMeters.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {meters} m'**
  String accuracyMeters(int meters);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addSighting.
  ///
  /// In en, this message translates to:
  /// **'Add Sighting'**
  String get addSighting;

  /// No description provided for @addSightingHint.
  ///
  /// In en, this message translates to:
  /// **'Full form'**
  String get addSightingHint;

  /// No description provided for @addSightingTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Sighting'**
  String get addSightingTitle;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add tag ...'**
  String get addTagHint;

  /// No description provided for @addTortoise.
  ///
  /// In en, this message translates to:
  /// **'Add Tortoise'**
  String get addTortoise;

  /// No description provided for @addTortoiseHint.
  ///
  /// In en, this message translates to:
  /// **'Quick entry'**
  String get addTortoiseHint;

  /// No description provided for @addTortoiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add tortoise sighting'**
  String get addTortoiseTitle;

  /// No description provided for @addedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added: {name}'**
  String addedSnack(String name);

  /// No description provided for @allRequiredFilled.
  ///
  /// In en, this message translates to:
  /// **'All required fields are filled in'**
  String get allRequiredFilled;

  /// No description provided for @animalsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 animal} other{{count} animals}}'**
  String animalsCount(int count);

  /// No description provided for @apiLoginChanged.
  ///
  /// In en, this message translates to:
  /// **'The API for login has changed (server reports \'{server}\', app accepts {accepted}). Please update your app, the data will not be lost.'**
  String apiLoginChanged(String server, String accepted);

  /// No description provided for @apiSyncChanged.
  ///
  /// In en, this message translates to:
  /// **'The API for syncing has changed (server reports \'{server}\', app accepts {accepted}). Please update your app, the data will not be lost.'**
  String apiSyncChanged(String server, String accepted);

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Mammal watching. Processing. Analysing.'**
  String get appTagline;

  /// No description provided for @atEndOfSighting.
  ///
  /// In en, this message translates to:
  /// **'At the end of the sighting'**
  String get atEndOfSighting;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @badgeCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves/newborns'**
  String get badgeCalves;

  /// No description provided for @badgePicture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get badgePicture;

  /// No description provided for @badgeSubgroups.
  ///
  /// In en, this message translates to:
  /// **'Subgroups'**
  String get badgeSubgroups;

  /// No description provided for @batteryLowBanner.
  ///
  /// In en, this message translates to:
  /// **'Battery low ({level} %) – connect a charger, the route recording stops when the phone switches off.'**
  String batteryLowBanner(int level);

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @checkBeginAfterTourEnd.
  ///
  /// In en, this message translates to:
  /// **'The sighting starts after the tour end.'**
  String get checkBeginAfterTourEnd;

  /// No description provided for @checkBeginBeforeTourStart.
  ///
  /// In en, this message translates to:
  /// **'The sighting starts before the tour start.'**
  String get checkBeginBeforeTourStart;

  /// No description provided for @checkBeginFarFromTrack.
  ///
  /// In en, this message translates to:
  /// **'The start position is {distance} away from the recorded route at that time.'**
  String checkBeginFarFromTrack(String distance);

  /// No description provided for @checkDateInFuture.
  ///
  /// In en, this message translates to:
  /// **'The date is in the future.'**
  String get checkDateInFuture;

  /// No description provided for @checkEndBeforeBegin.
  ///
  /// In en, this message translates to:
  /// **'The sighting ends before it starts.'**
  String get checkEndBeforeBegin;

  /// No description provided for @checkEndFarFromTrack.
  ///
  /// In en, this message translates to:
  /// **'The end position is {distance} away from the recorded route at that time.'**
  String checkEndFarFromTrack(String distance);

  /// No description provided for @checkTitle.
  ///
  /// In en, this message translates to:
  /// **'Please check'**
  String get checkTitle;

  /// No description provided for @checkTourEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The tour ends before it starts (over midnight?).'**
  String get checkTourEndBeforeStart;

  /// No description provided for @choiceNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get choiceNo;

  /// No description provided for @choiceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get choiceUnknown;

  /// No description provided for @choiceYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get choiceYes;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @currentTour.
  ///
  /// In en, this message translates to:
  /// **'Current tour'**
  String get currentTour;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteSightingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this sighting from the device? Already synced data stays on the server.'**
  String get deleteSightingQuestion;

  /// No description provided for @deleteSightingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete sighting'**
  String get deleteSightingTitle;

  /// No description provided for @disclosureAccept.
  ///
  /// In en, this message translates to:
  /// **'Ok, sure and save'**
  String get disclosureAccept;

  /// No description provided for @disclosureHeading.
  ///
  /// In en, this message translates to:
  /// **'How we use your location'**
  String get disclosureHeading;

  /// No description provided for @disclosureReject.
  ///
  /// In en, this message translates to:
  /// **'No, thanks and close'**
  String get disclosureReject;

  /// No description provided for @disclosureText1.
  ///
  /// In en, this message translates to:
  /// **'The MWPA app collects location data to auto-fill sighting data and track routes for movement activated even if the app is closed or not in use.'**
  String get disclosureText1;

  /// No description provided for @disclosureText2.
  ///
  /// In en, this message translates to:
  /// **'The app can only be used with position/location determination, otherwise the recorded data is useless. The data is only sent to the portal that is entered during login. For further questions you can contact or view the source code:'**
  String get disclosureText2;

  /// No description provided for @disclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'MWPA Disclosure'**
  String get disclosureTitle;

  /// No description provided for @distanceNm.
  ///
  /// In en, this message translates to:
  /// **'{distance} nm'**
  String distanceNm(String distance);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editSightingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Sighting'**
  String get editSightingTitle;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @fieldBeginPosition.
  ///
  /// In en, this message translates to:
  /// **'Position begin'**
  String get fieldBeginPosition;

  /// No description provided for @fieldBeginTime.
  ///
  /// In en, this message translates to:
  /// **'Sighting from'**
  String get fieldBeginTime;

  /// No description provided for @fieldCount.
  ///
  /// In en, this message translates to:
  /// **'Number of animals'**
  String get fieldCount;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldEndPosition.
  ///
  /// In en, this message translates to:
  /// **'Position end'**
  String get fieldEndPosition;

  /// No description provided for @fieldTourEnd.
  ///
  /// In en, this message translates to:
  /// **'End of trip'**
  String get fieldTourEnd;

  /// No description provided for @fieldTourStart.
  ///
  /// In en, this message translates to:
  /// **'Start of trip'**
  String get fieldTourStart;

  /// No description provided for @fieldsStillEmpty.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 field still empty} other{{count} fields still empty}}'**
  String fieldsStillEmpty(int count);

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @gpsOff.
  ///
  /// In en, this message translates to:
  /// **'GPS is off: no position and no route recording.'**
  String get gpsOff;

  /// No description provided for @gpsOffBanner.
  ///
  /// In en, this message translates to:
  /// **'GPS is off - no position, the route is not recorded.'**
  String get gpsOffBanner;

  /// No description provided for @gpsOk.
  ///
  /// In en, this message translates to:
  /// **'GPS is running, the route is recorded.'**
  String get gpsOk;

  /// No description provided for @gpsSearching.
  ///
  /// In en, this message translates to:
  /// **'GPS is running, but there is no current position fix (e.g. indoors).'**
  String get gpsSearching;

  /// No description provided for @gpsStatus.
  ///
  /// In en, this message translates to:
  /// **'GPS status'**
  String get gpsStatus;

  /// No description provided for @groupDispersed.
  ///
  /// In en, this message translates to:
  /// **'dispersed'**
  String get groupDispersed;

  /// No description provided for @groupLoose.
  ///
  /// In en, this message translates to:
  /// **'loose'**
  String get groupLoose;

  /// No description provided for @groupTight.
  ///
  /// In en, this message translates to:
  /// **'tight'**
  String get groupTight;

  /// No description provided for @groupWidelyDispersed.
  ///
  /// In en, this message translates to:
  /// **'widely dispersed'**
  String get groupWidelyDispersed;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpBattery.
  ///
  /// In en, this message translates to:
  /// **'Below 20 % battery a warning appears during a tour – connect a charger, otherwise the recording stops when the phone switches off.'**
  String get helpBattery;

  /// No description provided for @helpCloudDone.
  ///
  /// In en, this message translates to:
  /// **'On the server.'**
  String get helpCloudDone;

  /// No description provided for @helpCloudOff.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet.'**
  String get helpCloudOff;

  /// No description provided for @helpCloudUpload.
  ///
  /// In en, this message translates to:
  /// **'Changed, will be sent with the next sync.'**
  String get helpCloudUpload;

  /// No description provided for @helpColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue: the sighting is complete.'**
  String get helpColorBlue;

  /// No description provided for @helpColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green: quick entry of a turtle.'**
  String get helpColorGreen;

  /// No description provided for @helpColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red: a required field is still empty (e.g. number of animals).'**
  String get helpColorRed;

  /// No description provided for @helpColorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow: only the end is missing (end of tour, end position) or the species is unknown in the app – usually completed later.'**
  String get helpColorYellow;

  /// No description provided for @helpColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Colors and symbols in the list'**
  String get helpColorsTitle;

  /// No description provided for @helpGpsBackground.
  ///
  /// In en, this message translates to:
  /// **'The route is also recorded when the app is in the background; the notification shows that tracking is running.'**
  String get helpGpsBackground;

  /// No description provided for @helpGpsIcon.
  ///
  /// In en, this message translates to:
  /// **'The GPS symbol at the top: green = position OK, yellow = searching, red = GPS off. With GPS off, the route is not recorded.'**
  String get helpGpsIcon;

  /// No description provided for @helpGpsTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS, battery and screen'**
  String get helpGpsTitle;

  /// No description provided for @helpMissingHints.
  ///
  /// In en, this message translates to:
  /// **'In the form, a card at the top lists the empty required fields and values that look wrong. Tap a hint to jump to the field. You can always save anyway.'**
  String get helpMissingHints;

  /// No description provided for @helpQuick.
  ///
  /// In en, this message translates to:
  /// **'\"Add Tortoise\" saves a turtle with the current position and time in two taps. \"Add Sighting\" opens the full form.'**
  String get helpQuick;

  /// No description provided for @helpQuickEnd.
  ///
  /// In en, this message translates to:
  /// **'When the animals are gone, tap the pin button on the sighting in the list to set the end position and time.'**
  String get helpQuickEnd;

  /// No description provided for @helpQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick entry'**
  String get helpQuickTitle;

  /// No description provided for @helpScreen.
  ///
  /// In en, this message translates to:
  /// **'\"Keep screen on\" in the tour settings keeps the display on while the app is open.'**
  String get helpScreen;

  /// No description provided for @helpShowIntro.
  ///
  /// In en, this message translates to:
  /// **'Show introduction again'**
  String get helpShowIntro;

  /// No description provided for @helpSyncAuto.
  ///
  /// In en, this message translates to:
  /// **'The app syncs by itself when the network is back and every 15 minutes. The line at the top of the sightings tab shows the last sync and what is still open.'**
  String get helpSyncAuto;

  /// No description provided for @helpSyncManual.
  ///
  /// In en, this message translates to:
  /// **'To sync right away: pull the list down, tap the sync button or use Menu → \"Sync with server\".'**
  String get helpSyncManual;

  /// No description provided for @helpSyncMap.
  ///
  /// In en, this message translates to:
  /// **'Map areas you have looked at are kept and also shown offline.'**
  String get helpSyncMap;

  /// No description provided for @helpSyncOffline.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored on the phone first. You can record sightings without network – nothing is lost.'**
  String get helpSyncOffline;

  /// No description provided for @helpSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync and working offline'**
  String get helpSyncTitle;

  /// No description provided for @helpTourDefault.
  ///
  /// In en, this message translates to:
  /// **'Set boat, skipper and wind once per day under Menu → \"Set default tour\". New sightings take these values.'**
  String get helpTourDefault;

  /// No description provided for @helpTourEnd.
  ///
  /// In en, this message translates to:
  /// **'Without home area, end the tour with the \"Tour End\" button – you then see a summary of the tour.'**
  String get helpTourEnd;

  /// No description provided for @helpTourHomeArea.
  ///
  /// In en, this message translates to:
  /// **'With \"home area\" switched on, the tour starts automatically when the boat leaves the harbour area and ends when it comes back.'**
  String get helpTourHomeArea;

  /// No description provided for @helpTourRoute.
  ///
  /// In en, this message translates to:
  /// **'The orange line on the map is the route recorded on this tour. The sightings tab groups the sightings by tour with duration, distance and species.'**
  String get helpTourRoute;

  /// No description provided for @helpTourTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour and home area'**
  String get helpTourTitle;

  /// No description provided for @imageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not found'**
  String get imageNotFound;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @internalError.
  ///
  /// In en, this message translates to:
  /// **'Internal Error'**
  String get internalError;

  /// No description provided for @intro1Text.
  ///
  /// In en, this message translates to:
  /// **'\"Add Sighting\" opens the full form, \"Add Tortoise\" saves a turtle in two taps. Colors in the list show what is still missing.'**
  String get intro1Text;

  /// No description provided for @intro1Title.
  ///
  /// In en, this message translates to:
  /// **'Record sightings'**
  String get intro1Title;

  /// No description provided for @intro2Text.
  ///
  /// In en, this message translates to:
  /// **'Set the default tour once a day. The app records the route on the map – with home area even starting and ending the tour by itself.'**
  String get intro2Text;

  /// No description provided for @intro2Title.
  ///
  /// In en, this message translates to:
  /// **'Tour and route'**
  String get intro2Title;

  /// No description provided for @intro3Text.
  ///
  /// In en, this message translates to:
  /// **'Everything is saved on the phone and synced automatically as soon as there is network. You find this and more under Menu → Help.'**
  String get intro3Text;

  /// No description provided for @intro3Title.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get intro3Title;

  /// No description provided for @introDone.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get introDone;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @labelAllowTourEnd.
  ///
  /// In en, this message translates to:
  /// **'Allow tour end time button for all sightings'**
  String get labelAllowTourEnd;

  /// No description provided for @labelBeaufort.
  ///
  /// In en, this message translates to:
  /// **'Wind/Sea-state (Beaufort)'**
  String get labelBeaufort;

  /// No description provided for @labelBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get labelBehaviour;

  /// No description provided for @labelBoat.
  ///
  /// In en, this message translates to:
  /// **'Boat'**
  String get labelBoat;

  /// No description provided for @labelCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get labelCalves;

  /// No description provided for @labelDistanceCoast.
  ///
  /// In en, this message translates to:
  /// **'Distance to nearest coast'**
  String get labelDistanceCoast;

  /// No description provided for @labelEstimationNoGps.
  ///
  /// In en, this message translates to:
  /// **'Estimation without GPS'**
  String get labelEstimationNoGps;

  /// No description provided for @labelFreqBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Frequent behaviours of individuals'**
  String get labelFreqBehaviour;

  /// No description provided for @labelGroupStructure.
  ///
  /// In en, this message translates to:
  /// **'Group Structure'**
  String get labelGroupStructure;

  /// No description provided for @labelJuveniles.
  ///
  /// In en, this message translates to:
  /// **'Juveniles'**
  String get labelJuveniles;

  /// No description provided for @labelKeepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get labelKeepScreenOn;

  /// No description provided for @labelNewborns.
  ///
  /// In en, this message translates to:
  /// **'Newborns'**
  String get labelNewborns;

  /// No description provided for @labelNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get labelNote;

  /// No description provided for @labelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelOther;

  /// No description provided for @labelOtherBoats.
  ///
  /// In en, this message translates to:
  /// **'Other boats present'**
  String get labelOtherBoats;

  /// No description provided for @labelOtherSpecies.
  ///
  /// In en, this message translates to:
  /// **'Other Species'**
  String get labelOtherSpecies;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @labelPhotosTaken.
  ///
  /// In en, this message translates to:
  /// **'Photos taken'**
  String get labelPhotosTaken;

  /// No description provided for @labelReaction.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get labelReaction;

  /// No description provided for @labelRecAnimals.
  ///
  /// In en, this message translates to:
  /// **'Recognizable animals'**
  String get labelRecAnimals;

  /// No description provided for @labelSightingFrom.
  ///
  /// In en, this message translates to:
  /// **'Sighting duration: from'**
  String get labelSightingFrom;

  /// No description provided for @labelSkipper.
  ///
  /// In en, this message translates to:
  /// **'Skipper'**
  String get labelSkipper;

  /// No description provided for @labelSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get labelSpecies;

  /// No description provided for @labelSubgroups.
  ///
  /// In en, this message translates to:
  /// **'Subgroups'**
  String get labelSubgroups;

  /// No description provided for @labelUntil.
  ///
  /// In en, this message translates to:
  /// **'until'**
  String get labelUntil;

  /// No description provided for @labelUrl.
  ///
  /// In en, this message translates to:
  /// **'URL MWPA'**
  String get labelUrl;

  /// No description provided for @labelUseHomeArea.
  ///
  /// In en, this message translates to:
  /// **'Use Home Area auto-tracking tour start and end'**
  String get labelUseHomeArea;

  /// No description provided for @labelUsername.
  ///
  /// In en, this message translates to:
  /// **'Username / Email'**
  String get labelUsername;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @locationPermissionText.
  ///
  /// In en, this message translates to:
  /// **'Please go to the system settings and allow the app access to the location.'**
  String get locationPermissionText;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionTitle;

  /// No description provided for @logShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Log could not be shared: {error}'**
  String logShareFailed(String error);

  /// No description provided for @loginServerTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server did not respond in time. Please try again later.'**
  String get loginServerTimeout;

  /// No description provided for @loginServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Please check the network and the MWPA URL.'**
  String get loginServerUnreachable;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'MWPA Login'**
  String get loginTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout?'**
  String get logoutQuestion;

  /// No description provided for @logoutUnsynced.
  ///
  /// In en, this message translates to:
  /// **'{count} sighting(s) are not synced yet. Please sync before you logout, otherwise they are uploaded with the next login.\n\nLogout anyway?'**
  String logoutUnsynced(int count);

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'Map attribution'**
  String get mapAttribution;

  /// No description provided for @mapPositionPoints.
  ///
  /// In en, this message translates to:
  /// **'{position} / Points: {count}'**
  String mapPositionPoints(String position, int count);

  /// No description provided for @mapWaitForGps.
  ///
  /// In en, this message translates to:
  /// **'wait for GPS ...'**
  String get mapWaitForGps;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @nauticalMilesUnit.
  ///
  /// In en, this message translates to:
  /// **'nm'**
  String get nauticalMilesUnit;

  /// No description provided for @noGpsPositionYet.
  ///
  /// In en, this message translates to:
  /// **'No GPS position available yet'**
  String get noGpsPositionYet;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @noPosition.
  ///
  /// In en, this message translates to:
  /// **'No position'**
  String get noPosition;

  /// No description provided for @noPositionLower.
  ///
  /// In en, this message translates to:
  /// **'no position'**
  String get noPositionLower;

  /// No description provided for @noSightingsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Sighting\" to record one.'**
  String get noSightingsHint;

  /// No description provided for @noSightingsYet.
  ///
  /// In en, this message translates to:
  /// **'No sightings yet'**
  String get noSightingsYet;

  /// No description provided for @noUserInfo.
  ///
  /// In en, this message translates to:
  /// **'No user information response from server!'**
  String get noUserInfo;

  /// No description provided for @notAMember.
  ///
  /// In en, this message translates to:
  /// **'Not a Member? '**
  String get notAMember;

  /// No description provided for @notAValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Not a valid number'**
  String get notAValidNumber;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'not logged in'**
  String get notLoggedIn;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'not selected'**
  String get notSelected;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'not set'**
  String get notSet;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @positionFoundQuestion.
  ///
  /// In en, this message translates to:
  /// **'At this time a position was found for the current tour. Should this be used as the position?'**
  String get positionFoundQuestion;

  /// No description provided for @positionFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Position is found'**
  String get positionFoundTitle;

  /// No description provided for @projectOfMeer.
  ///
  /// In en, this message translates to:
  /// **'A project of the M.E.E.R. e.V. association.'**
  String get projectOfMeer;

  /// No description provided for @qcIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Quick Connect payload is incomplete.'**
  String get qcIncomplete;

  /// No description provided for @qcInvalidPayload.
  ///
  /// In en, this message translates to:
  /// **'QR code is not a valid Quick Connect payload.'**
  String get qcInvalidPayload;

  /// No description provided for @qcPointAtCode.
  ///
  /// In en, this message translates to:
  /// **'Point at the QR code in the MWPA web portal.'**
  String get qcPointAtCode;

  /// No description provided for @qcUnsupportedVersion.
  ///
  /// In en, this message translates to:
  /// **'Unsupported Quick Connect version. Please update the app.'**
  String get qcUnsupportedVersion;

  /// No description provided for @quickConnect.
  ///
  /// In en, this message translates to:
  /// **'Quick Connect'**
  String get quickConnect;

  /// No description provided for @registerOnPortal.
  ///
  /// In en, this message translates to:
  /// **'Register on your MWPA Portal!'**
  String get registerOnPortal;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAnywayHint.
  ///
  /// In en, this message translates to:
  /// **'You can save anyway and complete it later.'**
  String get saveAnywayHint;

  /// No description provided for @saveDefaultTour.
  ///
  /// In en, this message translates to:
  /// **'Save default Tour'**
  String get saveDefaultTour;

  /// No description provided for @saveSighting.
  ///
  /// In en, this message translates to:
  /// **'Save Sighting'**
  String get saveSighting;

  /// No description provided for @savedStillEmpty.
  ///
  /// In en, this message translates to:
  /// **'Saved. Still empty: {fields}'**
  String savedStillEmpty(String fields);

  /// No description provided for @sectionAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get sectionAnimals;

  /// No description provided for @sectionBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Behaviour & identification'**
  String get sectionBehaviour;

  /// No description provided for @sectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Further notes'**
  String get sectionNotes;

  /// No description provided for @sectionPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get sectionPicture;

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// No description provided for @sectionTimePosition.
  ///
  /// In en, this message translates to:
  /// **'Time & position'**
  String get sectionTimePosition;

  /// No description provided for @sectionTour.
  ///
  /// In en, this message translates to:
  /// **'Tour'**
  String get sectionTour;

  /// No description provided for @selectEmptyList.
  ///
  /// In en, this message translates to:
  /// **'<empty list>'**
  String get selectEmptyList;

  /// No description provided for @selectPlease.
  ///
  /// In en, this message translates to:
  /// **'<please select>'**
  String get selectPlease;

  /// No description provided for @selectUnknownId.
  ///
  /// In en, this message translates to:
  /// **'unknown by id: {id}'**
  String selectUnknownId(String id);

  /// No description provided for @serverTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server did not respond in time. Please try again later. Your data stays on the device and is synced later.'**
  String get serverTimeout;

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Please check the network and the server URL. Your data stays on the device and is synced later.'**
  String get serverUnreachable;

  /// No description provided for @sessionNotStarted.
  ///
  /// In en, this message translates to:
  /// **'User session is not started!'**
  String get sessionNotStarted;

  /// No description provided for @setDefaultTour.
  ///
  /// In en, this message translates to:
  /// **'Set default Tour'**
  String get setDefaultTour;

  /// No description provided for @setDefaultTourFirst.
  ///
  /// In en, this message translates to:
  /// **'Please set the default tour with date and start time beforehand. The entry cannot be added until then.'**
  String get setDefaultTourFirst;

  /// No description provided for @setEndLocation.
  ///
  /// In en, this message translates to:
  /// **'Set end location'**
  String get setEndLocation;

  /// No description provided for @setEndLocationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to set the end location/duration time for this sighting?'**
  String get setEndLocationQuestion;

  /// No description provided for @setEndLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set end location/duration'**
  String get setEndLocationTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareAppLog.
  ///
  /// In en, this message translates to:
  /// **'Share app log'**
  String get shareAppLog;

  /// No description provided for @sightingCloseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Close sighting without saving? All changes will be lost!'**
  String get sightingCloseQuestion;

  /// No description provided for @sightingCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Sighting close'**
  String get sightingCloseTitle;

  /// No description provided for @sightingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sighting} other{{count} sightings}}'**
  String sightingsCount(int count);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @speciesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Species not found'**
  String get speciesNotFound;

  /// No description provided for @stateEndMissing.
  ///
  /// In en, this message translates to:
  /// **'End missing'**
  String get stateEndMissing;

  /// No description provided for @stateIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get stateIncomplete;

  /// No description provided for @stateUnknownSpecies.
  ///
  /// In en, this message translates to:
  /// **'Unknown species'**
  String get stateUnknownSpecies;

  /// No description provided for @stillOpenAtEnd.
  ///
  /// In en, this message translates to:
  /// **'Still open - fill in at the end'**
  String get stillOpenAtEnd;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @switchToDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get switchToDarkTheme;

  /// No description provided for @switchToLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get switchToLightTheme;

  /// No description provided for @syncAutoStopped.
  ///
  /// In en, this message translates to:
  /// **'Automatic sync stopped – tap for details'**
  String get syncAutoStopped;

  /// No description provided for @syncChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed, waiting for sync'**
  String get syncChanged;

  /// No description provided for @syncConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting ...'**
  String get syncConnecting;

  /// No description provided for @syncDone.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncDone;

  /// No description provided for @syncFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Sync failed, retrying automatically – tap for details'**
  String get syncFailedRetry;

  /// No description provided for @syncLastDate.
  ///
  /// In en, this message translates to:
  /// **'Last synced {date}'**
  String syncLastDate(String date);

  /// No description provided for @syncLastHours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{Synced 1 hour ago} other{Synced {hours} hours ago}}'**
  String syncLastHours(int hours);

  /// No description provided for @syncLastJustNow.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get syncLastJustNow;

  /// No description provided for @syncLastMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{Synced 1 minute ago} other{Synced {minutes} minutes ago}}'**
  String syncLastMinutes(int minutes);

  /// No description provided for @syncLoginRejected.
  ///
  /// In en, this message translates to:
  /// **'The server rejected the login (password changed?). Please log out and sign in again. Your data stays on the device.'**
  String get syncLoginRejected;

  /// No description provided for @syncNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNotYet;

  /// No description provided for @syncOpenCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 open} other{{count} open}}'**
  String syncOpenCount(int count);

  /// No description provided for @syncRunning.
  ///
  /// In en, this message translates to:
  /// **'Syncing …'**
  String get syncRunning;

  /// No description provided for @syncSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'No login data stored for the sync. Please log out and sign in again with your password.'**
  String get syncSignInAgain;

  /// No description provided for @syncStepBehaviouralStates.
  ///
  /// In en, this message translates to:
  /// **'Behavioural states'**
  String get syncStepBehaviouralStates;

  /// No description provided for @syncStepEncounterCategories.
  ///
  /// In en, this message translates to:
  /// **'Encounter categories'**
  String get syncStepEncounterCategories;

  /// No description provided for @syncStepFinish.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get syncStepFinish;

  /// No description provided for @syncStepImages.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos'**
  String get syncStepImages;

  /// No description provided for @syncStepSightings.
  ///
  /// In en, this message translates to:
  /// **'Uploading sightings'**
  String get syncStepSightings;

  /// No description provided for @syncStepSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get syncStepSpecies;

  /// No description provided for @syncStepTracking.
  ///
  /// In en, this message translates to:
  /// **'Uploading tour track {detail}'**
  String syncStepTracking(String detail);

  /// No description provided for @syncStepVehicles.
  ///
  /// In en, this message translates to:
  /// **'Boats and skippers'**
  String get syncStepVehicles;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Syncing with server'**
  String get syncTitle;

  /// No description provided for @syncWithServer.
  ///
  /// In en, this message translates to:
  /// **'Sync with Server'**
  String get syncWithServer;

  /// No description provided for @tabSightings.
  ///
  /// In en, this message translates to:
  /// **'Sightings'**
  String get tabSightings;

  /// No description provided for @tabTour.
  ///
  /// In en, this message translates to:
  /// **'Tour'**
  String get tabTour;

  /// No description provided for @toggleTorch.
  ///
  /// In en, this message translates to:
  /// **'Toggle torch'**
  String get toggleTorch;

  /// No description provided for @tourCloseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Close tour without saving? All changes will be lost!'**
  String get tourCloseQuestion;

  /// No description provided for @tourCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour close'**
  String get tourCloseTitle;

  /// No description provided for @tourDateNotCurrent.
  ///
  /// In en, this message translates to:
  /// **'The tour date is not current, please check!'**
  String get tourDateNotCurrent;

  /// No description provided for @tourDateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Tour: default date is not set'**
  String get tourDateNotSet;

  /// No description provided for @tourDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour date'**
  String get tourDateTitle;

  /// No description provided for @tourEnd.
  ///
  /// In en, this message translates to:
  /// **'Tour End'**
  String get tourEnd;

  /// No description provided for @tourEndQuestion.
  ///
  /// In en, this message translates to:
  /// **'Update the tour end time for all sighting entries from the current tour?'**
  String get tourEndQuestion;

  /// No description provided for @tourFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour finished'**
  String get tourFinishedTitle;

  /// No description provided for @tourLabel.
  ///
  /// In en, this message translates to:
  /// **'Tour: {date} - {start}'**
  String tourLabel(String date, String start);

  /// No description provided for @tourNotStartedHomeArea.
  ///
  /// In en, this message translates to:
  /// **'The tour has not started yet (still in the home area). The entry cannot be added until then.'**
  String get tourNotStartedHomeArea;

  /// No description provided for @tourSince.
  ///
  /// In en, this message translates to:
  /// **'since {time}'**
  String tourSince(String time);

  /// No description provided for @tourWaitingHomeArea.
  ///
  /// In en, this message translates to:
  /// **'Tour: In Home-Area, wait for start'**
  String get tourWaitingHomeArea;

  /// No description provided for @turtleGreen.
  ///
  /// In en, this message translates to:
  /// **'Green sea turtle'**
  String get turtleGreen;

  /// No description provided for @turtleHawksbill.
  ///
  /// In en, this message translates to:
  /// **'Hawksbill sea turtle'**
  String get turtleHawksbill;

  /// No description provided for @turtleLeatherback.
  ///
  /// In en, this message translates to:
  /// **'Leatherback sea turtle'**
  String get turtleLeatherback;

  /// No description provided for @turtleLoggerhead.
  ///
  /// In en, this message translates to:
  /// **'Loggerhead sea turtle'**
  String get turtleLoggerhead;

  /// No description provided for @turtleSeaTurtle.
  ///
  /// In en, this message translates to:
  /// **'Sea turtle'**
  String get turtleSeaTurtle;

  /// No description provided for @turtleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get turtleUnknown;

  /// No description provided for @useCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Use current position'**
  String get useCurrentPosition;

  /// No description provided for @userNeedsOrganization.
  ///
  /// In en, this message translates to:
  /// **'Please update the user, all users need an organization.'**
  String get userNeedsOrganization;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @waitForGps.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the GPS signal.'**
  String get waitForGps;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
