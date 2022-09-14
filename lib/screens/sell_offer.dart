import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/enum.dart';
import 'package:stellar_flutter_dapp/main.dart';
import 'package:stellar_flutter_dapp/models/token.dart';
import 'package:stellar_flutter_dapp/screens/wallet.dart';
import 'package:stellar_flutter_dapp/widgets/custom_appbar.dart';
import 'package:stellar_flutter_sdk/src/responses/offer_response.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

import '../enum.dart';

class SellOfferPage extends StatefulWidget {
  SellOfferPage({Key? key, required this.transactionCubit, required this.offer})
      : super(key: key);
  final TransactionCubit transactionCubit;
  late OfferResponse? offer;
  @override
  State<SellOfferPage> createState() => _SellOfferPageState();
}

class _SellOfferPageState extends State<SellOfferPage> {
  late TransactionCubit _cubit;
  late List<String> items = []; // list of trusted tokens
  String? sellingAssetName;
  String? buyingAssetName;
  int sellingAmount = 0;
  int buyingAmount = 0;
  Token? sellingToken, buyingToken;
  final _formKey = GlobalKey<FormState>();
  bool offerProcessDone = false;
  OfferResponse? _offer;
  bool isPassive = false;
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
    _offer = widget.offer;
    if (widget.offer != null) {
      var sellingAsset = _offer!.selling as stl.AssetTypeCreditAlphaNum;
      var buyingAsset = _offer!.buying as stl.AssetTypeCreditAlphaNum;

      sellingAssetName = sellingAsset.mCode;
      buyingAssetName = buyingAsset.mCode;
      sellingAmount = double.tryParse(_offer!.amount!)!.toInt();
      buyingAmount = (double.tryParse(_offer!.price!)! * sellingAmount).toInt();

      if (sellingAssetName != 'XLM') {
        setToken(name: sellingAssetName!, type: AssetOfferType.selling);
      }
      if (buyingAssetName != 'XLM') {
        setToken(name: buyingAssetName!, type: AssetOfferType.buying);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(offerProcessDone);
        return true;
      },
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode
            ? AppTheme.darkBackgroundColor
            : Colors.white,
        appBar: CustomAppBar(context, true, offerProcessDone),
        body: BlocProvider(
          create: (context) => _cubit,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Form(
                      key: _formKey,
                      child:
                          BlocBuilder<TransactionCubit, TransactionCubitState>(
                        bloc: _cubit,
                        builder: (context, state) => Column(
                          // mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Manage Offer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: getColor(),
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
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: Checkbox(
                                    value: isPassive,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    activeColor: AppTheme.primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        isPassive = value!;
                                      });
                                    },
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Passive Offer'),
                                )
                              ],
                            ),
                            createOfferButton(),
                            if (state is OfferProcessFailed)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, left: 8, right: 8),
                                child: Text(
                                  'An Error Accord\n ${state.message.toString()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppTheme.red),
                                ),
                              ),
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
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            fillColor: AppTheme.primaryColor,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _cubit.manageOffer(
                  offerId: _offer != null ? _offer!.id : null,
                  type: _offer == null
                      ? OfferOperationType.create
                      : OfferOperationType.modify,
                  issuerSecretSeed: issuerSecretSeed,
                  sellerSecretSeed: keys[activeAccountId],
                  sellingAssetName: sellingAssetName!,
                  buyingAssetName: buyingAssetName!,
                  amountSelling: sellingAmount,
                  amountBuying: buyingAmount,
                  passiveOffer: isPassive,
                  memo: "ALI KARIMI",
                );
              }
            },
            child: Padding(
                padding: const EdgeInsets.all(0),
                child: BlocConsumer<TransactionCubit, TransactionCubitState>(
                    bloc: _cubit,
                    listener: (context, state) {
                      if (state is OfferProcessDone) {
                        setState(() {
                          offerProcessDone = true;
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is ProcessingOffer) {
                        return Row(
                          children: [
                            Text(
                              state.type == OfferOperationType.create
                                  ? 'Creating'
                                  : 'Modifying',
                              style: const TextStyle(
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
                      } else if (state is OfferProcessDone) {
                        return Row(
                          children: [
                            Text(
                              state.type == OfferOperationType.create
                                  ? 'Offer created'
                                  : 'Offer modified',
                              style: const TextStyle(
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
                      return Text(
                        _offer == null ? 'Create' : 'Modify',
                        style: const TextStyle(
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
          if (buyingAssetName == null) {
            return 'You need to select buying asset ';
          } else {
            if (value != "") {
              if (buyingAssetName == sellingAssetName) {
                return "Selling and buying assets should be different";
              } else {
                if (buyingAssetName != 'XLM') {
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
        controller: TextEditingController(
            text: buyingAmount != 0 ? buyingAmount.toString() : null),
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
            buyingAssetName = value;
            if (buyingAssetName != 'XLM') {
              setToken(name: value!, type: AssetOfferType.buying);
            }
          });
        },
        value: buyingAssetName,
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
        color: getColor(),
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
          if (sellingAssetName == null) {
            return 'You need to select selling asset ';
          } else {
            if (value != "") {
              if (buyingAssetName == sellingAssetName) {
                return "Selling and buying assets should be different";
              } else {
                if (sellingAssetName == "XLM") {
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
        controller: TextEditingController(
            text: sellingAmount != 0 ? sellingAmount.toString() : null),
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
            sellingAssetName = value;
            if (sellingAssetName != 'XLM') {
              setToken(name: value!, type: AssetOfferType.selling);
            }
          });
        },
        value: sellingAssetName,
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
        color: getColor(),
      ),
    );
  }

  Color getColor() {
    return themeProvider.isDarkMode
        ? Colors.white.withOpacity(0.80)
        : Colors.black.withOpacity(0.80);
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
