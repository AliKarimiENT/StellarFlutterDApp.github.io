import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/main.dart';

import '../widgets/custom_appbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? AppTheme.darkBackgroundColor
          : Colors.white,
      appBar: CustomAppBar(context, false, null),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  RawMaterialButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    fillColor: AppTheme.primaryColor,
                    child: Padding(
                        padding:
                            EdgeInsets.only(left: 16,top: 8,right: 8,bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Edit Profile'),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(Icons.chevron_right_rounded,),
                            )
                          ],
                        )),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 65),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: EdgeInsets.only(right: 8),
                    child: SvgPicture.asset(
                      'assets/moon.svg',
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const Text('Dark Theme'),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoSwitch(
                        value: themeProvider.isDarkMode,
                        activeColor: AppTheme.green,
                        onChanged: (value) async {
                          final provider = Provider.of<ThemeProvider>(context,
                              listen: false);
                          provider.toggleTheme(value);
                          await pref.setBool('darkTheme', value);
                        },
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
