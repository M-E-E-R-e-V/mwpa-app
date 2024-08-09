import 'dart:io' show Platform, exit;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ProminentDisclosurePage
class ProminentDisclosurePage extends StatefulWidget {
  const ProminentDisclosurePage({Key? key}) : super(key: key);

  @override
  State<ProminentDisclosurePage> createState() => _ProminentDisclosurePageState();
}

/// _ProminentDisclosurePageState
class _ProminentDisclosurePageState extends State<ProminentDisclosurePage> {

  /// initState
  @override
  void initState() {
    super.initState();
    _isAccept();
  }

  /// _isAccept
  Future<void> _isAccept() async {
    final prefs = await SharedPreferences.getInstance();

    var isAccept = false;

    if (prefs.containsKey(Preference.PROMINENT_DISCLOSURE_CONFIRMED)) {
      isAccept = prefs.getBool(Preference.PROMINENT_DISCLOSURE_CONFIRMED) ?? false;
    }

    if (isAccept) {
      LocationController locationController = Get.put(LocationController());

      if (await locationController.initLocation()) {
        Get.toNamed('/Login');
      } else {
        showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              double cWidth = MediaQuery.of(context).size.width*0.6;

              return Dialog(
                  child: SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            "No access to location determination!"
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          width: cWidth,
                          child: const Text(
                            'Please go to the system settings and allow the app access to the location:',
                          ),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryHeaderColor
                            ),
                            onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.location),
                            child: const Text("Open location settings")
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryHeaderColor
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Get.toNamed('/ProminentDisclosure');
                            },
                            child: const Text("Back")
                        )
                      ]
                    )
                  )
              );
            }
        );
      }
    }

    return;
  }

  /// acceptDisclosure
  Future acceptDisclosure() async {
    PrefController prefController = Get.find<PrefController>();
    await prefController.saveProminentDisclosureConfirmed(true);

    _isAccept();
  }

  /// rejectDisclosure
  Future rejectDisclosure() async {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  /// build
  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width*0.8;

    PrefController prefController = Get.find<PrefController>();
    prefController.saveProminentDisclosureConfirmed(false);

    return Scaffold(
      backgroundColor: Get.isDarkMode ? kPrimaryDarkBackgroundColor : kPrimaryBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'MWPA Disclosure',
                  style: headingStyle,
                ),

                const SizedBox(height: 10),

                Text(
                  'Mammal watching. Processing. Analysing.',
                  style: titleStyle,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: cWidth,
                      child: const Text(
                          'The MWPA app collects location data to auto-fill sighting data and track routes for movement activated even if the app is closed or not in use.',
                        )
                    ),
                  ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(16.0),
                          width: cWidth,
                          child: const Text(
                            'The app can only be used with position/location determination, otherwise the recorded data is useless. The data is only sent to the portal that is entered during login. For further questions you can contact or view the source code:',
                          )
                      ),
                    ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('https://github.com/M-E-E-R-e-V/mwpa-app'),
                  ],
                ),

                const SizedBox(height: 30),

                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: acceptDisclosure,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kPrimaryHeaderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Ok, sure and save',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    )
                ),


                const SizedBox(height: 30),

                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: rejectDisclosure,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kPrimaryBackgroundColor,
                          border: Border.all(
                            color: kPrimaryHeaderColor
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No, thanks and close',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    )
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('A project of the M.E.E.R. e.V. association.'),
                  ],
                )
              ]
            ),
          )
        )
      ),
    );
  }

}