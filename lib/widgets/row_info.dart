import 'package:flutter/material.dart';
import 'package:stellar_flutter_dapp/main.dart';

class RowInfoItem extends StatelessWidget {
  const RowInfoItem({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.80),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
