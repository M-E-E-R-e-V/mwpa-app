import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:provider/provider.dart';

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
      GpsStatus.ok => (Icons.gps_fixed, _okColor, 'GPS is running, the route is recorded.'),
      GpsStatus.searching => (
          Icons.gps_not_fixed,
          _searchingColor,
          'GPS is running, but there is no current position fix (e.g. indoors).',
        ),
      GpsStatus.off => (
          Icons.gps_off,
          Theme.of(context).colorScheme.error,
          'GPS is off: no position and no route recording.',
        ),
    };

    return IconButton(
      tooltip: 'GPS status',
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
                        'GPS is off - no position, the route is not recorded.',
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                    TextButton(
                      onPressed: _openSettings,
                      style: TextButton.styleFrom(foregroundColor: scheme.onErrorContainer),
                      child: const Text('Settings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
