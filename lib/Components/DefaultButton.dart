import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

/// DefaultButton
///
/// Wrapper around [FilledButton] that keeps the long-standing call-sites in
/// the codebase (label / buttonIcon / onTab / width / height / bgColor) intact
/// but renders Material 3 ink, ripple and elevation.
class DefaultButton extends StatelessWidget {
  final String? label;
  final IconData? buttonIcon;
  final Function()? onTab;
  final double? width;
  final double? height;
  final Color? bgColor;

  const DefaultButton({
    super.key,
    this.label,
    this.buttonIcon,
    this.onTab,
    this.width,
    this.height,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final background = bgColor ?? kButtonBackgroundColor;

    final child = label == null
        ? (buttonIcon != null
            ? Icon(buttonIcon, color: kButtonFontColor, size: 20)
            : const SizedBox.shrink())
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (buttonIcon != null) ...[
                Icon(buttonIcon, color: kButtonFontColor, size: 18),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label!,
                  style: const TextStyle(
                    color: kButtonFontColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final button = FilledButton(
      onPressed: onTab,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: kButtonFontColor,
        disabledBackgroundColor: background.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: child,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: SizedBox(
        width: width ?? 140,
        height: height ?? 48,
        child: button,
      ),
    );
  }
}