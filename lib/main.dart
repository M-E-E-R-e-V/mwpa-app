import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/BatteryController.dart';
import 'package:mwpaapp/Controllers/SyncController.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocaleController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/ThemeController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Pages/AboutPage.dart';
import 'package:mwpaapp/Pages/EditSightingPage.dart';
import 'package:mwpaapp/Pages/EditTourPage.dart';
import 'package:mwpaapp/Pages/HelpPage.dart';
import 'package:mwpaapp/Pages/ListPage.dart';
import 'package:mwpaapp/Pages/LoginPage.dart';
import 'package:mwpaapp/Pages/ProminentDisclosurePage.dart';
import 'package:mwpaapp/Ui/Themes.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// _registerFontLicenses - bundled fonts and the OSM map data on the license page (packages
/// register their licenses themselves)
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      ['Lato font'],
      await rootBundle.loadString('assets/fonts/OFL.txt'),
    );
    yield LicenseEntryWithLineBreaks(
      ['Material Design Icons'],
      await rootBundle.loadString('assets/fonts/MaterialDesignIcons-LICENSE.txt'),
    );
    // map tiles of the tour map (data: ODbL)
    yield const LicenseEntryWithLineBreaks(
      ['OpenStreetMap'],
      'Map data © OpenStreetMap contributors.\n\n'
      'The data is available under the Open Database License (ODbL) 1.0, '
      'the map tiles are provided by the OpenStreetMap Foundation.\n\n'
      'https://www.openstreetmap.org/copyright',
    );
  });
}

/// main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLog.init();
  AppLog.i('App', 'start $kAppVersion ($kAppBuild)');

  // uncaught errors go to the log file, so they can be shared from the field
  FlutterError.onError = (details) {
    AppLog.e('Flutter', details.exceptionAsString(), null, details.stack);
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLog.e('Uncaught', error, null, stack);
    return false;
  };

  if (kDebugMode) {
    // Allow self-signed certificates against local MWPA dev servers. Never
    // active in release builds — kDebugMode is compile-time constant false
    // there, so the HttpOverrides assignment is tree-shaken away.
    HttpOverrides.global = _DevHttpOverrides();
  }

  await DBHelper.initDb();

  _registerFontLicenses();

  // Preferences are loaded before the first frame, so every page sees the
  // login state, the disclosure flag and the active tour from the start.
  final prefController = PrefController();
  await prefController.load();

  final themeController = ThemeController();
  await themeController.load();

  final localeController = LocaleController();
  await localeController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PrefController>.value(value: prefController),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<LocaleController>.value(value: localeController),
        ChangeNotifierProvider(create: (_) => SightingController()..getSightings()),
        ChangeNotifierProvider(create: (_) => BatteryController()),
        ChangeNotifierProvider(create: (_) => VehicleController()..getVehicle()),
        ChangeNotifierProvider(create: (_) => VehicleDriverController()..getVehicleDriver()),
        ChangeNotifierProvider(create: (_) => SpeciesController()..getSpecies()),
        ChangeNotifierProvider(create: (_) => EncounterCategoriesController()..getEncounterCategorie()),
        ChangeNotifierProvider(create: (_) => BehaviouralStateController()..getBehaviouralStates()),
        // Created lazily on first use (ListPage / ProminentDisclosurePage).
        // Location tracking only starts when the prominent disclosure was
        // accepted, see LocationController.initIfConfirmed().
        ChangeNotifierProvider(
          create: (context) => LocationController(
            context.read<PrefController>(),
            context.read<SightingController>(),
          )..initIfConfirmed(),
        ),
        // automatic background sync, started with the main screen
        ChangeNotifierProvider(
          create: (context) {
            final species = context.read<SpeciesController>();
            final vehicles = context.read<VehicleController>();
            final drivers = context.read<VehicleDriverController>();
            final categories = context.read<EncounterCategoriesController>();
            final states = context.read<BehaviouralStateController>();
            final location = context.read<LocationController>();
            final sightings = context.read<SightingController>();

            return SyncController(
              prefs: context.read<PrefController>(),
              runSync: (update) => SyncMwpaService(species).sync(update),
              pendingCount: DBHelper.countPendingSync,
              // reference data and sightings changed on the server side
              afterSync: () async {
                await vehicles.getVehicle();
                await drivers.getVehicleDriver();
                await species.getSpecies();
                await categories.getEncounterCategorie();
                await states.getBehaviouralStates();
                await location.reloadSettings();
                await sightings.getSightings();
              },
            )..start();
          },
        ),
      ],
      child: const MWPAApp(),
    ),
  );
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

/// MWPAApp
class MWPAApp extends StatelessWidget {
  const MWPAApp({super.key});

  /// initialRoute - first page: the location disclosure until it was
  /// accepted, then the list when logged in, else the login.
  static String initialRoute(PrefController prefs) {
    if (!prefs.prominentDisclosureConfirmed) {
      return '/ProminentDisclosure';
    }

    return prefs.isLogin ? '/List' : '/Login';
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mammal watching. Processing. Analysing.',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: context.watch<ThemeController>().themeMode,
      // UI language from the flag selection (default English)
      locale: context.watch<LocaleController>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // prefs are loaded before runApp, so the first page is known right
      // away - no login form flashing up before the list
      initialRoute: initialRoute(context.read<PrefController>()),
      routes: {
        '/ProminentDisclosure': (_) => const ProminentDisclosurePage(),
        '/About': (_) => const AboutPage(),
        '/Help': (_) => const HelpPage(),
        '/Login': (_) => const LoginPage(),
        '/List': (_) => const ListPage(),
        '/Edit': (_) => const EditSightingPage(),
        '/setTour': (_) => const EditTourPage(),
      },
    );
  }
}
