import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Constants.dart';

/// SwitchInput - on/off (value.intValue: 1 = on, 0 = off).
class SwitchInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const SwitchInput({super.key, this.title, required this.value, this.onChange});

  @override
  State<SwitchInput> createState() => _SwitchInputState();
}

class _SwitchInputState extends State<SwitchInput> {
  @override
  Widget build(BuildContext context) {
    return InputFrame(
      title: widget.title,
      child: Container(
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.only(left: 14),
        alignment: Alignment.centerLeft,
        child: Switch(
          value: widget.value.intValue >= 1,
          activeTrackColor: kButtonBackgroundColor,
          thumbIcon: WidgetStateProperty.resolveWith((states) => Icon(
              states.contains(WidgetState.selected)
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked)),
          onChanged: (bool on) {
            setState(() => widget.value.intValue = on ? 1 : 0);
            widget.onChange?.call();
          },
        ),
      ),
    );
  }
}

/// YesNoUnknownInput - three-way toggle
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
  /// button order: Unknown, Yes, No
  static const _values = [-1, 1, 0];

  @override
  Widget build(BuildContext context) {
    final v = widget.value.intValue;
    final isSelected = [v <= -1, v >= 1, v == 0];

    return InputFrame(
      title: widget.title,
      child: InputBox(
        bordered: false,
        child: ToggleButtons(
          isSelected: isSelected,
          onPressed: (int index) {
            setState(() => widget.value.intValue = _values[index]);
            widget.onChange?.call();
          },
          color: inputIconColor(context),
          selectedColor: Colors.grey[700],
          selectedBorderColor: kPrimaryColor,
          fillColor: kButtonBackgroundColor,
          borderColor: kPrimaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          children: const [
            Text(' Unknown '),
            Text(' Yes '),
            Text(' No '),
          ],
        ),
      ),
    );
  }
}
