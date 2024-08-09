import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Dialog/InfoDialog.dart';
import 'package:mwpaapp/Mwpa/Models/Info.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Mwpa/MwpaAPI.dart';
import '../Mwpa/MwpaException.dart';

/// LoginPage
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// _LoginPageState
class _LoginPageState extends State<LoginPage> {
  final PrefController _prefController = Get.find<PrefController>();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  /// initState
  @override
  void initState() {
    super.initState();
    _isLogin();
    _loadPref();
  }

  /// signIn
  Future signIn() async {
    var url = _urlController.text.trim();
    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();

    try {
      var api = MwpaApi(url);

      Info apiInfo = await api.getInfo();

      if (apiInfo.version_api_login != versionApiMobileLogin) {
        throw Exception("The API for login has changed, please update your app, the data will not be lost.");
      }

      if (!await api.isLogin()) {
        if (await api.login(username, password)) {
          await _loadUser(api, url, username, password);
        }
      } else {
        await _loadUser(api, url, username, password);
      }
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      if (error is MwpaException) {
        setState(() {
          InfoDialog.show(context, 'Error', error.toString());
        });
      } else {
        setState(() {
          InfoDialog.show(context, 'Internal Error', error.toString());
        });
      }
    }
  }

  /// Load User
  Future<void> _loadUser(MwpaApi api, String url, String username, String password) async {
    if (await api.isLogin()) {
      final prefs = await SharedPreferences.getInstance();

      var userInfo = await api.getUserInfo();

      if (userInfo.user != null && userInfo.organization != null) {
        await prefs.setString(Preference.URL, url);
        await prefs.setString(Preference.USERNAME, username);
        await prefs.setString(Preference.PASSWORD, password);
        await prefs.setInt(Preference.USERID, userInfo.user!.id);
        await prefs.setInt(Preference.ORGID, userInfo.organization!.id);

        Get.toNamed('/List');
      } else {
        if (userInfo.organization == null) {
          throw Exception("Please update the user, all user need a organization.");
        }

        throw Exception("No user information response from server!");
      }
    } else {
      throw Exception("User session is not started!");
    }
  }

  /// _loadPref
  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.containsKey(Preference.URL)) {
        _urlController.text = prefs.getString(Preference.URL)!;
      } else {
        _urlController.text = const String.fromEnvironment('URL', defaultValue: '');
      }

      if (prefs.containsKey(Preference.USERNAME)) {
        _usernameController.text = prefs.getString(Preference.USERNAME)!;
      } else {
        _usernameController.text = const String.fromEnvironment('USERNAME', defaultValue: '');
      }

      if (prefs.containsKey(Preference.PASSWORD)) {
        _passwordController.text = prefs.getString(Preference.PASSWORD)!;
      } else {
        _passwordController.text = const String.fromEnvironment('PASSWORD', defaultValue: '');
      }
    });
  }

  /// _isLogin
  Future<void> _isLogin() async {
    await _prefController.load();

    if (_prefController.prominentDisclosureConfirmed == false) {
      Get.toNamed('/ProminentDisclosure');
      return;
    }

    if (_prefController.isLogin) {
      Get.toNamed('/List');
    }

    return;
  }

  /// build
  @override
  Widget build(BuildContext context) {
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
                  'MWPA Login',
                  style: headingStyle,
                ),

                const SizedBox(height: 10),

                Text(
                  'Mammal watching. Processing. Analysing.',
                  style: titleStyle,
                ),

                const SizedBox(height: 50),

                // url portal text-field

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'URL MWPA',

                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // username text-field

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Username/EMail'
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // password text-field

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // sign in button

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kPrimaryHeaderColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign In',
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

                const SizedBox(height: 25),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a Member?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                        ' Register on your MWPA Portal!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )
                    )
                  ],
                ),
              ],
            ),
          )
        )
      ),
    );
  }
}