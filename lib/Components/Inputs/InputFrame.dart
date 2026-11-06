import 'package:flutter/material.dart';
import 'package:mwpaapp/Ui/Themes.dart';

/// InputFrame - common layout of every form input: optional [title] above
/// the input [child], with the standard spacing to the previous input.
class InputFrame extends StatelessWidget {
  final String? title;
  final Widget child;

  const InputFrame({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(title!, style: inputLabelStyle(context)),
            ),
          child,
        ],
      ),
    );
  }
}

/// InputSection - titled card that groups related inputs of a form;
/// [description] is an optional info text below the title.
class InputSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? description;
  final List<Widget> children;

  const InputSection({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final accent = inputAccentColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: accent),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                ),
              ],
            ),
            if (description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// TapField - read-only field that shows [text] (or [hint]) and calls
/// [onTap] when tapped anywhere; used by the picker inputs. Without [onTap]
/// the field is disabled (greyed out).
class TapField extends StatelessWidget {
  final String text;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;

  const TapField({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.hint = '',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final disabledColor = scheme.onSurface.withValues(alpha: 0.38);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          enabled: enabled,
          suffixIcon: Icon(icon, color: enabled ? inputAccentColor(context) : disabledColor),
        ),
        isEmpty: text.isEmpty,
        child: Text(
          text.isEmpty ? hint : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: !enabled
                    ? disabledColor
                    : text.isEmpty
                        ? scheme.onSurfaceVariant
                        : null,
              ),
        ),
      ),
    );
  }
}

/// inputAccentColor - color of section headers and field icons; the brand
/// blue is too dark on the dark background.
Color inputAccentColor(BuildContext context) {
  final theme = Theme.of(context);

  return theme.brightness == Brightness.dark
      ? Themes.darkAccent
      : theme.colorScheme.primary;
}

/// inputLabelStyle - style of the title above an input.
TextStyle? inputLabelStyle(BuildContext context) {
  final theme = Theme.of(context);

  return theme.textTheme.labelLarge?.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: theme.colorScheme.onSurfaceVariant,
  );
}
