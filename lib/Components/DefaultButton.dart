import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class DefaultButton extends StatelessWidget {
  final String label;
  final Function()? onTab;
  final double? width;

  const DefaultButton({Key? key, required this.label, this.onTab, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var newWidth = 150.0;

    if (width != null) {
      newWidth = width!;
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
            Text(
              label,
              style: const TextStyle(
                  color: kButtonFontColor,
                  fontWeight: FontWeight.bold
              ),
            )
          ],
        )
      ),
    );
  }
}
