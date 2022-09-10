import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

AppBar CustomAppBar(BuildContext context,bool hasLeading,bool? returnValue) {
  return AppBar(
    centerTitle: true,
    automaticallyImplyLeading: hasLeading,
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
            ),
          ),
          const Text(
            'Stellar Wallet',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    ),
    actions: [],
    backgroundColor: Colors.white,
    shadowColor: Colors.white,
    elevation: 0,
    leading: hasLeading ? IconButton(
      icon: Icon(Icons.chevron_left_rounded, size: 32),
      color: Colors.black,
      splashRadius: 32,
      iconSize: 36,
      onPressed: () {
        Navigator.of(context).pop(returnValue);
      },
    ):null,
  );
}
