import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AboutPage - app version, connection, local data and project links; the
/// open source licenses via the Flutter license page.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static const String projectUrl = 'https://github.com/M-E-E-R-e-V/mwpa';
  static const String appUrl = 'https://github.com/M-E-E-R-e-V/mwpa-app';
  static const String developerName = 'Pegenau GmbH & Co. KG';
  static const String developerUrl = 'https://www.pegenau.de/';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _server = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _server = prefs.getString(Preference.URL) ?? '';
      _username = prefs.getString(Preference.USERNAME) ?? '';
    });
  }

  /// _copy - no browser plugin in the app: links are copied
  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sightings = context.watch<SightingController>().sightingList;
    final unsynced = sightings
        .where((s) => s.unid == '' || s.syncStatus == Sighting.SYNC_STATUS_OPEN)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
          children: [
            // header -------------------------------------------------------
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/images/logo_512.png', width: 112, height: 112),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'MWPA',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Mammal Watching. Processing. Analysing.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Center(
              child: Chip(
                avatar: const Icon(Icons.verified_outlined, size: 18),
                label: const Text('Version $kAppVersion ($kAppBuild)'),
              ),
            ),
            const SizedBox(height: 20),

            // connection ---------------------------------------------------
            InputSection(
              title: 'Connection',
              icon: Icons.cloud_outlined,
              children: [
                _InfoTile(
                  icon: Icons.dns_outlined,
                  label: 'Server',
                  value: _server.isEmpty ? 'not set' : _server,
                ),
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'User',
                  value: _username.isEmpty ? 'not logged in' : _username,
                ),
                _InfoTile(
                  icon: Icons.api_outlined,
                  label: 'Supported server API',
                  value: 'Login ${versionApiMobileLogin.join(', ')} · '
                      'Sync ${versionApiMobileSync.join(', ')}',
                ),
              ],
            ),

            // local data ---------------------------------------------------
            InputSection(
              title: 'Data on this device',
              icon: Icons.storage_outlined,
              children: [
                _InfoTile(
                  icon: Icons.list_alt,
                  label: 'Sightings',
                  value: '${sightings.length}',
                ),
                _InfoTile(
                  icon: unsynced == 0 ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                  label: 'Not synced yet',
                  value: '$unsynced',
                ),
              ],
            ),

            // project ------------------------------------------------------
            InputSection(
              title: 'Project',
              icon: Icons.info_outline,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'MWPA collects and analyses data of whale and dolphin '
                    'watching. This app records sightings and tour tracks, '
                    'also offline, and syncs them with an MWPA server. '
                    'A project of M.E.E.R. e.V.',
                  ),
                ),
                _InfoTile(
                  icon: Icons.code,
                  label: 'MWPA project',
                  value: AboutPage.projectUrl,
                  onTap: () => _copy(AboutPage.projectUrl),
                ),
                _InfoTile(
                  icon: Icons.phone_android,
                  label: 'App source code',
                  value: AboutPage.appUrl,
                  onTap: () => _copy(AboutPage.appUrl),
                ),
                _InfoTile(
                  icon: Icons.business_outlined,
                  label: 'Software development',
                  value: '${AboutPage.developerName}\n${AboutPage.developerUrl}',
                  onTap: () => _copy(AboutPage.developerUrl),
                ),
              ],
            ),

            FilledButton.tonalIcon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'MWPA',
                applicationVersion: '$kAppVersion ($kAppBuild)',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/logo_512.png', width: 64, height: 64),
                ),
              ),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Open source licenses'),
            ),
          ],
        ),
      ),
    );
  }
}

/// _InfoTile - label/value row; with [onTap] a copy icon is shown
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: inputAccentColor(context)),
      title: Text(label, style: inputLabelStyle(context)),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      trailing: onTap == null ? null : const Icon(Icons.copy, size: 20),
      onTap: onTap,
    );
  }
}
