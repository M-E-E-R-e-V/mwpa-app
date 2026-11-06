import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/LanguageSelector.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Dialog/InfoDialog.dart';
import 'package:mwpaapp/Mwpa/Models/Info.dart';
import 'package:mwpaapp/Pages/QuickConnectScanPage.dart';
import 'package:mwpaapp/Settings/CredentialStore.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Mwpa/MwpaAPI.dart';
import '../Mwpa/MwpaException.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// LoginPage
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// _LoginPageState
class _LoginPageState extends State<LoginPage> {
  late final PrefController _prefController = context.read<PrefController>();
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
    final l10n = context.l10n;
    MwpaApi? api;

    try {
      api = MwpaApi(url);

      Info apiInfo = await api.getInfo();

      if (!versionApiMobileLogin.contains(apiInfo.version_api_login)) {
        throw Exception(l10n.apiLoginChanged(
            '${apiInfo.version_api_login}', versionApiMobileLogin.join(', ')));
      }

      if (!await api.isLogin()) {
        if (await api.login(username, password)) {
          await _loadUser(api, url, username, password);
        }
      } else {
        await _loadUser(api, url, username, password);
      }
    } catch(error) {
      AppLog.w('Login', 'sign in failed', error);

      if (!mounted) return;

      if (error is MwpaConnectionException) {
        InfoDialog.show(
          context,
          l10n.error,
          error.timeout ? l10n.loginServerTimeout : l10n.loginServerUnreachable,
          isError: true,
        );
      } else if (error is MwpaException) {
        setState(() {
          InfoDialog.show(context, l10n.error, error.toString(), isError: true);
        });
      } else {
        setState(() {
          InfoDialog.show(context, l10n.internalError, error.toString(), isError: true);
        });
      }
    } finally {
      api?.close();
    }
  }

  /// quickConnect
  /// Open the QR scanner, parse the payload the web portal generated, exchange
  /// the embedded OTP for a mobile session, and persist enough preferences for
  /// the rest of the app to work.
  ///
  /// We deliberately do NOT store the user's password — Quick Connect never
  /// learns it. SyncMwpaService falls back to the login page when PASSWORD is
  /// missing, so background sync will be inactive until the user signs in once
  /// with email/password (acceptable for the MVP).
  Future<void> quickConnect() async {
    final l10n = context.l10n;
    MwpaApi? api;

    try {
      final scanned = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const QuickConnectScanPage()),
      );

      if (scanned == null || scanned.isEmpty) {
        return;
      }

      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(scanned) as Map<String, dynamic>;
      } catch (_) {
        throw MwpaException(l10n.qcInvalidPayload);
      }

      final version = payload['version'];
      final server = payload['server'] as String?;
      final username = payload['username'] as String?;
      final otp = payload['otp'] as String?;

      if (version != 1) {
        throw MwpaException(l10n.qcUnsupportedVersion);
      }

      if (server == null || server.isEmpty || otp == null || otp.isEmpty || username == null) {
        throw MwpaException(l10n.qcIncomplete);
      }

      api = MwpaApi(server);

      Info apiInfo = await api.getInfo();

      if (!versionApiMobileLogin.contains(apiInfo.version_api_login)) {
        throw Exception(l10n.apiLoginChanged(
            '${apiInfo.version_api_login}', versionApiMobileLogin.join(', ')));
      }

      if (await api.quickConnect(otp)) {
        await _persistQuickConnect(api, server, username);
      }
    } catch (error) {
      AppLog.w('Login', 'quick connect failed', error);

      if (!mounted) return;

      if (error is MwpaConnectionException) {
        InfoDialog.show(
          context,
          l10n.error,
          error.timeout ? l10n.loginServerTimeout : l10n.loginServerUnreachable,
          isError: true,
        );
      } else if (error is MwpaException) {
        setState(() {
          InfoDialog.show(context, l10n.error, error.toString(), isError: true);
        });
      } else {
        setState(() {
          InfoDialog.show(context, l10n.internalError, error.toString(), isError: true);
        });
      }
    } finally {
      api?.close();
    }
  }

  /// Persist URL + username + ids for a Quick Connect session. Mirrors
  /// _loadUser but skips the password — Quick Connect never receives it.
  Future<void> _persistQuickConnect(MwpaApi api, String url, String username) async {
    final l10n = context.l10n;

    if (await api.isLogin()) {
      final prefs = await SharedPreferences.getInstance();

      var userInfo = await api.getUserInfo();

      if (userInfo.user != null && userInfo.organization != null) {
        await prefs.setString(Preference.URL, url);
        await prefs.setString(Preference.USERNAME, username);
        // Wipe any stale password so SyncMwpaService doesn't reuse a previous
        // user's credentials against this session.
        await CredentialStore().deletePassword();
        await prefs.setInt(Preference.USERID, userInfo.user!.id);
        await prefs.setInt(Preference.ORGID, userInfo.organization!.id);

        AppLog.i('Login', 'quick connect: logged in, user ${userInfo.user!.id}');

        if (!mounted) return;
        Navigator.of(context).pushNamed('/List');
      } else {
        if (userInfo.organization == null) {
          throw Exception(l10n.userNeedsOrganization);
        }

        throw Exception(l10n.noUserInfo);
      }
    } else {
      throw Exception(l10n.sessionNotStarted);
    }
  }

  /// Load User
  Future<void> _loadUser(MwpaApi api, String url, String username, String password) async {
    final l10n = context.l10n;

    if (await api.isLogin()) {
      final prefs = await SharedPreferences.getInstance();

      var userInfo = await api.getUserInfo();

      if (userInfo.user != null && userInfo.organization != null) {
        await prefs.setString(Preference.URL, url);
        await prefs.setString(Preference.USERNAME, username);
        await CredentialStore().writePassword(password);
        await prefs.setInt(Preference.USERID, userInfo.user!.id);
        await prefs.setInt(Preference.ORGID, userInfo.organization!.id);
        AppLog.i('Login', 'logged in, user ${userInfo.user!.id}');

        if (!mounted) return;
        Navigator.of(context).pushNamed('/List');
      } else {
        if (userInfo.organization == null) {
          throw Exception(l10n.userNeedsOrganization);
        }

        throw Exception(l10n.noUserInfo);
      }
    } else {
      throw Exception(l10n.sessionNotStarted);
    }
  }

  /// _loadPref
  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

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

    });

    final password = await CredentialStore().readPassword();

    if (!mounted) return;

    setState(() {
      _passwordController.text = password ?? const String.fromEnvironment('PASSWORD', defaultValue: '');
    });
  }

  /// _isLogin
  Future<void> _isLogin() async {
    await _prefController.load();

    if (!mounted) return;

    if (_prefController.prominentDisclosureConfirmed == false) {
      Navigator.of(context).pushNamed('/ProminentDisclosure');
      return;
    }

    if (_prefController.isLogin) {
      Navigator.of(context).pushNamed('/List');
    }

    return;
  }

  /// build
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: const [LanguageSelector()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 120,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    context.l10n.loginTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.l10n.labelUrl,
                      prefixIcon: const Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.l10n.labelUsername,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => signIn(),
                    decoration: InputDecoration(
                      labelText: context.l10n.labelPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: signIn,
                    icon: const Icon(Icons.login),
                    label: Text(context.l10n.signIn),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: quickConnect,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(context.l10n.quickConnect),
                  ),
                  const SizedBox(height: 28),
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: context.l10n.notAMember,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: context.l10n.registerOnPortal),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}