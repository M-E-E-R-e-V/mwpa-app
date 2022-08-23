import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Pages/List/EditSightingPage.dart';
import 'package:mwpaapp/Pages/ListPage.dart';
import 'package:mwpaapp/Pages/LoginPage.dart';

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
      builder: (context, widget) => Navigator(
        onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
          builder: (ctx) {
            return Container(
              child: widget,
            );
          },
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/List': (context) => const ListPage(),
        '/Edit': (context) => const EditSightingPage(),
      }
    );
  }
}
