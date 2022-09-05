import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../app_theme.dart';
import '../models/fab_data.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/vertical_flow_widget.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your onPressed code here!
      //   },
      //   child: const Icon(Icons.navigation),
      // ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 56),
        child: ExpandableFab(
          key: _key,
          type: ExpandableFabType.up,
          child: const Icon(Icons.add),
          closeButtonStyle: const ExpandableFabCloseButtonStyle(
              backgroundColor: AppTheme.primaryColor),
          backgroundColor: AppTheme.primaryColor,
          distance: 56,
          overlayStyle: ExpandableFabOverlayStyle(
            // color: Colors.black.withOpacity(0.5),
            blur: 5,
          ),
          children: <FABData>[
            FABData(title: 'Sell Offer', icon: Icons.sell_rounded),
            FABData(title: 'Buy Offer', icon: Icons.credit_card),
          ].map<Widget>(buildItem).toList(),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
    );
  }

  Widget buildItem(FABData data) => FloatingActionButton.extended(
        elevation: 0,
        splashColor: Colors.grey.shade600,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.primaryColor,
        icon: Icon(
          data.icon,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          data.title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        onPressed: () {
          final state = _key.currentState;
          if (state != null) {
            state.toggle();
          }
        },
      );
}
