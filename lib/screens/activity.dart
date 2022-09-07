import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit.dart';
import 'package:stellar_flutter_dapp/enum.dart';
import 'package:stellar_flutter_dapp/screens/sell_offer.dart';
import 'package:stellar_flutter_dapp/screens/wallet.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

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
  late List<stl.OfferResponse> offers = [];

  @override
  void initState() {
    super.initState();
    _transactionCubit = TransactionCubit();
    _transactionCubit.getOffers(accountId: activeAccountId);
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
      body: BlocProvider(
        create: (context) => _transactionCubit,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: Column(
                children: [
                  activityCategoriesHeader(),
                  Expanded(
                    child: BlocConsumer(
                      bloc: _transactionCubit,
                      listener: (context, state) {
                        if (state is LoadedOffers) {
                          setState(() {
                            offers = state.records;
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is LoadingOffers) {
                          return Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                width: 24,
                                height: 24,
                                child: const CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const Text(
                                'Loading Offers',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ));
                        } else if (state is LoadingOffersFailed) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'There was a problem for loading offers',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                                Text(
                                  state.message,
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }
                        if (offers.isEmpty) {
                          return Container(
                            child: const Text('No offer found',
                                style: TextStyle(color: Colors.black)),
                            alignment: Alignment.center,
                          );
                        } else {
                          return Container(
                            child: const Text('Ali Karimi',
                                style: TextStyle(color: Colors.black)),
                            alignment: Alignment.center,
                          );
                        }
                      },
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

  SizedBox activityCategoriesHeader() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (index != selectedIndex) {
                setState(() {
                  selectedIndex = index;
                });
                if (selectedIndex == 0) {
                  _transactionCubit.getOffers(accountId: activeAccountId);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 8),
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
