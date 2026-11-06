import 'package:flutter/material.dart';
import 'package:mwpaapp/Controllers/BatteryController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

/// LowBatteryBanner - warning below the app bar while a tour is set and the
/// battery is low and not charging (the route recording ends when the phone
/// switches off)
class LowBatteryBanner extends StatelessWidget {
  const LowBatteryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final battery = context.watch<BatteryController>();
    final hasTour = context.select<PrefController, bool>((c) => c.prefToru != null);
    final show = hasTour && battery.isLow;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: !show
          ? const SizedBox(width: double.infinity)
          : Material(
              color: scheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Icon(Icons.battery_alert, color: scheme.onTertiaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.batteryLowBanner(battery.info!.level),
                        style: TextStyle(color: scheme.onTertiaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
