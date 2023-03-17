
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';

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
    PrefController prefController = Get.find<PrefController>();

    if (prefController.prominentDisclosureConfirmed) {
      Get.toNamed('/Login');
    }

    return;
  }

  /// acceptDisclosure
  Future acceptDisclosure() async {
    PrefController prefController = Get.find<PrefController>();
    prefController.saveProminentDisclosureConfirmed(true);

    _isAccept();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width*0.8;

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

                const SizedBox(height: 75),

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
                      child: const Flexible(
                        child: Text(
                          'I agree that the app continuously tracks and saves the position (GPS/location) in the background. The app can only be used with position/location determination, otherwise the recorded data is useless. The data is only sent to the portal that is entered during login. For further questions you can contact or view the source code:',
                        ),
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

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('A project of the M.E.E.R. e.V. association.'),
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
                            'Accept',
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
              ]
            ),
          )
        )
      ),
    );
  }

}