import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

/// Height of a single-line input box.
const double kInputHeight = 52.0;

/// InputFrame - common layout of every form input: optional [title] above
/// the input [child], with the standard spacing to the previous input.
class InputFrame extends StatelessWidget {
  final String? title;
  final Widget child;

  const InputFrame({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(title!, style: titleStyle(context)),
          child,
        ],
      ),
    );
  }
}

/// InputBox - the rounded, bordered box around an input.
class InputBox extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? minHeight;
  final EdgeInsetsGeometry padding;
  final bool bordered;

  const InputBox({
    super.key,
    required this.child,
    this.height,
    this.minHeight,
    this.padding = const EdgeInsets.only(left: 14),
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
      margin: const EdgeInsets.only(top: 8.0),
      padding: padding,
      decoration: bordered
          ? BoxDecoration(
              border: Border.all(color: kPrimaryColor, width: 1.0),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: child,
    );
  }
}

/// ValueBox - single-line box that shows a value [text] with an optional
/// [trailing] action (picker button, dropdown, ...).
class ValueBox extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const ValueBox({super.key, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InputBox(
      height: kInputHeight,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              text,
              style: subTitleStyle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: trailing == null
                ? const SizedBox.shrink()
                : Align(alignment: Alignment.topRight, child: trailing),
          ),
        ],
      ),
    );
  }
}

/// inputIconColor - color of the action icons inside an input box.
Color inputIconColor(BuildContext context) =>
    isDarkMode(context) ? kPrimaryDarkFontColor : kPrimaryFontColor;
