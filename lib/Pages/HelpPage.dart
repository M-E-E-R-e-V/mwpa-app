import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Pages/IntroPage.dart';
import 'package:mwpaapp/Ui/AppIcons.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// HelpPage - short help in sections that open on tap: colors and symbols
/// of the list, tour and home area, sync/offline, GPS/battery/screen and
/// the quick entry. The introduction can be shown again from here.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // same colors as the sightings list (ListSightingTile, GpsStatusIndicator)
  static const Color _warningColor = Color(0xffe0a200);
  static const Color _turtleColor = Color(0xff2e9e48);
  static const Color _gpsOkColor = Color(0xff4cd964);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.help)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          _Section(
            icon: Icons.palette_outlined,
            title: l10n.helpColorsTitle,
            initiallyExpanded: true,
            children: [
              _Stripe(color: scheme.error, text: l10n.helpColorRed),
              _Stripe(color: _warningColor, text: l10n.helpColorYellow),
              _Stripe(color: _turtleColor, text: l10n.helpColorGreen),
              _Stripe(color: inputAccentColor(context), text: l10n.helpColorBlue),
              const Divider(height: 24),
              _Item(icon: Icons.cloud_off_outlined, text: l10n.helpCloudOff),
              _Item(icon: Icons.cloud_upload_outlined, color: _warningColor, text: l10n.helpCloudUpload),
              _Item(icon: Icons.cloud_done_outlined, color: _turtleColor, text: l10n.helpCloudDone),
              const Divider(height: 24),
              _Item(icon: Icons.info_outline, text: l10n.helpMissingHints),
            ],
          ),
          _Section(
            icon: Icons.directions_boat_outlined,
            title: l10n.helpTourTitle,
            children: [
              _Item(icon: Icons.event_note_outlined, text: l10n.helpTourDefault),
              _Item(icon: Icons.home_outlined, text: l10n.helpTourHomeArea),
              _Item(icon: Icons.flag_outlined, text: l10n.helpTourEnd),
              _Item(icon: Icons.route_outlined, color: kButtonBackgroundColor, text: l10n.helpTourRoute),
            ],
          ),
          _Section(
            icon: Icons.sync,
            title: l10n.helpSyncTitle,
            children: [
              _Item(icon: Icons.phone_android, text: l10n.helpSyncOffline),
              _Item(icon: Icons.cloud_sync_outlined, text: l10n.helpSyncAuto),
              _Item(icon: Icons.sync, text: l10n.helpSyncManual),
              _Item(icon: Icons.map_outlined, text: l10n.helpSyncMap),
            ],
          ),
          _Section(
            icon: Icons.gps_fixed,
            title: l10n.helpGpsTitle,
            children: [
              _Item(icon: Icons.gps_fixed, color: _gpsOkColor, text: l10n.helpGpsIcon),
              _Item(icon: Icons.notifications_outlined, text: l10n.helpGpsBackground),
              _Item(icon: Icons.battery_alert_outlined, color: scheme.error, text: l10n.helpBattery),
              _Item(icon: Icons.light_mode_outlined, text: l10n.helpScreen),
            ],
          ),
          _Section(
            icon: Icons.bolt_outlined,
            title: l10n.helpQuickTitle,
            children: [
              _Item(icon: AppIcons.tortoise, color: _turtleColor, text: l10n.helpQuick),
              _Item(icon: Icons.add_location_alt_outlined, text: l10n.helpQuickEnd),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.slideshow_outlined),
              label: Text(l10n.helpShowIntro),
              onPressed: () => IntroPage.show(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// _Section - card that opens on tap
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: inputAccentColor(context)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// _Item - one help text with its symbol
class _Item extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String text;

  const _Item({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// _Stripe - status color of the list as a small bar with its meaning
class _Stripe extends StatelessWidget {
  final Color color;
  final String text;

  const _Stripe({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 22,
            margin: const EdgeInsets.only(left: 8, right: 22),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
