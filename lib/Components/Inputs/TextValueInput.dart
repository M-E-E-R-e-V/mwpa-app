import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';

/// Kind of a [TextValueInput].
enum TextValueKind {
  /// multi-line free text
  textarea,

  /// number with decimal point
  decimal,

  /// digits only
  digits,
}

/// TextValueInput - free text / number typed in (value.strValue); the
/// stored value is shown as editable text.
class TextValueInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final TextValueKind kind;
  final VoidCallback? onChange;
  final String? hint;
  final String? suffixText;

  const TextValueInput({
    super.key,
    this.title,
    required this.value,
    required this.kind,
    this.onChange,
    this.hint,
    this.suffixText,
  });

  @override
  State<TextValueInput> createState() => _TextValueInputState();
}

class _TextValueInputState extends State<TextValueInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.strValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTextarea = widget.kind == TextValueKind.textarea;

    return InputFrame(
      title: widget.title,
      child: TextField(
        controller: _controller,
        keyboardType: switch (widget.kind) {
          TextValueKind.textarea => TextInputType.multiline,
          TextValueKind.decimal => const TextInputType.numberWithOptions(decimal: true),
          TextValueKind.digits => TextInputType.number,
        },
        inputFormatters: switch (widget.kind) {
          TextValueKind.textarea => null,
          TextValueKind.decimal => [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          TextValueKind.digits => [FilteringTextInputFormatter.digitsOnly],
        },
        textInputAction: isTextarea ? TextInputAction.newline : TextInputAction.done,
        textCapitalization: isTextarea ? TextCapitalization.sentences : TextCapitalization.none,
        minLines: isTextarea ? 3 : 1,
        maxLines: isTextarea ? 8 : 1,
        decoration: InputDecoration(
          hintText: widget.hint,
          suffixText: widget.suffixText,
        ),
        onChanged: (text) {
          widget.value.strValue = text;
          widget.onChange?.call();
        },
      ),
    );
  }
}

/// DistanceInput - distance typed in nautical miles; stored in meters
/// (value.strValue), like the distance the app computes from GPS.
///
/// When the page changes the stored meters (e.g. a new begin position),
/// the shown nm value follows on the next rebuild.
class DistanceInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const DistanceInput({super.key, this.title, required this.value, this.onChange});

  @override
  State<DistanceInput> createState() => _DistanceInputState();
}

class _DistanceInputState extends State<DistanceInput> {
  late final TextEditingController _controller = TextEditingController();

  /// meters value the field text was last synced with
  String _shownMeters = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _syncText();
  }

  @override
  void didUpdateWidget(DistanceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncText();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncText() {
    if (widget.value.strValue == _shownMeters) {
      return;
    }

    _shownMeters = widget.value.strValue;
    _controller.text = UtilDistanceCoast.metersToNmText(_shownMeters);
    _error = null;
  }

  void _onChanged(String text) {
    final meters = UtilDistanceCoast.nmTextToMeters(text);

    if (meters == null) {
      setState(() => _error = 'Not a valid number');
      return;
    }

    setState(() => _error = null);
    widget.value.strValue = meters;
    _shownMeters = meters;
    widget.onChange?.call();
  }

  @override
  Widget build(BuildContext context) {
    return InputFrame(
      title: widget.title,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          suffixText: 'nm',
          errorText: _error,
        ),
        onChanged: _onChanged,
      ),
    );
  }
}
