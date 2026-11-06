// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about => 'Über';

  @override
  String get aboutAllContributors => 'Alle Mitwirkenden auf GitHub';

  @override
  String get aboutAppSource => 'Quellcode der App';

  @override
  String get aboutConnection => 'Verbindung';

  @override
  String get aboutContributors => 'Mitwirkende';

  @override
  String get aboutDevelopment => 'Softwareentwicklung';

  @override
  String get aboutImprint => 'Impressum';

  @override
  String get aboutLegal => 'Rechtliches';

  @override
  String get aboutLocalData => 'Daten auf diesem Gerät';

  @override
  String get aboutMapData => 'Kartendaten';

  @override
  String get aboutMwpaProject => 'MWPA-Projekt';

  @override
  String get aboutNotSynced => 'Noch nicht synchronisiert';

  @override
  String get aboutPrivacy => 'Datenschutzerklärung';

  @override
  String get aboutProject => 'Projekt';

  @override
  String get aboutProjectText =>
      'MWPA erfasst und analysiert Daten aus der Wal- und Delfinbeobachtung. Diese App zeichnet Sichtungen und Tourverläufe auf – auch offline – und synchronisiert sie mit einem MWPA-Server. Ein Projekt von M.E.E.R. e.V.';

  @override
  String get aboutServer => 'Server';

  @override
  String get aboutSightings => 'Sichtungen';

  @override
  String get aboutSupport => 'Support';

  @override
  String get aboutSupportText =>
      'Wenn etwas nicht funktioniert, teile das App-Log mit dem MWPA-Team (z. B. per Mail). Es enthält App-Ereignisse und Fehler, aber keine Passwörter.';

  @override
  String get aboutSupportedApi => 'Unterstützte Server-API';

  @override
  String get aboutUser => 'Benutzer';

  @override
  String accuracyMeters(int meters) {
    return 'Genauigkeit: $meters m';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get addSighting => 'Sichtung';

  @override
  String get addSightingHint => 'Vollständiges Formular';

  @override
  String get addSightingTitle => 'Sichtung hinzufügen';

  @override
  String get addTagHint => 'Tag hinzufügen ...';

  @override
  String get addTortoise => 'Schildkröte';

  @override
  String get addTortoiseHint => 'Schnelleintrag';

  @override
  String get addTortoiseTitle => 'Schildkröten-Sichtung hinzufügen';

  @override
  String addedSnack(String name) {
    return 'Hinzugefügt: $name';
  }

  @override
  String get allRequiredFilled => 'Alle Pflichtfelder sind ausgefüllt';

  @override
  String animalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tiere',
      one: '1 Tier',
    );
    return '$_temp0';
  }

  @override
  String apiLoginChanged(String server, String accepted) {
    return 'Die Login-API hat sich geändert (Server meldet \'$server\', die App akzeptiert $accepted). Bitte aktualisiere die App, die Daten gehen nicht verloren.';
  }

  @override
  String apiSyncChanged(String server, String accepted) {
    return 'Die Sync-API hat sich geändert (Server meldet \'$server\', die App akzeptiert $accepted). Bitte aktualisiere die App, die Daten gehen nicht verloren.';
  }

  @override
  String get appTagline => 'Mammal watching. Processing. Analysing.';

  @override
  String get atEndOfSighting => 'Am Ende der Sichtung';

  @override
  String get back => 'Zurück';

  @override
  String get badgeCalves => 'Kälber/Neugeborene';

  @override
  String get badgePicture => 'Bild';

  @override
  String get badgeSubgroups => 'Untergruppen';

  @override
  String batteryLowBanner(int level) {
    return 'Akku schwach ($level %) – bitte Ladegerät anschließen, die Routenaufzeichnung endet, wenn das Handy ausgeht.';
  }

  @override
  String get camera => 'Kamera';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get checkBeginAfterTourEnd =>
      'Die Sichtung beginnt nach dem Tourende.';

  @override
  String get checkBeginBeforeTourStart =>
      'Die Sichtung beginnt vor dem Tourbeginn.';

  @override
  String checkBeginFarFromTrack(String distance) {
    return 'Die Startposition ist $distance von der aufgezeichneten Route zu dieser Zeit entfernt.';
  }

  @override
  String get checkDateInFuture => 'Das Datum liegt in der Zukunft.';

  @override
  String get checkEndBeforeBegin => 'Die Sichtung endet vor ihrem Beginn.';

  @override
  String checkEndFarFromTrack(String distance) {
    return 'Die Endposition ist $distance von der aufgezeichneten Route zu dieser Zeit entfernt.';
  }

  @override
  String get checkTitle => 'Bitte prüfen';

  @override
  String get checkTourEndBeforeStart =>
      'Die Tour endet vor ihrem Beginn (über Mitternacht?).';

  @override
  String get choiceNo => 'Nein';

  @override
  String get choiceUnknown => 'Unbekannt';

  @override
  String get choiceYes => 'Ja';

  @override
  String get close => 'Schließen';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get currentTour => 'Aktuelle Tour';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteSightingQuestion =>
      'Diese Sichtung vom Gerät löschen? Bereits synchronisierte Daten bleiben auf dem Server.';

  @override
  String get deleteSightingTitle => 'Sichtung löschen';

  @override
  String get disclosureAccept => 'Ok, einverstanden und speichern';

  @override
  String get disclosureHeading => 'Wie wir deinen Standort nutzen';

  @override
  String get disclosureReject => 'Nein, danke und schließen';

  @override
  String get disclosureText1 =>
      'Die MWPA-App erfasst Standortdaten, um Sichtungsdaten automatisch auszufüllen und Fahrtrouten aufzuzeichnen – auch wenn die App geschlossen ist oder nicht verwendet wird.';

  @override
  String get disclosureText2 =>
      'Die App ist nur mit Positions-/Standortbestimmung nutzbar, sonst sind die erfassten Daten wertlos. Die Daten werden ausschließlich an das beim Login eingetragene Portal gesendet. Bei Fragen kannst du uns kontaktieren oder den Quellcode ansehen:';

  @override
  String get disclosureTitle => 'MWPA-Hinweis';

  @override
  String distanceNm(String distance) {
    return '$distance sm';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get editSightingTitle => 'Sichtung bearbeiten';

  @override
  String get error => 'Fehler';

  @override
  String get fieldBeginPosition => 'Position Beginn';

  @override
  String get fieldBeginTime => 'Sichtung ab';

  @override
  String get fieldCount => 'Anzahl Tiere';

  @override
  String get fieldDate => 'Datum';

  @override
  String get fieldEndPosition => 'Position Ende';

  @override
  String get fieldTourEnd => 'Tourende';

  @override
  String get fieldTourStart => 'Tourbeginn';

  @override
  String fieldsStillEmpty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Felder noch leer',
      one: '1 Feld noch leer',
    );
    return '$_temp0';
  }

  @override
  String get gallery => 'Galerie';

  @override
  String get gpsOff =>
      'GPS ist aus: keine Position und keine Routenaufzeichnung.';

  @override
  String get gpsOffBanner =>
      'GPS ist aus - keine Position, die Route wird nicht aufgezeichnet.';

  @override
  String get gpsOk => 'GPS läuft, die Route wird aufgezeichnet.';

  @override
  String get gpsSearching =>
      'GPS läuft, aber es gibt keine aktuelle Position (z. B. in Gebäuden).';

  @override
  String get gpsStatus => 'GPS-Status';

  @override
  String get groupDispersed => 'verstreut';

  @override
  String get groupLoose => 'locker';

  @override
  String get groupTight => 'dicht';

  @override
  String get groupWidelyDispersed => 'weit verstreut';

  @override
  String get help => 'Hilfe';

  @override
  String get helpBattery =>
      'Unter 20 % Akku erscheint während einer Tour eine Warnung – Ladegerät anschließen, sonst endet die Aufzeichnung, wenn das Handy ausgeht.';

  @override
  String get helpCloudDone => 'Auf dem Server.';

  @override
  String get helpCloudOff => 'Noch nicht synchronisiert.';

  @override
  String get helpCloudUpload =>
      'Geändert, wird mit dem nächsten Sync gesendet.';

  @override
  String get helpColorBlue => 'Blau: Die Sichtung ist vollständig.';

  @override
  String get helpColorGreen => 'Grün: Schnelleintrag einer Schildkröte.';

  @override
  String get helpColorRed =>
      'Rot: Ein Pflichtfeld ist noch leer (z. B. Anzahl der Tiere).';

  @override
  String get helpColorYellow =>
      'Gelb: Nur das Ende fehlt (Tourende, Endposition) oder die Art ist der App unbekannt – wird meist später ergänzt.';

  @override
  String get helpColorsTitle => 'Farben und Symbole in der Liste';

  @override
  String get helpGpsBackground =>
      'Die Route wird auch im Hintergrund aufgezeichnet; die Benachrichtigung zeigt, dass die Aufzeichnung läuft.';

  @override
  String get helpGpsIcon =>
      'Das GPS-Symbol oben: grün = Position OK, gelb = wird gesucht, rot = GPS aus. Bei ausgeschaltetem GPS wird die Route nicht aufgezeichnet.';

  @override
  String get helpGpsTitle => 'GPS, Akku und Bildschirm';

  @override
  String get helpMissingHints =>
      'Im Formular zeigt oben eine Karte die leeren Pflichtfelder und auffällige Werte. Ein Tipp auf einen Hinweis springt zum Feld. Speichern geht immer.';

  @override
  String get helpQuick =>
      '„Schildkröte“ speichert eine Schildkröte mit aktueller Position und Uhrzeit mit zwei Tipps. „Sichtung“ öffnet das vollständige Formular.';

  @override
  String get helpQuickEnd =>
      'Sichtungen der laufenden Tour ohne Endposition stehen als kleine Labels auf der Karte. Sind die Tiere weg, setzt der Stecknadel-Knopf dort (oder an der Sichtung in der Liste) Endposition und -zeit.';

  @override
  String get helpQuickTitle => 'Schnelleintrag';

  @override
  String get helpScreen =>
      '„Bildschirm anlassen“ in den Einstellungen hält das Display an, solange die App offen ist.';

  @override
  String get helpShowIntro => 'Einführung erneut anzeigen';

  @override
  String get helpSyncAuto =>
      'Die App synchronisiert von selbst, sobald wieder Netz da ist, und alle 15 Minuten. Die Zeile oben im Tab Sichtungen zeigt den letzten Sync und was noch offen ist.';

  @override
  String get helpSyncManual =>
      'Sofort synchronisieren: Liste nach unten ziehen, den Sync-Knopf antippen oder Menü → „Mit Server synchronisieren“.';

  @override
  String get helpSyncMap =>
      'Angesehene Kartenbereiche werden gespeichert und auch offline angezeigt.';

  @override
  String get helpSyncOffline =>
      'Alles wird zuerst auf dem Handy gespeichert. Sichtungen lassen sich ohne Netz erfassen – es geht nichts verloren.';

  @override
  String get helpSyncTitle => 'Sync und offline arbeiten';

  @override
  String get helpTourDefault =>
      'Boot, Skipper und Wind einmal am Tag unter Menü → „Einstellungen“ eintragen. Neue Sichtungen übernehmen diese Werte.';

  @override
  String get helpTourEnd =>
      'Ohne Heimatgebiet wird die Tour mit dem Knopf „Tour-Ende“ beendet – danach erscheint eine Zusammenfassung.';

  @override
  String get helpTourHomeArea =>
      'Mit eingeschaltetem „Heimatgebiet“ beginnt die Tour automatisch, wenn das Boot den Hafenbereich verlässt, und endet bei der Rückkehr.';

  @override
  String get helpTourRoute =>
      'Die orange Linie auf der Karte ist die aufgezeichnete Route der Tour. Der Tab Sichtungen gruppiert die Sichtungen nach Tour mit Dauer, Strecke und Arten.';

  @override
  String get helpTourTitle => 'Tour und Heimatgebiet';

  @override
  String get imageNotFound => 'Bild nicht gefunden';

  @override
  String get info => 'Info';

  @override
  String get internalError => 'Interner Fehler';

  @override
  String get intro1Text =>
      '„Sichtung“ öffnet das vollständige Formular, „Schildkröte“ speichert eine Schildkröte mit zwei Tipps. Farben in der Liste zeigen, was noch fehlt.';

  @override
  String get intro1Title => 'Sichtungen erfassen';

  @override
  String get intro2Text =>
      'Einmal am Tag die Tour unter „Einstellungen“ festlegen. Die App zeichnet die Route auf der Karte auf – mit Heimatgebiet beginnt und endet die Tour sogar von selbst.';

  @override
  String get intro2Title => 'Tour und Route';

  @override
  String get intro3Text =>
      'Alles wird auf dem Handy gespeichert und automatisch synchronisiert, sobald Netz da ist. Dies und mehr steht unter Menü → Hilfe.';

  @override
  String get intro3Title => 'Funktioniert offline';

  @override
  String get introDone => 'Los geht\'s';

  @override
  String get introNext => 'Weiter';

  @override
  String get introSkip => 'Überspringen';

  @override
  String get labelAllowTourEnd =>
      'Button „Tour-Ende“ für alle Sichtungen erlauben';

  @override
  String get labelBeaufort => 'Wind/Seegang (Beaufort)';

  @override
  String get labelBehaviour => 'Verhalten';

  @override
  String get labelBoat => 'Boot';

  @override
  String get labelCalves => 'Kälber';

  @override
  String get labelDistanceCoast => 'Entfernung zur nächsten Küste';

  @override
  String get labelEstimationNoGps => 'Schätzung ohne GPS';

  @override
  String get labelFreqBehaviour => 'Häufige Verhaltensweisen einzelner Tiere';

  @override
  String get labelGroupStructure => 'Gruppenstruktur';

  @override
  String get labelJuveniles => 'Jungtiere';

  @override
  String get labelKeepScreenOn => 'Bildschirm anlassen';

  @override
  String get labelNewborns => 'Neugeborene';

  @override
  String get labelNote => 'Notiz';

  @override
  String get labelOther => 'Sonstiges';

  @override
  String get labelOtherBoats => 'Weitere Boote anwesend';

  @override
  String get labelOtherSpecies => 'Weitere Arten';

  @override
  String get labelPassword => 'Passwort';

  @override
  String get labelPhotosTaken => 'Fotos gemacht';

  @override
  String get labelReaction => 'Reaktion';

  @override
  String get labelRecAnimals => 'Wiedererkennbare Tiere';

  @override
  String get labelSightingFrom => 'Dauer der Sichtung: von';

  @override
  String get labelSkipper => 'Skipper';

  @override
  String get labelSpecies => 'Art';

  @override
  String get labelSubgroups => 'Untergruppen';

  @override
  String get labelUntil => 'bis';

  @override
  String get labelUrl => 'URL MWPA';

  @override
  String get labelUseHomeArea =>
      'Tourbeginn und -ende automatisch über das Heimatgebiet';

  @override
  String get labelUsername => 'Benutzername / E-Mail';

  @override
  String get language => 'Sprache';

  @override
  String get locationPermissionText =>
      'Bitte erlaube der App in den Systemeinstellungen den Zugriff auf den Standort.';

  @override
  String get locationPermissionTitle => 'Standortberechtigung erforderlich';

  @override
  String logShareFailed(String error) {
    return 'Log konnte nicht geteilt werden: $error';
  }

  @override
  String get loginServerTimeout =>
      'Der Server hat nicht rechtzeitig geantwortet. Bitte später erneut versuchen.';

  @override
  String get loginServerUnreachable =>
      'Keine Verbindung zum Server. Bitte Netzverbindung und MWPA-URL prüfen.';

  @override
  String get loginTitle => 'MWPA-Anmeldung';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutQuestion => 'Möchtest du dich abmelden?';

  @override
  String logoutUnsynced(int count) {
    return '$count Sichtung(en) sind noch nicht synchronisiert. Bitte vor dem Abmelden synchronisieren, sonst werden sie mit der nächsten Anmeldung hochgeladen.\n\nTrotzdem abmelden?';
  }

  @override
  String get mapAttribution => 'Kartenquelle';

  @override
  String mapPositionPoints(String position, int count) {
    return '$position / Punkte: $count';
  }

  @override
  String get mapWaitForGps => 'warte auf GPS ...';

  @override
  String get menu => 'Menü';

  @override
  String get myLocation => 'Mein Standort';

  @override
  String get nauticalMilesUnit => 'sm';

  @override
  String get noGpsPositionYet => 'Noch keine GPS-Position vorhanden';

  @override
  String get noImageSelected => 'Kein Bild ausgewählt';

  @override
  String get noPosition => 'Keine Position';

  @override
  String get noPositionLower => 'keine Position';

  @override
  String get noSightingsHint => 'Tippe auf „Sichtung“, um eine zu erfassen.';

  @override
  String get noSightingsYet => 'Noch keine Sichtungen';

  @override
  String get noUserInfo =>
      'Der Server hat keine Benutzerinformationen geliefert!';

  @override
  String get notAMember => 'Noch kein Mitglied? ';

  @override
  String get notAValidNumber => 'Keine gültige Zahl';

  @override
  String get notLoggedIn => 'nicht angemeldet';

  @override
  String get notSelected => 'nicht ausgewählt';

  @override
  String get notSet => 'nicht gesetzt';

  @override
  String get ok => 'Ok';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get openSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get positionFoundQuestion =>
      'Zu dieser Zeit gibt es eine Position der aktuellen Tour. Soll sie übernommen werden?';

  @override
  String get positionFoundTitle => 'Position gefunden';

  @override
  String get projectOfMeer => 'Ein Projekt des Vereins M.E.E.R. e.V.';

  @override
  String get qcIncomplete => 'Der Quick-Connect-Code ist unvollständig.';

  @override
  String get qcInvalidPayload =>
      'Der QR-Code ist kein gültiger Quick-Connect-Code.';

  @override
  String get qcPointAtCode =>
      'Richte die Kamera auf den QR-Code im MWPA-Webportal.';

  @override
  String get qcUnsupportedVersion =>
      'Nicht unterstützte Quick-Connect-Version. Bitte aktualisiere die App.';

  @override
  String get quickConnect => 'Quick Connect';

  @override
  String get registerOnPortal => 'Registriere dich in deinem MWPA-Portal!';

  @override
  String get remove => 'Entfernen';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get required => 'Pflichtfeld';

  @override
  String get save => 'Speichern';

  @override
  String get saveAnywayHint =>
      'Du kannst trotzdem speichern und später ergänzen.';

  @override
  String get saveSettings => 'Einstellungen speichern';

  @override
  String get saveSighting => 'Sichtung speichern';

  @override
  String savedStillEmpty(String fields) {
    return 'Gespeichert. Noch leer: $fields';
  }

  @override
  String get sectionAnimals => 'Tiere';

  @override
  String get sectionBehaviour => 'Verhalten & Identifikation';

  @override
  String get sectionNotes => 'Weitere Notizen';

  @override
  String get sectionPicture => 'Bild';

  @override
  String get sectionSettings => 'Einstellungen';

  @override
  String get sectionTimePosition => 'Zeit & Position';

  @override
  String get sectionDefaultTour => 'Standard-Tour';

  @override
  String get sectionDefaultTourInfo =>
      'Boot, Skipper, Wind und Tourzeiten werden in jede neue Sichtung übernommen und ordnen sie dieser Tour zu. Am besten einmal am Tag vor der Ausfahrt ausfüllen.';

  @override
  String get sectionTour => 'Tour';

  @override
  String get selectEmptyList => '<leere Liste>';

  @override
  String get selectPlease => '<bitte wählen>';

  @override
  String selectUnknownId(String id) {
    return 'unbekannte ID: $id';
  }

  @override
  String get serverTimeout =>
      'Der Server hat nicht rechtzeitig geantwortet. Bitte später erneut versuchen. Die Daten bleiben auf dem Gerät und werden später synchronisiert.';

  @override
  String get serverUnreachable =>
      'Keine Verbindung zum Server. Bitte Netzverbindung und Server-URL prüfen. Die Daten bleiben auf dem Gerät und werden später synchronisiert.';

  @override
  String get sessionNotStarted => 'Die Benutzersitzung wurde nicht gestartet!';

  @override
  String get setDefaultTourFirst =>
      'Bitte zuerst unter Menü → „Einstellungen“ Datum und Startzeit der Tour festlegen. Bis dahin kann kein Eintrag angelegt werden.';

  @override
  String get setEndLocation => 'Endposition setzen';

  @override
  String get setEndLocationQuestion =>
      'Endposition und Endzeit für diese Sichtung setzen?';

  @override
  String get setEndLocationTitle => 'Endposition/-zeit setzen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shareAppLog => 'App-Log teilen';

  @override
  String get sightingCloseQuestion =>
      'Sichtung ohne Speichern schließen? Alle Änderungen gehen verloren!';

  @override
  String get sightingCloseTitle => 'Sichtung schließen';

  @override
  String sightingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sichtungen',
      one: '1 Sichtung',
    );
    return '$_temp0';
  }

  @override
  String get signIn => 'Anmelden';

  @override
  String get speciesNotFound => 'Art nicht gefunden';

  @override
  String get stateEndMissing => 'Ende fehlt';

  @override
  String get stateIncomplete => 'Unvollständig';

  @override
  String get stateUnknownSpecies => 'Unbekannte Art';

  @override
  String get stillOpenAtEnd => 'Noch offen - am Ende ausfüllen';

  @override
  String get switchCamera => 'Kamera wechseln';

  @override
  String get switchToDarkTheme => 'Dunkles Design';

  @override
  String get switchToLightTheme => 'Helles Design';

  @override
  String get syncAutoStopped =>
      'Automatischer Sync gestoppt – Details antippen';

  @override
  String get syncChanged => 'Geändert, wartet auf Sync';

  @override
  String get syncConnecting => 'Verbinde ...';

  @override
  String get syncDone => 'Synchronisiert';

  @override
  String get syncFailedRetry =>
      'Sync fehlgeschlagen, wird automatisch wiederholt – Details antippen';

  @override
  String syncLastDate(String date) {
    return 'Zuletzt synchronisiert $date';
  }

  @override
  String syncLastHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Vor $hours Stunden synchronisiert',
      one: 'Vor 1 Stunde synchronisiert',
    );
    return '$_temp0';
  }

  @override
  String get syncLastJustNow => 'Gerade synchronisiert';

  @override
  String syncLastMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Vor $minutes Minuten synchronisiert',
      one: 'Vor 1 Minute synchronisiert',
    );
    return '$_temp0';
  }

  @override
  String get syncLoginRejected =>
      'Der Server hat die Anmeldung abgelehnt (Passwort geändert?). Bitte abmelden und neu anmelden. Die Daten bleiben auf dem Gerät.';

  @override
  String get syncNotYet => 'Noch nicht synchronisiert';

  @override
  String syncOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offen',
      one: '1 offen',
    );
    return '$_temp0';
  }

  @override
  String get syncRunning => 'Synchronisiere …';

  @override
  String get syncSignInAgain =>
      'Für den Sync sind keine Anmeldedaten gespeichert. Bitte abmelden und mit Passwort neu anmelden.';

  @override
  String get syncStepBehaviouralStates => 'Verhaltenszustände';

  @override
  String get syncStepEncounterCategories => 'Begegnungskategorien';

  @override
  String get syncStepFinish => 'Fertig';

  @override
  String get syncStepImages => 'Fotos hochladen';

  @override
  String get syncStepSightings => 'Sichtungen hochladen';

  @override
  String get syncStepSpecies => 'Arten';

  @override
  String syncStepTracking(String detail) {
    return 'Tourverlauf hochladen $detail';
  }

  @override
  String get syncStepVehicles => 'Boote und Skipper';

  @override
  String get syncTitle => 'Synchronisiere mit Server';

  @override
  String get syncWithServer => 'Mit Server synchronisieren';

  @override
  String get tabSightings => 'Sichtungen';

  @override
  String get tabTour => 'Tour';

  @override
  String get toggleTorch => 'Taschenlampe ein/aus';

  @override
  String get settingsCloseQuestion =>
      'Einstellungen ohne Speichern schließen? Alle Änderungen gehen verloren!';

  @override
  String get settingsCloseTitle => 'Einstellungen schließen';

  @override
  String get tourDateNotCurrent =>
      'Das Tour-Datum ist nicht aktuell, bitte prüfen!';

  @override
  String get tourDateNotSet => 'Tour: kein Datum gesetzt';

  @override
  String get tourDateTitle => 'Tour-Datum';

  @override
  String get tourEnd => 'Tour-Ende';

  @override
  String get tourEndQuestion =>
      'Tour-Endzeit für alle Sichtungen der aktuellen Tour setzen?';

  @override
  String get tourFinishedTitle => 'Tour beendet';

  @override
  String tourLabel(String date, String start) {
    return 'Tour: $date - $start';
  }

  @override
  String get tourNotStartedHomeArea =>
      'Die Tour hat noch nicht begonnen (noch im Heimatgebiet). Bis dahin kann kein Eintrag angelegt werden.';

  @override
  String tourSince(String time) {
    return 'seit $time';
  }

  @override
  String get tourWaitingHomeArea => 'Tour: im Heimatgebiet, warte auf Start';

  @override
  String get turtleGreen => 'Suppenschildkröte';

  @override
  String get turtleHawksbill => 'Echte Karettschildkröte';

  @override
  String get turtleLeatherback => 'Lederschildkröte';

  @override
  String get turtleLoggerhead => 'Unechte Karettschildkröte';

  @override
  String get turtleSeaTurtle => 'Meeresschildkröte';

  @override
  String get turtleUnknown => 'Unbekannt';

  @override
  String get useCurrentPosition => 'Aktuelle Position übernehmen';

  @override
  String get userNeedsOrganization =>
      'Bitte den Benutzer anpassen, jeder Benutzer braucht eine Organisation.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get waitForGps => 'Bitte auf das GPS-Signal warten.';

  @override
  String get zoomIn => 'Vergrößern';

  @override
  String get zoomOut => 'Verkleinern';

  @override
  String runningMore(int count) {
    return '+$count weitere';
  }
}
