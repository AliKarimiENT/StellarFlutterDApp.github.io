import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/enum.dart';
import 'package:stellar_flutter_dapp/screens/sell_offer.dart';
import 'package:stellar_flutter_dapp/screens/wallet.dart';

import '../app_theme.dart';
import '../models/fab_data.dart';
import '../widgets/custom_appbar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _key = GlobalKey<ExpandableFabState>();
  late TransactionCubit _transactionCubit;
  late List<String> categories = ['Offers', 'Transactions', 'Operations'];
  late int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _transactionCubit = TransactionCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(context, false),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56),
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
            FABData(
                title: 'Sell Offer',
                icon: Icons.sell_rounded,
                type: OfferType.sell),
            FABData(
                title: 'Buy Offer',
                icon: Icons.credit_card,
                type: OfferType.buy),
          ].map<Widget>(buildItem).toList(),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                          color: selectedIndex == index
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: AppTheme.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                            color: selectedIndex == index
                                ? Colors.white
                                : Colors.grey.shade700),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(FABData data) => FloatingActionButton.extended(
        elevation: 0,
        heroTag: data.title,
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
          if (data.type == OfferType.sell) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  SellOfferPage(transactionCubit: _transactionCubit),
            ));
            // _transactionCubit.createSellOffer(
            //     issuerSecretSeed: issuerSecretSeed,
            //     sellerSecretSeed: keys[accounts[0].accountId],
            //     sellingAssetName: 'DIGI',
            //     buyingAssetName: 'ETH',
            //     amountSelling: 10,
            //     amountBuying: 10);
          }
        },
      );
}
