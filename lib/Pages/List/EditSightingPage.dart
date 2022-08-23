import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class EditSightingPage extends StatelessWidget {
  const EditSightingPage({Key? key}) : super(key: key);

  _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryHeaderColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: kButtonFontColor,
        ),
        onPressed: () async {
          await Navigator.pushNamed(context, '/List');
        },
      ),
      actions: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Container(),
    );
  }


}
