import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Pages/EditSightingPage.dart';
import 'package:mwpaapp/Pages/EditTourPage.dart';
import 'package:mwpaapp/Pages/ListPage.dart';
import 'package:mwpaapp/Pages/LoginPage.dart';
import 'package:mwpaapp/Pages/ProminentDisclosurePage.dart';
import 'package:mwpaapp/Services/ThemeService.dart';
import 'package:mwpaapp/Ui/Themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();
  runApp(const MWPAApp());
}

class MWPAApp extends StatefulWidget {
  const MWPAApp({Key? key}) : super(key: key);

  @override
  State<MWPAApp> createState() => _MWPAAppState();
}

class _MWPAAppState extends State<MWPAApp> {
  final PrefController _prefController = Get.put(PrefController());
  final LocationController _locationController = Get.put(LocationController());

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mammal watching. Processing. Analysing.',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
      initialRoute: '/ProminentDisclosure',
      getPages: [
        GetPage(
            name: '/ProminentDisclosure',
            page: () => const ProminentDisclosurePage()
        ),
        GetPage(
          name: '/Login',
          page: () => const LoginPage()
        ),
        GetPage(
          name: '/List',
          page: () => const ListPage()
        ),
        GetPage(
          name: '/Edit',
          page: () => const EditSightingPage()
        ),
        GetPage(
          name: "/setTour",
          page: () => const EditTourPage()
        )
      ],
      builder: EasyLoading.init(),
    );
  }
}
