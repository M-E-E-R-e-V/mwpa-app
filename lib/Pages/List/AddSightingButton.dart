import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class AddSightingButton extends StatelessWidget {
  final String label = "+ Add Sighting";
  final Function()? onTab;

  const AddSightingButton({Key? key, required this.onTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: kButtonBackgroundColor
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            label,
            style: const TextStyle(
              color: kButtonFontColor,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ),
    );
  }
}
