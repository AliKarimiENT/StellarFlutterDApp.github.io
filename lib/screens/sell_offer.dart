import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/enum.dart';
import 'package:stellar_flutter_dapp/models/token.dart';
import 'package:stellar_flutter_dapp/screens/wallet.dart';
import 'package:stellar_flutter_dapp/widgets/custom_appbar.dart';

import '../enum.dart';

class SellOfferPage extends StatefulWidget {
  const SellOfferPage({Key? key, required this.transactionCubit})
      : super(key: key);
  final TransactionCubit transactionCubit;
  @override
  State<SellOfferPage> createState() => _SellOfferPageState();
}

class _SellOfferPageState extends State<SellOfferPage> {
  late TransactionCubit _cubit;
  late List<String> items = []; // list of trusted tokens
  String? sellingAsset;
  String? buyingAsset;
  int sellingAmount = 0;
  int buyingAmount = 0;
  Token? sellingToken, buyingToken;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _cubit = widget.transactionCubit;
    _cubit.emit(TransactionCubitInitial());
    items.add("XLM");
    for (var token in tokens) {
      if (token.trusted) {
        items.add(token.symbol);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(context, true),
      body: BlocProvider(
        create: (context) => _cubit,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: Form(
                    key: _formKey,
                    child: BlocBuilder<TransactionCubit, TransactionCubitState>(
                      bloc: _cubit,
                      builder: (context, state) => Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Manage Sell Offer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.80),
                                ),
                              ),
                            ),
                          ),
                          sellingAssetHeader(),
                          sellingAssetDropDown(),
                          sellingAmountEntry(),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          buyingAssetHeader(),
                          buyingAssetDropDown(),
                          buyingAmountEntry(),
                          createOfferButton(),
                          if (state is CreatingOfferFailed)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16, left: 8, right: 8),
                              child: Text(
                                'An Error Accord\n ${state.message.toString()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.red),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget createOfferButton() {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.maxFinite,
          height: 45,
          margin: EdgeInsets.only(bottom: 16),
          child: RawMaterialButton(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            fillColor: AppTheme.primaryColor,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _cubit.createSellOffer(
                    issuerSecretSeed: issuerSecretSeed,
                    sellerSecretSeed: keys[activeAccountId],
                    sellingAssetName: sellingAsset!,
                    buyingAssetName: buyingAsset!,
                    amountSelling: sellingAmount,
                    amountBuying: buyingAmount);
              }
            },
            child: Padding(
                padding: EdgeInsets.all(0),
                child: BlocBuilder<TransactionCubit, TransactionCubitState>(
                    bloc: _cubit,
                    builder: (context, state) {
                      if (state is CreatingOffer) {
                        return Row(
                          children: [
                            const Text(
                              'Creating',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              width: 16,
                              height: 16,
                            )
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                        );
                      } else if (state is CreatedOffer) {
                        return Row(
                          children: [
                            const Text(
                              'Sell offer created',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 8, right: 8, bottom: 8),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              width: 16,
                              height: 16,
                            )
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                        );
                      }
                      return const Text(
                        'Create',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      );
                    })
                // child: Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text(
                //       'Get started',
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 20,
                //           fontWeight: FontWeight.w500),
                //     ),
                //                                   ],
                // ),
                ),
          ),
        ),
      ),
    );
  }

  Container buyingAmountEntry() {
    return Container(
      // height: 48,
      // width: 200,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: TextFormField(
        autocorrect: false,
        maxLines: 1,
        cursorHeight: 16,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (buyingAsset == null) {
            return 'You need to select buying asset ';
          } else {
            if (value != "") {
              if (buyingAsset == sellingAsset) {
                return "Selling and buying assets should be different";
              } else {
                if (buyingAsset != 'XLM') {
                  if (double.parse(value!) > buyingToken!.limit) {
                    return "You can't buy asset more than trusted amount";
                  }
                }
              }

              return null;
            } else {
              return 'Please enter amount';
            }
          }
        },
        autofocus: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(8)),
          labelText: 'Buying amount',
        ),
        // decoration: const InputDecoration(
        //     fillColor: Colors.white,
        //     focusColor: Colors.white,
        //     labelText: 'Selling amount'),
        onChanged: (value) {
          buyingAmount = int.parse(value);
        },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Container buyingAssetDropDown() {
    return Container(
      // width: 200,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 16),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            buyingAsset = value;
            if (buyingAsset != 'XLM') {
              setToken(name: value!, type: AssetOfferType.buying);
            }
          });
        },
        value: buyingAsset,
        hint: Text('Select Buying Asset'),
      ),
    );
  }

  Text buyingAssetHeader() {
    return Text(
      'Buying Asset',
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 14,
        color: Colors.black.withOpacity(0.80),
      ),
    );
  }

  Container sellingAmountEntry() {
    return Container(
      // height: 48,
      // width: 200,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: TextFormField(
        autocorrect: false,
        maxLines: 1,
        cursorHeight: 16, autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (sellingAsset == null) {
            return 'You need to select selling asset ';
          } else {
            if (value != "") {
              if (buyingAsset == sellingAsset) {
                return "Selling and buying assets should be different";
              } else {
                if (sellingAsset == "XLM") {
                  if (double.parse(value!) > double.parse(xlmAmount!)) {
                    return "You can't sell XLM more than your balance";
                  }
                } else {
                  if (double.parse(value!) > sellingToken!.balance) {
                    return "You can't sell more than your balance";
                  }
                }
              }

              return null;
            } else {
              return 'Please enter amount';
            }
          }
        },
        autofocus: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(8)),
          labelText: 'Selling amount',
        ),
        // decoration: const InputDecoration(
        //     fillColor: Colors.white,
        //     focusColor: Colors.white,
        //     labelText: 'Selling amount'),
        onChanged: (value) {
          sellingAmount = int.parse(value);
        },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Container sellingAssetDropDown() {
    return Container(
      // width: 200,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 16),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            sellingAsset = value;
            if (sellingAsset != 'XLM') {
              setToken(name: value!, type: AssetOfferType.selling);
            }
          });
        },
        value: sellingAsset,
        hint: Text('Select Selling Asset'),
      ),
    );
  }

  Text sellingAssetHeader() {
    return Text(
      'Selling Asset',
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 14,
        color: Colors.black.withOpacity(0.80),
      ),
    );
  }

  void setToken({required String name, required AssetOfferType type}) {
    for (var token in tokens) {
      if (token.symbol == name) {
        if (type == AssetOfferType.selling) {
          sellingToken = token;
        } else {
          buyingToken = token;
        }
      }
    }
  }
}
