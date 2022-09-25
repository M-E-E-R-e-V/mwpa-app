import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class DefaultButton extends StatelessWidget {
  final String? label;
  final IconData? buttonIcon;
  final Function()? onTab;
  final double? width;

  const DefaultButton({Key? key, this.label, this.buttonIcon, this.onTab, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var newWidth = 150.0;

    if (width != null) {
      newWidth = width!;
    }

    Widget? innert;

    if (label != null) {
      innert = Text(
        label!,
        style: const TextStyle(
            color: kButtonFontColor,
            fontWeight: FontWeight.bold
        ),
      );
    } else if(buttonIcon != null) {
      innert = Icon(
        buttonIcon,
        color: kButtonFontColor,
        size: 18,
      );
    }

    return GestureDetector(
      onTap: onTab,
      child: Container(
        width: newWidth,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: kButtonBackgroundColor
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            innert ?? Container()
          ],
        )
      ),
    );
  }
}
