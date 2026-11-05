import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/ThemeController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Pages/EditSightingPage.dart';
import 'package:mwpaapp/Pages/EditTourPage.dart';
import 'package:mwpaapp/Pages/ListPage.dart';
import 'package:mwpaapp/Pages/LoginPage.dart';
import 'package:mwpaapp/Pages/ProminentDisclosurePage.dart';
import 'package:mwpaapp/Ui/Themes.dart';
import 'package:provider/provider.dart';

/// main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    // Allow self-signed certificates against local MWPA dev servers. Never
    // active in release builds — kDebugMode is compile-time constant false
    // there, so the HttpOverrides assignment is tree-shaken away.
    HttpOverrides.global = _DevHttpOverrides();
  }

  await DBHelper.initDb();

  // Preferences are loaded before the first frame, so every page sees the
  // login state, the disclosure flag and the active tour from the start.
  final prefController = PrefController();
  await prefController.load();

  final themeController = ThemeController();
  await themeController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PrefController>.value(value: prefController),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider(create: (_) => SightingController()..getSightings()),
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mammal watching. Processing. Analysing.',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: context.watch<ThemeController>().themeMode,
      initialRoute: '/Login',
      routes: {
        '/ProminentDisclosure': (_) => const ProminentDisclosurePage(),
        '/Login': (_) => const LoginPage(),
        '/List': (_) => const ListPage(),
        '/Edit': (_) => const EditSightingPage(),
        '/setTour': (_) => const EditTourPage(),
      },
      builder: EasyLoading.init(),
    );
  }
}
