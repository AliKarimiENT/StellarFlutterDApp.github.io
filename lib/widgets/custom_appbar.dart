import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

AppBar CustomAppBar() {
  return AppBar(
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
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
    backgroundColor: Colors.white,
    shadowColor: Colors.white,
    elevation: 0,
  );
}
