import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/main.dart';

AppBar CustomAppBar(BuildContext context, bool hasLeading, bool? returnValue) {
  return AppBar(
    centerTitle: true,
    automaticallyImplyLeading: hasLeading,
    backgroundColor:
        themeProvider.isDarkMode ? AppTheme.darkBackgroundColor : Colors.white,
    title: Padding(
      padding: hasLeading ? EdgeInsets.only(right: 56) : EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: SvgPicture.asset(
              'assets/stellarLogo.svg',
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            'Stellar Wallet',
            style: TextStyle(color: themeProvider.isDarkMode
            ? Colors.white
            : Colors.black),
          ),
        ],
      ),
    ),
    actions: [],
    // backgroundColor: Colors.white,
    // shadowColor: Colors.white,
    elevation: 0,
    leading: hasLeading
        ? IconButton(
            icon: Icon(Icons.chevron_left_rounded, size: 32),
            // color: Colors.black,
            splashRadius: 32,
            iconSize: 36,
            onPressed: () {
              Navigator.of(context).pop(returnValue);
            },
          )
        : null,
  );
}
