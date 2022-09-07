import 'package:flutter/material.dart';

import '../widgets/custom_appbar.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(context,false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Settings Page')
          ],
        ),
      ),
    );
  }
}