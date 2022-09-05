import 'package:flutter/material.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/models/fab_data.dart';

const double buttonSize = 36;

class VerticalFlowWidget extends StatefulWidget {
  VerticalFlowWidget({Key? key}) : super(key: key);

  @override
  State<VerticalFlowWidget> createState() => _VerticalFlowWidgetState();
}

class _VerticalFlowWidgetState extends State<VerticalFlowWidget> {
  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: FlowMenuDelegate(),
      children: <FABData>[
        FABData(title: '', icon: Icons.add),
        FABData(title: 'Sell Offer', icon: Icons.sell_rounded),
        FABData(title: 'Buy Offer', icon: Icons.credit_card),
      ].map<Widget>(buildItem).toList(),
      // children:
      //     <String>['Sell Offer', 'Buy Offer'].map<Widget>(buildItem).toList(),
    );
  }

  Widget buildItem(FABData data) => FloatingActionButton.extended(
        elevation: 0,
        splashColor: Colors.black,
        foregroundColor: AppTheme.primaryColor,
        icon: Icon(
          data.icon,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          data.title,
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
        onPressed: () {},
      );
}

class FlowMenuDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final xStart = size.width - 150;
    final yStart = size.height - 45;

    for (var i = 0; i < context.childCount; i++) {
      final childSize = context.getChildSize(i)!.width;
      final margin = 8;
      final dx = (56 + margin) * i;
      final x = xStart;
      final y = yStart - dx - 50;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(x, y, 0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return false;
  }
}
