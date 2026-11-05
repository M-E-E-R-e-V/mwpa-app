import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/Util/UtilShare.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// AboutPage - app version, connection, local data and project links; the
/// open source licenses via the Flutter license page.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static const String projectUrl = 'https://github.com/M-E-E-R-e-V/mwpa';
  static const String appUrl = 'https://github.com/M-E-E-R-e-V/mwpa-app';
  static const String developerName = 'Pegenau GmbH & Co. KG';
  static const String osmCopyrightUrl = 'https://www.openstreetmap.org/copyright';
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

  bool _sharing = false;

  /// _shareLog - log file with app/device header via the share sheet
  Future<void> _shareLog() async {
    setState(() => _sharing = true);

    try {
      var device = '';

      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        device = '${info.manufacturer} ${info.model}, Android ${info.version.release} (SDK ${info.version.sdkInt})';
      }

      final header = [
        'MWPA app $kAppVersion ($kAppBuild)',
        'Device: $device',
        'Server: $_server',
        'User: $_username',
        'Exported: ${DateTime.now()}',
      ].join('\n');

      AppLog.i('About', 'log shared');
      final file = await AppLog.exportFile(header: header);

      if (!await UtilShare.shareFile(file.path, subject: 'MWPA app log')) {
        throw Exception('Sharing is not available on this device');
      }
    } catch (error, stack) {
      AppLog.e('About', 'share log failed', error, stack);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.logShareFailed('$error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  /// _copy - no browser plugin in the app: links are copied
  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.copiedToClipboard)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sightings = context.watch<SightingController>().sightingList;
    final unsynced = sightings
        .where((s) => s.unid == '' || s.syncStatus == Sighting.SYNC_STATUS_OPEN)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.about)),
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
              context.l10n.appTagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Center(
              child: Chip(
                avatar: const Icon(Icons.verified_outlined, size: 18),
                label: Text(context.l10n.versionLabel('$kAppVersion ($kAppBuild)')),
              ),
            ),
            const SizedBox(height: 20),

            // connection ---------------------------------------------------
            InputSection(
              title: context.l10n.aboutConnection,
              icon: Icons.cloud_outlined,
              children: [
                _InfoTile(
                  icon: Icons.dns_outlined,
                  label: context.l10n.aboutServer,
                  value: _server.isEmpty ? context.l10n.notSet : _server,
                ),
                _InfoTile(
                  icon: Icons.person_outline,
                  label: context.l10n.aboutUser,
                  value: _username.isEmpty ? context.l10n.notLoggedIn : _username,
                ),
                _InfoTile(
                  icon: Icons.api_outlined,
                  label: context.l10n.aboutSupportedApi,
                  value: 'Login ${versionApiMobileLogin.join(', ')} · '
                      'Sync ${versionApiMobileSync.join(', ')}',
                ),
              ],
            ),

            // local data ---------------------------------------------------
            InputSection(
              title: context.l10n.aboutLocalData,
              icon: Icons.storage_outlined,
              children: [
                _InfoTile(
                  icon: Icons.list_alt,
                  label: context.l10n.aboutSightings,
                  value: '${sightings.length}',
                ),
                _InfoTile(
                  icon: unsynced == 0 ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                  label: context.l10n.aboutNotSynced,
                  value: '$unsynced',
                ),
              ],
            ),

            // project ------------------------------------------------------
            InputSection(
              title: context.l10n.aboutProject,
              icon: Icons.info_outline,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(context.l10n.aboutProjectText),
                ),
                _InfoTile(
                  icon: Icons.code,
                  label: context.l10n.aboutMwpaProject,
                  value: AboutPage.projectUrl,
                  onTap: () => _copy(AboutPage.projectUrl),
                ),
                _InfoTile(
                  icon: Icons.phone_android,
                  label: context.l10n.aboutAppSource,
                  value: AboutPage.appUrl,
                  onTap: () => _copy(AboutPage.appUrl),
                ),
                _InfoTile(
                  icon: Icons.map_outlined,
                  label: context.l10n.aboutMapData,
                  value: '© OpenStreetMap contributors (ODbL)\n${AboutPage.osmCopyrightUrl}',
                  onTap: () => _copy(AboutPage.osmCopyrightUrl),
                ),
                _InfoTile(
                  icon: Icons.business_outlined,
                  label: context.l10n.aboutDevelopment,
                  value: '${AboutPage.developerName}\n${AboutPage.developerUrl}',
                  onTap: () => _copy(AboutPage.developerUrl),
                ),
              ],
            ),

            // support -------------------------------------------------------
            InputSection(
              title: context.l10n.aboutSupport,
              icon: Icons.support_agent,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Text(context.l10n.aboutSupportText),
                ),
                OutlinedButton.icon(
                  onPressed: _sharing ? null : _shareLog,
                  icon: _sharing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.share_outlined),
                  label: Text(context.l10n.shareAppLog),
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
              label: Text(context.l10n.openSourceLicenses),
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
