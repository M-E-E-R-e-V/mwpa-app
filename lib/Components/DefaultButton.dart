import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class DefaultButton extends StatelessWidget {
  final String? label;
  final IconData? buttonIcon;
  final Function()? onTab;
  final double? width;
  final double? height;
  final Color? bgColor;

  const DefaultButton({Key? key, this.label, this.buttonIcon, this.onTab, this.width, this.height, this.bgColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var newWidth = 150.0;
    var newHeight = 60.0;
    var newBgColor = kButtonBackgroundColor;

    if (width != null) {
      newWidth = width!;
    }

    if (height != null) {
      newHeight = height!;
    }

    if (bgColor != null) {
      newBgColor = bgColor!;
    }

    List<Widget> inner = [];

    if(buttonIcon != null) {
      inner.add(Icon(
        buttonIcon,
        color: kButtonFontColor,
        size: 18,
      ));
    }

    if (label != null) {
      inner.add(Text(
        label!,
        style: const TextStyle(
            color: kButtonFontColor,
            fontWeight: FontWeight.bold
        ),
      ));
    }

    return GestureDetector(
      onTap: onTab,
      child: Container(
        width: newWidth,
        height: newHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: newBgColor
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: inner,
            )
          ],
        )
      ),
    );
  }
}
