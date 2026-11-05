import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Constants.dart';

/// Kind of a [TextValueInput].
enum TextValueKind {
  /// multi-line free text
  textarea,

  /// number with decimal point
  decimal,

  /// digits only
  digits,
}

/// TextValueInput - free text / number typed in (value.strValue).
///
/// For single-line kinds the stored value is shown as hint, formatted by
/// [onFormat] if given; the textarea shows it as editable text.
class TextValueInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final TextValueKind kind;
  final VoidCallback? onChange;
  final String Function(DynInputValue value)? onFormat;

  const TextValueInput({
    super.key,
    this.title,
    required this.value,
    required this.kind,
    this.onChange,
    this.onFormat,
  });

  @override
  State<TextValueInput> createState() => _TextValueInputState();
}

class _TextValueInputState extends State<TextValueInput> {
  @override
  Widget build(BuildContext context) {
    final isTextarea = widget.kind == TextValueKind.textarea;
    final display = widget.onFormat?.call(widget.value) ?? widget.value.strValue;

    const hiddenBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 0),
    );

    final field = TextFormField(
      autofocus: false,
      cursorColor: Colors.grey[700],
      initialValue: isTextarea ? display : null,
      style: subTitleStyle(context),
      keyboardType: switch (widget.kind) {
        TextValueKind.textarea => TextInputType.multiline,
        TextValueKind.decimal ||
        TextValueKind.digits => const TextInputType.numberWithOptions(decimal: true),
      },
      inputFormatters: widget.kind == TextValueKind.digits
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
          : null,
      textInputAction: isTextarea ? TextInputAction.newline : null,
      minLines: isTextarea ? 20 : null,
      maxLines: isTextarea ? 20 : null,
      decoration: InputDecoration(
        counterText: isTextarea ? '' : null,
        hintText: display,
        hintStyle: subTitleStyle(context),
        focusedBorder: hiddenBorder,
        enabledBorder: hiddenBorder,
      ),
      onChanged: (text) {
        setState(() => widget.value.strValue = text);
        widget.onChange?.call();
      },
    );

    final box = InputBox(
      height: kInputHeight,
      child: Row(
        children: [
          Expanded(flex: 3, child: field),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );

    return InputFrame(
      title: widget.title,
      child: isTextarea ? IntrinsicHeight(child: box) : box,
    );
  }
}
