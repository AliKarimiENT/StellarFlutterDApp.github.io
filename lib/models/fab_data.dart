import 'package:flutter/cupertino.dart';

import '../enum.dart';

class FABData {
  // floating action button data model
  String title;
  IconData icon;
  OfferType type;
  FABData({
    required this.title,
    required this.icon,
    required this.type,
  });
}
