import 'dart:io' show Platform, exit;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ProminentDisclosurePage
class ProminentDisclosurePage extends StatefulWidget {
  const ProminentDisclosurePage({super.key});

  @override
  State<ProminentDisclosurePage> createState() =>
      _ProminentDisclosurePageState();
}

/// _ProminentDisclosurePageState
class _ProminentDisclosurePageState extends State<ProminentDisclosurePage> {
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
      isAccept =
          prefs.getBool(Preference.PROMINENT_DISCLOSURE_CONFIRMED) ?? false;
    }

    if (isAccept) {
      if (!mounted) return;
      LocationController locationController = context.read<LocationController>();

      if (await locationController.initLocation()) {
        if (!mounted) return;
        Navigator.of(context).pushNamed('/Login');
      } else {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              icon: const Icon(Icons.location_off_outlined, size: 32),
              title: const Text('Location permission required'),
              content: const Text(
                'Please go to the system settings and allow the app access to the location.',
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                OutlinedButton(
                  // back to the disclosure underneath; "accept" retries
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
                FilledButton.icon(
                  // location service off -> system location settings,
                  // otherwise the app settings with the permission
                  onPressed: () async {
                    if (await Geolocator.isLocationServiceEnabled()) {
                      await Geolocator.openAppSettings();
                    } else {
                      await Geolocator.openLocationSettings();
                    }
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Open settings'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  /// acceptDisclosure
  Future<void> acceptDisclosure() async {
    PrefController prefController = context.read<PrefController>();
    await prefController.saveProminentDisclosureConfirmed(true);
    _isAccept();
  }

  /// rejectDisclosure
  Future<void> rejectDisclosure() async {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 120,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'MWPA Disclosure',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mammal watching. Processing. Analysing.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.my_location_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'How we use your location',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'The MWPA app collects location data to auto-fill '
                            'sighting data and track routes for movement '
                            'activated even if the app is closed or not in use.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'The app can only be used with position/location '
                            'determination, otherwise the recorded data is '
                            'useless. The data is only sent to the portal that '
                            'is entered during login. For further questions you '
                            'can contact or view the source code:',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            'https://github.com/M-E-E-R-e-V/mwpa-app',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: acceptDisclosure,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ok, sure and save'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: rejectDisclosure,
                    icon: const Icon(Icons.close),
                    label: const Text('No, thanks and close'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'A project of the M.E.E.R. e.V. association.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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