
import 'package:flutter/material.dart';
import 'package:mwpaapp/Setting/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    var url = _urlController.text.trim();
    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();

    if (true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Preference.URL, url);
      await prefs.setString(Preference.USERNAME, username);
      await prefs.setString(Preference.PASSWORD, password);
    }

    // https://www.youtube.com/watch?v=c09XiwOZKsI
    // https://www.youtube.com/watch?v=PBxbWZZTG2Q
    // https://www.youtube.com/hashtag/createdbykoko

    // https://www.youtube.com/watch?v=tKtYfuuVHlA
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  child: Image.asset(
                      'lib/Icons/logo.png'
                  ),
                ),

                const SizedBox(height: 75),

                // Title
                const Text(
                  'NWPA Login',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 36
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Mammal watching. Processing. Analysing.',
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),

                const SizedBox(height: 50),

                // url portal textfield

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'URL NWPA'
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // username textfield

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: Colors.white),
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

                // password textfield

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password'
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
                        color: Colors.indigo,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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