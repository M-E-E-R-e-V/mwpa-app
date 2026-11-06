import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:provider/provider.dart';
import 'package:mwpaapp/l10n/l10n.dart';

const Color _okColor = Color(0xff4cd964);
const Color _searchingColor = Color(0xffffc233);

/// GpsStatusIcon - app bar icon with the state of the position stream; a
/// tap explains the state.
class GpsStatusIcon extends StatelessWidget {
  const GpsStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<LocationController, GpsStatus>((c) => c.gpsStatus);

    final (icon, color, text) = switch (status) {
      GpsStatus.ok => (Icons.gps_fixed, _okColor, context.l10n.gpsOk),
      GpsStatus.searching => (
          Icons.gps_not_fixed,
          _searchingColor,
          context.l10n.gpsSearching,
        ),
      GpsStatus.off => (
          Icons.gps_off,
          Theme.of(context).colorScheme.error,
          context.l10n.gpsOff,
        ),
    };

    return IconButton(
      tooltip: context.l10n.gpsStatus,
      icon: Icon(icon, color: color),
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(text)));
      },
    );
  }
}

/// GpsOffBanner - visible hint above the content while no position stream is
/// running; empty otherwise. The stream restarts by itself once location is
/// available again.
class GpsOffBanner extends StatelessWidget {
  const GpsOffBanner({super.key});

  /// _openSettings - location settings when location is switched off,
  /// otherwise the app settings (permission)
  static Future<void> _openSettings() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select<LocationController, GpsStatus>((c) => c.gpsStatus);
    final scheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: status != GpsStatus.off
          ? const SizedBox(width: double.infinity)
          : Material(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Icon(Icons.gps_off, color: scheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.gpsOffBanner,
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                    TextButton(
                      onPressed: _openSettings,
                      style: TextButton.styleFrom(foregroundColor: scheme.onErrorContainer),
                      child: Text(context.l10n.settings),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
