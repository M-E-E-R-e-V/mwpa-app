import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Pages/LoginPage.dart';
import 'package:mwpaapp/Pages/WelcomePage.dart';

void main() {
  runApp(const MWPAApp());
}

class MWPAApp extends StatelessWidget {
  const MWPAApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mammal watching. Processing. Analysing.',
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage()
    );
  }
}
