
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/enum.dart';
import 'package:stellar_flutter_dapp/screens/sell_offer.dart';
import 'package:stellar_flutter_dapp/screens/wallet.dart';
import 'package:stellar_flutter_dapp/widgets/row_info.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

import '../app_theme.dart';
import '../helper.dart';
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
  late List<stl.TransactionResponse> transactions = [];
  late List<stl.OperationResponse> operations = [];
  late String deletedOfferId = '';
  @override
  void initState() {
    super.initState();
    _transactionCubit = TransactionCubit();
    _transactionCubit.getOffers(accountId: activeAccountId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: CustomAppBar(context, false, null),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56),
        child: ExpandableFab(
          key: _key,
          type: ExpandableFabType.up,
          child: const Icon(Icons.add),
          closeButtonStyle: const ExpandableFabCloseButtonStyle(
              backgroundColor: AppTheme.green),
          backgroundColor: AppTheme.green,
          distance: 56,
          overlayStyle: ExpandableFabOverlayStyle(
            // color: Colors.black.withOpacity(0.5),
            blur: 5,
          ),
          children: <FABData>[
            FABData(
                title: 'Add Offer',
                icon: Icons.sell_rounded,
                type: OfferType.sell),
          ].map<Widget>(buildItem).toList(),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      body: BlocProvider(
        create: (context) => _transactionCubit,
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
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
                        } else if (state is OfferProcessDone) {
                          if (state.type == OfferOperationType.delete) {
                            _transactionCubit.getOffers(
                                accountId: activeAccountId);
                            deleteBtnTapped = false;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "The offer with id : ($deletedOfferId) is deleted",
                                style: const TextStyle(color: Colors.white),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              backgroundColor: AppTheme.primaryColor,
                              duration: const Duration(milliseconds: 3500),
                            ));
                          }
                        } else if (state is LoadedTransactions) {
                          setState(() {
                            transactions = state.records;
                          });
                        } else if (state is LoadedOperations) {
                          setState(() {
                            operations = state.records;
                          });
                        }
                      },
                      builder: (context, state) {
                        if (selectedIndex == 0) {
                          if (state is LoadingOffers) {
                            return loadingWidget(text: 'Loading Offers');
                          } else if (state is LoadingOffersFailed) {
                            return loadingFailureWidget(
                                header:
                                    'There was a problem for loading offers',
                                message: state.message);
                          }
                          if (offers.isEmpty) {
                            return emptyListWidget(category: 'offer');
                          } else {
                            return offersList();
                          }
                        } else if (selectedIndex == 1) {
                          if (state is LoadingTransactions) {
                            return loadingWidget(text: 'Loading transactions');
                          } else if (state is LoadingOffersFailed) {
                            return loadingFailureWidget(
                                header:
                                    'There was a problem for loading transaction',
                                message: state.message);
                          }
                          if (transactions.isEmpty) {
                            return emptyListWidget(category: 'transaction');
                          } else {
                            return transactionsList();
                          }
                        } else if (selectedIndex == 2) {
                          if (state is LoadingOperations) {
                            return loadingWidget(text: 'Loading operations');
                          } else if (state is LoadingOperationsFailed) {
                            return loadingFailureWidget(
                                header:
                                    'There was a problem for loading operations',
                                message: state.message);
                          }
                          if (operations.isEmpty) {
                            return emptyListWidget(category: 'operation');
                          } else {
                            return operationList();
                          }
                        }
                        return Container();
                        // if (offers.isEmpty) {
                        // } else {
                        //   if (selectedIndex == 0) {
                        //   } else if (selectedIndex == 1) {
                        //     return Center(child: Text('Transactions'));
                        //   } else {
                        //     return Center(child: Text('Operations'));
                        //   }
                        // }
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

  Container emptyListWidget({required String category}) {
    return Container(
      child: Text(
        'No $category found',
      ),
      alignment: Alignment.center,
    );
  }

  Center loadingFailureWidget(
      {required String header, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            header,
            style: const TextStyle(color: AppTheme.red, fontSize: 16),
          ),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Center loadingWidget({required String text}) {
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
          ),
        ),
        Text(
          text,
        ),
      ],
    ));
  }

  bool deleteBtnTapped = false;

  Widget offersList() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          var offer = offers[index];
          String? sellingAssetImage, buyingAssetImage;
          late stl.AssetTypeCreditAlphaNum sellingAsset, buyingAsset;
          late String sellingAssetName, buyingAssetName;
          if (offer.selling!.type == 'native') {
            sellingAssetImage =
                'https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@1a63530be6e374711a8554f31b17e4cb92c25fa5/svg/black/xlm.svg';
            sellingAssetName = 'XLM';
          } else {
            sellingAsset = offer.selling as stl.AssetTypeCreditAlphaNum;
            sellingAssetName = sellingAsset.mCode!;
          }

          if (offer.buying!.type == 'native') {
            buyingAssetImage =
                'https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@1a63530be6e374711a8554f31b17e4cb92c25fa5/svg/black/xlm.svg';
            buyingAssetName = 'XLM';
          } else {
            buyingAsset = offer.buying as stl.AssetTypeCreditAlphaNum;

            buyingAssetName = buyingAsset.mCode!;
          }

          for (var token in tokens) {
            if (offer.selling!.type != 'native') {
              if (sellingAsset.mCode == token.symbol) {
                sellingAssetImage = token.image;
              }
            }
            if (offer.buying!.type != 'native') {
              if (buyingAsset.mCode == token.symbol) {
                buyingAssetImage = token.image;
              }
            }
          }

          DateTime _localTime = getLocalDateTime(offer.lastModifiedTime!);
          final localDateTime = _localTime.toString().substring(
                0,
                _localTime.toString().indexOf('.'),
              );
          return Stack(
            children: [
              Positioned(
                child: IconButton(
                  iconSize: 20,
                  color: Colors.grey,
                  onPressed: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => SellOfferPage(
                          transactionCubit: _transactionCubit, offer: offer),
                    ))
                        .then((value) {
                      if (value) {
                        _transactionCubit.getOffers(accountId: activeAccountId);
                      }
                    });
                  },
                  icon: const Icon(Icons.mode_edit_rounded),
                ),
                top: 8,
                left: 4,
              ),
              Positioned(
                child: IconButton(
                  iconSize: 20,
                  color: Colors.grey,
                  onPressed: () {
                    if (!deleteBtnTapped) {
                      deleteBtnTapped = true;
                      deletedOfferId = offer.id!;
                      _transactionCubit.manageOffer(
                        offerId: offer.id,
                        type: OfferOperationType.delete,
                        issuerSecretSeed: issuerSecretSeed,
                        sellerSecretSeed: keys[activeAccountId],
                        sellingAssetName: sellingAssetName,
                        buyingAssetName: buyingAssetName,
                        amountSelling: 0,
                        amountBuying: 1,
                        passiveOffer: false,
                        memo: "ALI KARIMI",
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: AppTheme.red,
                  ),
                ),
                bottom: 0,
                left: 4,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    offersAssetColumnImages(
                        sellingAssetImage, buyingAssetImage),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            RowInfoItem(
                              title: 'Offer id',
                              value: offer.id!,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 36),
                              child: Divider(),
                            ),
                            RowInfoItem(
                              title: 'Seller',
                              value: offer.seller!.accountId,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 36),
                              child: Divider(),
                            ),
                            RowInfoItem(
                              title: 'Selling',
                              value: sellingAssetName,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 36),
                              child: Divider(),
                            ),
                            RowInfoItem(
                              title: 'Amount',
                              value: offer.amount ?? '',
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 36),
                              child: Divider(),
                            ),
                            RowInfoItem(
                              title: 'Buying',
                              value: buyingAssetName,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 36),
                              child: Divider(),
                            ),
                            RowInfoItem(
                              title: 'Price',
                              value: offer.price ?? '',
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 36),
                              child: Divider(),
                            ),
                            RowInfoItem(
                              title: 'Date & Time',
                              value: localDateTime,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 36),
                              child: Divider(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        },
        itemCount: offers.length);
  }

  Widget transactionsList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        var transaction = transactions[index];
        bool successful = transaction.successful!;
        DateTime _localTime = getLocalDateTime(transaction.createdAt!);
        final localDateTime = _localTime.toString().substring(
              0,
              _localTime.toString().indexOf('.'),
            );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 16),
                      child: Icon(
                        successful
                            ? CupertinoIcons.check_mark_circled
                            : CupertinoIcons.multiply_circle,
                        color: successful ? AppTheme.green : AppTheme.red,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RowInfoItem(
                          title: 'Successful',
                          value: transaction.successful.toString(),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Divider(),
                        ),
                        RowInfoItem(
                          title: 'Hash/ID',
                          value: transaction.hash!,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Divider(),
                        ),
                        RowInfoItem(
                          title: 'Source',
                          value: transaction.sourceAccount!,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Divider(),
                        ),
                        RowInfoItem(
                          title: 'Ledger',
                          value: transaction.ledger.toString(),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Divider(),
                        ),
                        RowInfoItem(
                          title: 'Charged fee',
                          value: transaction.feeCharged.toString(),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Divider(),
                        ),
                        RowInfoItem(
                          title: 'Operation count',
                          value: transaction.operationCount.toString(),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Divider(),
                        ),
                        RowInfoItem(
                          title: 'Created at',
                          value: localDateTime,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget operationList() {
    return ListView.builder(
      itemCount: operations.length,
      itemBuilder: (context, index) {
        var operation = operations[index];
        bool successful = operation.transactionSuccessful!;
        DateTime _localTime = getLocalDateTime(operation.createdAt!);
        final localDateTime = _localTime.toString().substring(
              0,
              _localTime.toString().indexOf('.'),
            );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, right: 16),
                        child: Icon(
                          successful
                              ? CupertinoIcons.check_mark_circled
                              : CupertinoIcons.multiply_circle,
                          color: successful ? AppTheme.green : AppTheme.red,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RowInfoItem(
                            title: 'Transaction successful',
                            value: operation.transactionSuccessful.toString(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Divider(),
                          ),
                          RowInfoItem(
                            title: 'ID',
                            value: operation.id.toString(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Divider(),
                          ),
                          RowInfoItem(
                            title: 'Source',
                            value: operation.sourceAccount.toString(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Divider(),
                          ),
                          RowInfoItem(
                            title: 'Transaction hash',
                            value: operation.transactionHash.toString(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Divider(),
                          ),
                          RowInfoItem(
                            title: 'Transaction hash',
                            value: operation.transactionHash.toString(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Divider(),
                          ),
                          RowInfoItem(
                            title: 'Type',
                            value: operation.type.toString(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Divider(),
                          ),
                          RowInfoItem(
                            title: 'Created at',
                            value: localDateTime,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Divider(),
                          ),
                        ],
                      ),
                    )
                  ]),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Padding offersAssetColumnImages(
      String? sellingAssetImage, String? buyingAssetImage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SvgPicture.network(
            sellingAssetImage!,
            color: Colors.grey,
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Icon(Icons.keyboard_arrow_down_rounded),
          ),
          SvgPicture.network(
            buyingAssetImage!,
            color: Colors.grey,
            height: 30,
          ),
        ],
      ),
    );
  }

  SizedBox activityCategoriesHeader() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                } else if (selectedIndex == 1) {
                  _transactionCubit.getTransaction(accountId: activeAccountId);
                } else if (selectedIndex == 2) {
                  _transactionCubit.getOperations(accountId: activeAccountId);
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
                      : Colors.grey.shade700,
                ),
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
        onPressed: () async {
          final state = _key.currentState;
          if (state != null) {
            state.toggle();
          }
          await Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => SellOfferPage(
              transactionCubit: _transactionCubit,
              offer: null,
            ),
          ))
              .then((value) {
            if (value == true) {
              _transactionCubit.getOffers(accountId: activeAccountId);
            }
          });
        },
      );
}
