import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Constants.dart';

/// SwitchInput - on/off (value.intValue: 1 = on, 0 = off); the [title] is
/// shown inside the tile, the whole tile toggles.
class SwitchInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const SwitchInput({super.key, this.title, required this.value, this.onChange});

  @override
  State<SwitchInput> createState() => _SwitchInputState();
}

class _SwitchInputState extends State<SwitchInput> {
  void _set(bool on) {
    setState(() => widget.value.intValue = on ? 1 : 0);
    widget.onChange?.call();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.value.intValue >= 1;
    final theme = Theme.of(context);

    return InputFrame(
      child: Material(
        color: theme.inputDecorationTheme.fillColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _set(!on),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title ?? '', style: theme.textTheme.bodyLarge),
                ),
                Switch(
                  value: on,
                  activeTrackColor: kButtonBackgroundColor,
                  onChanged: _set,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// YesNoUnknownInput - three-way choice
/// (value.intValue: -1 = unknown, 1 = yes, 0 = no).
class YesNoUnknownInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const YesNoUnknownInput({super.key, this.title, required this.value, this.onChange});

  @override
  State<YesNoUnknownInput> createState() => _YesNoUnknownInputState();
}

class _YesNoUnknownInputState extends State<YesNoUnknownInput> {
  @override
  Widget build(BuildContext context) {
    final v = widget.value.intValue;
    final selected = v <= -1 ? -1 : (v >= 1 ? 1 : 0);

    return InputFrame(
      title: widget.title,
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: kButtonBackgroundColor,
          selectedForegroundColor: kButtonFontColor,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        segments: const [
          ButtonSegment(value: -1, label: Text('Unknown')),
          ButtonSegment(value: 1, label: Text('Yes')),
          ButtonSegment(value: 0, label: Text('No')),
        ],
        selected: {selected},
        onSelectionChanged: (Set<int> s) {
          setState(() => widget.value.intValue = s.first);
          widget.onChange?.call();
        },
      ),
    );
  }
}
