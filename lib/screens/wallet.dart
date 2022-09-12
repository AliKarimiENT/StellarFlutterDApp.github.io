import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/enum.dart';
import 'package:stellar_flutter_dapp/main.dart';
import 'package:stellar_flutter_dapp/models/account.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

import '../blocs/info/info_cubit.dart';
import '../models/token.dart';
import '../widgets/row_info.dart';

late String activeAccountId;
late List<Account> accounts = [];
late InfoCubit _infoCubit;
late TransactionCubit _transactionCubit;
late List<Token> tokens;
late TabController controller;
late int trustedTokens = 0;
late Map<String, dynamic> keys;
String? xlmAmount;
late Map<String, dynamic> images;

class WalletPage extends StatefulWidget {
  const WalletPage(this.accountId, {Key? key}) : super(key: key);
  final String accountId;
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic>
      funds; // a mapping for accountId and true/false which shows that an account is funded or not
  late String accountId2;

  double buyAssetAmount = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    activeAccountId = widget.accountId;

    loadFunds();

    _infoCubit = InfoCubit();
    _transactionCubit = TransactionCubit();
    loadAccountInfo();
    loadKeys();

    tokens = [
      Token(
        symbol: 'DIGI',
        image:
            'https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@1a63530be6e374711a8554f31b17e4cb92c25fa5/svg/black/dgb.svg',
        name: 'DigiByte',
        issuerName: 'Ali Karimi',
        issuerAccountId: issuerAccountId,
        value: 1,
        balance: 0,
        limit: 0,
        trusted: false,
      ),
      Token(
        symbol: 'ETH',
        image:
            'https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@1a63530be6e374711a8554f31b17e4cb92c25fa5/svg/black/eth.svg',
        name: 'Ethereum',
        issuerName: 'Ali Karimi',
        issuerAccountId: issuerAccountId,
        value: 1,
        balance: 0,
        limit: 0,
        trusted: false,
      ),
      Token(
        symbol: 'EUR',
        image:
            'https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@1a63530be6e374711a8554f31b17e4cb92c25fa5/svg/black/eur.svg',
        name: 'Euro',
        issuerName: 'Ali Karimi',
        issuerAccountId: issuerAccountId,
        value: 1,
        balance: 0,
        limit: 0,
        trusted: false,
      ),
      Token(
        symbol: 'GOLD',
        image:
            'https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@1a63530be6e374711a8554f31b17e4cb92c25fa5/svg/black/gold.svg',
        name: 'Dragonereum Gold',
        issuerName: 'Ali Karimi',
        issuerAccountId: issuerAccountId,
        value: 1,
        balance: 0,
        limit: 0,
        trusted: false,
      ),
    ];
  }

  Future<void> loadFunds() async {
    String encodedFunds = pref.getString('funds')!;
    funds = json.decode(encodedFunds);
    //      var secretSeed = keys[senderId];
  }

  Future<void> loadKeys() async {
    String encodedKeys = pref.getString('keys')!;
    keys = json.decode(encodedKeys);
    accountId2 = keys.keys.toList()[1];

    images = {
      keys.keys.toList()[0]:
          'https://img.seadn.io/files/7a485f43de73d372b34ef909e8e60aa7.png?fit=max&w=600',
      keys.keys.toList()[1]:
          'https://www.artnews.com/wp-content/uploads/2022/01/unnamed-2.png?w=631'
    };
  }

  Future<void> loadAccountInfo() async {
    var funded = funds[activeAccountId];
    if (funded == false) {
      _infoCubit.fundAccount(widget.accountId);
    } else {
      _infoCubit.getBasicAccountInfo(pref.getString('accountId')!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode
            ? AppTheme.darkBackgroundColor
            : Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                'assets/svgs/stellarLogo.svg',
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              'Stellar Wallet',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        // backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        leading: Icon(
          Icons.menu_rounded,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
        actions: [
          Container(
            width: 56,
          )
        ],
      ),
      body: BlocProvider(
        create: (context) => _infoCubit,
        child: BlocConsumer<InfoCubit, InfoState>(
          bloc: _infoCubit,
          listener: (context, state) {
            if (state is FundAccountDone) {
              if (state.result) {
                _infoCubit.getBasicAccountInfo(activeAccountId);
                funds[activeAccountId] = true;
              }
            }
            // else if (state is AccountInfoLoaded) {
            //   var keysList = keys.keys.toList();
            //   var index = keysList.indexOf(activeAccountId);
            //   _infoCubit.setUserProfileImage(
            //     images.values.toList()[index],
            //     activeAccountId,
            //     keys[activeAccountId],
            //   );
            // }
          },
          builder: (context, state) {
            if (state is FundAccountLoading) {
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
                      'Funding your account on Stellar TestNet',
                    ),
                  ],
                ),
              );
            } else if (state is FundAccountFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Unfortunately there was a problem',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    Text(
                      state.message,
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 12),
                    ),
                  ],
                ),
              );
            } else if (state is FundAccountDone) {
              if (!state.result) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "We couldn't fund your account\n tap to retry",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      IconButton(
                          onPressed: () =>
                              _infoCubit.fundAccount(widget.accountId),
                          icon: const Icon(Icons.replay))
                    ],
                  ),
                );
              }
            } else if (state is AccountInfoLoaded) {
              var newAccount = Account(
                  imageUrl: images[activeAccountId],
                  accountId: state.account.accountId,
                  index: accounts.length + 1);
              bool exist = false;
              for (var account in accounts) {
                if (account.accountId == state.account.accountId) {
                  exist = true;
                  newAccount = account;
                  break;
                }
              }

              if (!exist) {
                for (var token in tokens) {
                  token.trusted = false;
                  token.balance = 0;
                  token.limit = 0;
                }
                accounts.add(newAccount);
              }

              for (stl.Balance? balance in state.account.balances!) {
                if (balance!.assetType != stl.Asset.TYPE_NATIVE) {
                  for (var token in tokens) {
                    if (token.symbol == balance.assetCode) {
                      token.trusted = true;
                      trustedTokens++;
                      token.limit = double.tryParse(balance.limit!)!.toInt();
                      token.balance = double.parse(balance.balance!).toInt();
                    }
                  }
                } else {
                  xlmAmount = balance.balance;
                }
              }

              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate:
                        sliverAccountInfoHeader(xlmAmount, newAccount, context),
                  ),
                  SliverPersistentHeader(
                    delegate: SectionHeaderDelegate("Section B"),
                    pinned: true,
                    floating: true,
                  ),
                  SliverPersistentHeader(
                    delegate: AssetsHeaderDelegate(50),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          physics: const PageScrollPhysics(),
                          itemBuilder: (context, index) {
                            var token = tokens[index];
                            return Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.network(token.image,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white60
                                                  : Colors.grey,
                                              height: 36),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4),
                                                    child: Text(
                                                      token.symbol,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.8)
                                                            : Colors.black
                                                                .withOpacity(
                                                                    0.80),
                                                      ),
                                                    ),
                                                  ),
                                                  token.balance != 0
                                                      ? RowInfoItem(
                                                          title: 'Balance',
                                                          value: token.balance
                                                              .toString())
                                                      : Container(),
                                                  token.limit != 0
                                                      ? RowInfoItem(
                                                          title: 'Trusted',
                                                          value: token.limit
                                                              .toString())
                                                      : Container(),
                                                  RowInfoItem(
                                                      title: 'Value',
                                                      value:
                                                          '${token.value} XLM'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          token.trusted == false
                                              ? Container(
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 0),
                                                  child: IconButton(
                                                    color:
                                                        AppTheme.primaryColor,
                                                    onPressed: () {
                                                      showTrustBottomSheet(
                                                          context, token);
                                                      _transactionCubit
                                                          .initTrust();
                                                    },
                                                    icon: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    splashRadius: 32,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                )
                                              : Container(
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 0),
                                                  child: IconButton(
                                                    color:
                                                        AppTheme.primaryColor,
                                                    onPressed: () {
                                                      _transactionCubit.emit(
                                                          TransactionCubitInitial());
                                                      showTokenOperationsDialog(
                                                          context, token);
                                                    },
                                                    icon: const Icon(
                                                      Icons.more_vert_rounded,
                                                      color: Colors.black,
                                                      size: 24,
                                                    ),
                                                    splashRadius: 32,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade400,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? AppTheme
                                                                .darkBackgroundColor
                                                            : Colors.white30,
                                                        spreadRadius: 2,
                                                        blurRadius: 5,
                                                        offset: Offset(0,
                                                            0), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24),
                                        child: Divider(
                                          color: Colors.black45,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  "Token name:",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  token.name,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  "Issuer account ID:",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text: token
                                                              .issuerAccountId
                                                              .substring(0, 5),
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade500,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '...',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade500,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: token
                                                              .issuerAccountId
                                                              .substring(
                                                                  widget.accountId
                                                                          .length -
                                                                      5,
                                                                  widget
                                                                      .accountId
                                                                      .length),
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade500,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          },
                          itemCount: tokens.length,
                        ),
                        const Center(child: Text('Not found')),
                      ],
                      controller: controller,
                    ),
                  )
                ],
              );
            } else if (state is AccountInfoFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'There was a problem for loading account info',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }
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
                    'Loading Account Info',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<dynamic> showTokenOperationsDialog(BuildContext context, Token token) {
    return showDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierDismissible: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1,
                )),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, top: 16, right: 24, bottom: 8),
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        token.symbol,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor),
                      ),
                      RawMaterialButton(
                        onPressed: () {
                          _transactionCubit.initTrust();
                          showTrustBottomSheet(context, token);
                        },
                        elevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        // fillColor:
                        //     Colors.transparent,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            side: BorderSide(
                                color: AppTheme.primaryColor, width: 2)),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Text('Change Trust',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              )),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      thickness: 1,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      dialogMenuItem(
                          title: 'Buy',
                          icon: Icons.credit_card_rounded,
                          onTapped: () {
                            _transactionCubit.emit(TransactionCubitInitial());
                            showBuyAssetBottomSheet(context, token);
                          }),
                      dialogMenuItem(
                          title: 'Send',
                          icon: Icons.send,
                          onTapped: () {
                            _transactionCubit.emit(TransactionCubitInitial());
                            showSendAssetBottomSheet(context, token);
                          }),
                      dialogMenuItem(
                          title: 'Sell',
                          icon: Icons.sell_rounded,
                          onTapped: () {}),
                      dialogMenuItem(
                          title: 'More info',
                          icon: Icons.info,
                          onTapped: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget dialogMenuItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTapped}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: onTapped,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
            ),
          )
        ],
      ),
    );
  }

  int trustAmount = 0;
  final _trustFormKey = GlobalKey<FormState>();

  Future<dynamic> showTrustBottomSheet(BuildContext context, Token token) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: MediaQuery.of(context).viewInsets,
              decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  border: Border.all(color: AppTheme.primaryColor)),
              child: Form(
                key: _trustFormKey,
                child: BlocConsumer<TransactionCubit, TransactionCubitState>(
                  bloc: _transactionCubit,
                  listener: (context, state) {
                    if (state is TrustingTokenDone) {
                      _infoCubit.getBasicAccountInfo(activeAccountId);
                      if (state.trusted) {
                        setState(() {
                          token.trusted = true;
                          token.limit = state.limit;
                          trustedTokens++;
                        });
                      } else {
                        setState(() {
                          token.trusted = false;
                          token.limit = state.limit;
                          trustedTokens--;
                        });
                      }
                    }
                  },
                  builder: (context, state) => Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                            'Enter amount of ${token.symbol} token want to trust'),
                      ),
                      Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          autocorrect: false,
                          validator: (value) {
                            if (value != "") {
                              if (double.parse(value!) > 500) {
                                return 'Amount of trusted token must be less than 500';
                              }
                              return null;
                            } else {
                              return 'Please enter amount';
                            }
                          },
                          autofocus: true,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              hintText:
                                  'To delete trust, set the trust limit to 0'),
                          onChanged: (value) {
                            trustAmount = int.parse(value);
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 8, bottom: 16),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: RawMaterialButton(
                            onPressed: () {
                              if (_trustFormKey.currentState!.validate()) {
                                late ChangeTrustType type;
                                if (trustAmount == 0) {
                                  type = ChangeTrustType.delete;
                                } else if (token.limit == 0) {
                                  type = ChangeTrustType.create;
                                } else if (trustAmount != token.limit) {
                                  type = ChangeTrustType.modify;
                                }
                                _transactionCubit.createTrustline(
                                  issuerSecretSeed: issuerSecretSeed,
                                  trusterSecretSeed: keys[activeAccountId],
                                  tokenName: token.symbol,
                                  trustLimit: trustAmount.toString(),
                                  type: type,
                                );
                              }
                            },
                            elevation: 0,
                            fillColor: AppTheme.primaryColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: BlocBuilder<TransactionCubit,
                                  TransactionCubitState>(
                                bloc: _transactionCubit,
                                builder: (context, state) {
                                  if (state is ChangingTokenTrust) {
                                    late String buttonText;
                                    switch (state.type) {
                                      case ChangeTrustType.create:
                                        buttonText = 'Trusting token';
                                        break;
                                      case ChangeTrustType.modify:
                                        buttonText = "Token's trust modifying";
                                        break;
                                      case ChangeTrustType.delete:
                                        buttonText = "Token's trust deleting";
                                        break;
                                    }
                                    return Row(
                                      children: [
                                        Text(
                                          buttonText,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child:
                                              const CircularProgressIndicator(),
                                          width: 16,
                                          height: 16,
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    );
                                  } else if (state is TrustingTokenDone) {
                                    late String buttonText;
                                    switch (state.type) {
                                      case ChangeTrustType.create:
                                        buttonText = 'Token trusted';
                                        break;
                                      case ChangeTrustType.modify:
                                        buttonText = "Token's trust modified";
                                        break;
                                      case ChangeTrustType.delete:
                                        buttonText = "Token's trust deleted";
                                        break;
                                    }
                                    return Row(
                                      children: [
                                        Text(
                                          buttonText,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    );
                                  }
                                  return const Text(
                                    'Trust',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (state is TrustingTokenFailed)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${state.message.toString()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.red)),
                        )
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  SliverChildListDelegate sliverAccountInfoHeader(
      xlmAmount, Account account, BuildContext context) {
    return SliverChildListDelegate(
      [
        GestureDetector(
          onTap: () {
            accountSwitchBottomSheet(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.green,
                ),
              ),
              Text(
                'Stellar Test Network',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade600,
              )
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(top: 24, bottom: 0),
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor,
          ),
          child: CircleAvatar(
            foregroundColor: Colors.white,
            radius: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                account.imageUrl,
              ),
            ),
          ),
        ),
        Text(
          'Account ${account.index}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'XLM $xlmAmount ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(25))),
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: account.accountId.substring(0, 5),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: '...',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: account.accountId.substring(
                          widget.accountId.length - 5, widget.accountId.length),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: account.accountId));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Account id copied to your clipboard'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  backgroundColor: AppTheme.primaryColor,
                  duration: const Duration(milliseconds: 500),
                ));
              },
              splashRadius: 24,
              icon: const Icon(
                Icons.copy_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<dynamic> accountSwitchBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        var account1length = widget.accountId.length;
        return Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  border: Border.all(color: AppTheme.primaryColor)),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      activeAccountId = widget.accountId;
                      setState(() {
                        _infoCubit.getBasicAccountInfo(activeAccountId);
                      });
                      Navigator.of(context).pop();
                    },
                    title: Text(
                      'Account 1: ${widget.accountId.toString().substring(0, 8)}...${widget.accountId.toString().substring(account1length - 8, account1length)}',
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeAccountId == widget.accountId
                            ? AppTheme.primaryColor
                            : Colors.grey.shade400,
                      ),
                      child: CircleAvatar(
                        foregroundColor: Colors.white,
                        radius: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            images.values.toList()[0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        activeAccountId = accountId2;
                        if (funds[accountId2]) {
                          _infoCubit.getBasicAccountInfo(accountId2);
                        } else {
                          _infoCubit.fundAccount(accountId2);
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    title: Text(
                      'Account 2: ${accountId2.toString().substring(0, 8)}...${accountId2.toString().substring(accountId2.length - 8, accountId2.length)}',
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeAccountId == accountId2
                            ? AppTheme.primaryColor
                            : Colors.grey.shade400,
                      ),
                      child: CircleAvatar(
                        foregroundColor: Colors.white,
                        radius: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            images.values.toList()[1],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future<dynamic> showBuyAssetBottomSheet(BuildContext context, Token token) {
    final _buyAssetFormKey = GlobalKey<FormState>();

    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: MediaQuery.of(context).viewInsets,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: Form(
                key: _buyAssetFormKey,
                child: BlocConsumer<TransactionCubit, TransactionCubitState>(
                  bloc: _transactionCubit,
                  listener: (context, state) {
                    if (state is TransactionPaymentSent) {
                      _infoCubit.getBasicAccountInfo(activeAccountId);
                    }
                  },
                  builder: (context, state) => Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                            'Enter amount of ${token.symbol} token want to buy'),
                      ),
                      Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          autocorrect: false,
                          validator: (value) {
                            if (value != "") {
                              if (double.parse(value!) > 500) {
                                return 'Amount of token to buy must be less than 500';
                              }
                              return null;
                            } else {
                              return 'Please enter amount';
                            }
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                            fillColor: themeProvider.isDarkMode
                                ? Colors.black
                                : Colors.white,
                            focusColor: themeProvider.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                          onChanged: (value) {
                            buyAssetAmount = double.parse(value);
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 8, bottom: 16),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: RawMaterialButton(
                            onPressed: () {
                              _transactionCubit.sendNonNativePayment(
                                issuerSecretSeed: issuerSecretSeed,
                                senderSecretSeed: discontrollerSecretSeed,
                                trusterSecretSeed: keys[activeAccountId],
                                tokenName: token.symbol,
                                amount: buyAssetAmount.toString(),
                                type: TransactionPaymentType.buy,
                              );
                            },
                            elevation: 0,
                            fillColor: AppTheme.primaryColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: BlocBuilder<TransactionCubit,
                                  TransactionCubitState>(
                                bloc: _transactionCubit,
                                builder: (context, state) {
                                  if (state is TransactionPaymentSending) {
                                    return Row(
                                      children: [
                                        const Text(
                                          'Sending request',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child:
                                              const CircularProgressIndicator(),
                                          width: 16,
                                          height: 16,
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    );
                                  } else if (state is TransactionPaymentSent) {
                                    return Row(
                                      children: [
                                        const Text(
                                          'The token has been purchased',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    );
                                  }
                                  return const Text(
                                    'Buy',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (state is TransactionPaymentFailed)
                        Text('An Error Accord\n ${state.message.toString()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.red))
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Future<dynamic> showSendAssetBottomSheet(BuildContext context, Token token) {
    final _sendAssetFormKey = GlobalKey<FormState>();
    late String senderSecretSeed, trusterSecretSeed;
    for (var account in accounts) {
      if (account.accountId == activeAccountId) {
        senderSecretSeed = keys[account.accountId];
      } else {
        trusterSecretSeed = keys[account.accountId];
      }
    }
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: MediaQuery.of(context).viewInsets,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                border: Border.all(color: AppTheme.primaryColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Form(
                key: _sendAssetFormKey,
                child: BlocConsumer<TransactionCubit, TransactionCubitState>(
                  bloc: _transactionCubit,
                  listener: (context, state) {
                    if (state is TransactionPaymentSent) {
                      _infoCubit.getBasicAccountInfo(activeAccountId);
                    }
                  },
                  builder: (context, state) => Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                            'Enter amount of ${token.symbol} token want to send'),
                      ),
                      Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          autocorrect: false,
                          validator: (value) {
                            if (value != "") {
                              if (double.parse(value!) > token.balance) {
                                return 'Amount of token to send must be less than your balance';
                              }
                              return null;
                            } else {
                              return 'Please enter amount';
                            }
                          },
                          autofocus: true,
                          decoration: const InputDecoration(
                              // fillColor: Colors.white,
                              // focusColor: Colors.white,
                              ),
                          onChanged: (value) {
                            buyAssetAmount = double.parse(value);
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 8, bottom: 16),
                        child: SizedBox(
                          width: double
                              .maxFinite, // check token is trusted by other one or not
                          child: RawMaterialButton(
                            onPressed: () {
                              if (_sendAssetFormKey.currentState!.validate()) {
                                _transactionCubit.sendNonNativePayment(
                                    issuerSecretSeed: issuerSecretSeed,
                                    senderSecretSeed: senderSecretSeed,
                                    trusterSecretSeed: trusterSecretSeed,
                                    tokenName: token.symbol,
                                    amount: buyAssetAmount.toString(),
                                    type: TransactionPaymentType.send);
                              }
                            },
                            elevation: 0,
                            fillColor: AppTheme.primaryColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: BlocBuilder<TransactionCubit,
                                  TransactionCubitState>(
                                bloc: _transactionCubit,
                                builder: (context, state) {
                                  if (state is TransactionPaymentSending) {
                                    return Row(
                                      children: [
                                        const Text(
                                          'Sending token',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child:
                                              const CircularProgressIndicator(),
                                          width: 16,
                                          height: 16,
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    );
                                  } else if (state is TransactionPaymentSent) {
                                    return Row(
                                      children: [
                                        const Text(
                                          'The token has been sent',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    );
                                  }
                                  return const Text(
                                    'Send',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (state is TransactionPaymentFailed)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'An Error Accord\n ${state.message.toString()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.red)),
                        )
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class AssetsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  AssetsHeaderDelegate(this.height);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return TabBar(
      labelPadding: const EdgeInsets.symmetric(vertical: 8),
      tabs: const [
        Tab(
          text: 'TOKENS',
        ),
        Tab(
          text: 'NFTs',
        )
      ],
      controller: controller,
      indicatorColor: AppTheme.primaryColor,
      unselectedLabelColor: Colors.grey,
      labelColor: AppTheme.primaryColor,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double height;

  SectionHeaderDelegate(this.title, [this.height = 82]);

  double amount = 0;
  double buyAssetAmount = 0;

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return BlocProvider(
      create: (context) => _transactionCubit,
      child: Container(
        color: themeProvider.isDarkMode
            ? AppTheme.darkBackgroundColor
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                  child: IconButton(
                    splashRadius: 8,
                    icon: const Icon(Icons.credit_card_rounded),
                    onPressed: () {
                      if (trustedTokens == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('No token has been trusted'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(milliseconds: 800),
                        ));
                      } else {
                        _transactionCubit.emit(TransactionCubitInitial());
                        showBuyAssetBottomSheet(context);
                      }
                    },
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Buy',
                  style: TextStyle(color: AppTheme.primaryColor),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                  child: IconButton(
                    splashRadius: 8,
                    icon: const Icon(Icons.download),
                    onPressed: () {},
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Receive',
                  style: TextStyle(color: AppTheme.primaryColor),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                  child: IconButton(
                    splashRadius: 8,

                    // iconSize: 16,
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      Account? sender, receiver;
                      for (Account account in accounts) {
                        if (account.accountId == activeAccountId) {
                          sender = account;
                        } else {
                          receiver = account;
                        }
                      }
                      if (receiver == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              'The reciever account is not funded\nTry to change account and it will be funded'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(milliseconds: 1250),
                        ));
                      } else {
                        sendAmountModalBottomSheet(context, sender!, receiver);
                      }
                    },
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Send',
                  style: TextStyle(color: AppTheme.primaryColor),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                  child: IconButton(
                    splashRadius: 8,
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () {},
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Swap',
                  style: const TextStyle(color: AppTheme.primaryColor),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> sendAmountModalBottomSheet(
      BuildContext context, Account sender, Account receiver) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Wrap(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: MediaQuery.of(context).viewInsets,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: BlocBuilder<TransactionCubit, TransactionCubitState>(
              bloc: _transactionCubit,
              builder: (context, state) {
                if (state is TransactionPaymentSent) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        child: Text(
                          'Confirm send info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      confirmationRowItem(
                          title: 'Sender:',
                          value: state.transaction.sourceAccount!.accountId
                              .toString()),
                      confirmationRowItem(
                          title: 'Recipient:', value: state.receiver),
                      confirmationRowItem(
                        title: 'Amount:',
                        value: '${state.amount} XLM',
                      ),
                      confirmationRowItem(
                        title: 'Transaction Fee:',
                        value: '${state.fee} XLM',
                      ),
                      confirmationRowItem(
                        title: 'Time:',
                        value:
                            '${getMonth(state.time.month)} ${state.time.day},${state.time.year} at ${state.time.hour}:${state.time.minute}:${state.time.second}',
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 8, bottom: 16),
                          child: SizedBox(
                            width: double.maxFinite,
                            child: RawMaterialButton(
                              elevation: 0,
                              fillColor: AppTheme.primaryColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Proceed',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                          )),
                    ],
                  );
                }
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Enter amount of XLM want to send'),
                    ),
                    Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppTheme.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        autocorrect: false,
                        autofocus: true,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                        ),
                        onChanged: (value) {
                          amount = double.parse(value);
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: RawMaterialButton(
                          onPressed: () {
                            _transactionCubit.sendNativePayment(
                                senderId: sender.accountId,
                                destinationId: receiver.accountId,
                                amount: amount.toString());
                          },
                          // hoverColor: Colors.blue,
                          elevation: 0,
                          fillColor: AppTheme.primaryColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: BlocConsumer<TransactionCubit,
                                TransactionCubitState>(
                              bloc: _transactionCubit,
                              listener: (context, state) {
                                if (state is TransactionPaymentSent) {
                                  // Navigator.of(context).pop();
                                  FocusScope.of(context).unfocus();
                                  _infoCubit
                                      .getBasicAccountInfo(sender.accountId);
                                }
                              },
                              builder: (context, state) {
                                if (state is TransactionPaymentSending) {
                                  return Row(
                                    children: [
                                      const Text(
                                        'Transaction Sending',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child:
                                            const CircularProgressIndicator(),
                                        width: 16,
                                        height: 16,
                                      )
                                    ],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  );
                                } else if (state is TransactionPaymentFailed) {
                                  return const Text('An Error Accord',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.red));
                                } else if (state is TransactionPaymentSent) {}

                                return const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  final _buyAssetFormKey = GlobalKey<FormState>();

  Future<dynamic> showBuyAssetBottomSheet(BuildContext context) {
    List<String> list = [];
    Token selectedToken = tokens.first;
    for (var token in tokens) {
      if (token.trusted) {
        list.add(token.symbol);
      }
    }

    String selectedValue = list.first;
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: MediaQuery.of(context).viewInsets,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: Form(
                key: _buyAssetFormKey,
                child: BlocConsumer<TransactionCubit, TransactionCubitState>(
                  bloc: _transactionCubit,
                  listener: (context, state) {},
                  builder: (context, state) => StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        children: [
                          DropdownButton<String>(
                            value: selectedValue,
                            items: list
                                .map<DropdownMenuItem<String>>(
                                    (String value) => DropdownMenuItem(
                                          child: Text(value),
                                          value: value,
                                        ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value!;
                                for (var token in tokens) {
                                  if (token.symbol == selectedValue) {
                                    selectedToken = token;
                                  }
                                }
                              });
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Enter amount of token want to buy'),
                          ),
                          Container(
                            height: 48,
                            margin: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppTheme.primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              autocorrect: false,
                              validator: (value) {
                                if (value != "") {
                                  if (double.parse(value!) > 500) {
                                    return 'Amount of token to buy must be less than 500';
                                  }
                                  return null;
                                } else {
                                  return 'Please enter amount';
                                }
                              },
                              autofocus: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                focusColor: Colors.white,
                              ),
                              onChanged: (value) {
                                buyAssetAmount = double.parse(value);
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 24, right: 24, top: 8, bottom: 16),
                            child: SizedBox(
                              width: double.maxFinite,
                              child: RawMaterialButton(
                                onPressed: () {
                                  _transactionCubit.sendNonNativePayment(
                                    issuerSecretSeed: issuerSecretSeed,
                                    senderSecretSeed: discontrollerSecretSeed,
                                    trusterSecretSeed: keys[activeAccountId],
                                    tokenName: selectedToken.symbol,
                                    amount: buyAssetAmount.toString(),
                                    type: TransactionPaymentType.buy,
                                  );
                                },
                                elevation: 0,
                                fillColor: AppTheme.primaryColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: BlocConsumer<TransactionCubit,
                                      TransactionCubitState>(
                                    bloc: _transactionCubit,
                                    listener: (context, state) {
                                      if (state is TransactionPaymentSent) {
                                        _infoCubit.getBasicAccountInfo(
                                            activeAccountId);
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state is TransactionPaymentSending) {
                                        return Row(
                                          children: [
                                            const Text(
                                              'Sending request',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child:
                                                  const CircularProgressIndicator(),
                                              width: 16,
                                              height: 16,
                                            )
                                          ],
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        );
                                      } else if (state
                                          is TransactionPaymentSent) {
                                        return Row(
                                          children: [
                                            const Text(
                                              'The token has been purchased',
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        );
                                      }
                                      return const Text(
                                        'Buy',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (state is TransactionPaymentFailed)
                            Text(
                                'An Error Accord\n ${state.message.toString()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.red))
                        ],
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget confirmationRowItem({required String title, required String value}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title),
              const SizedBox(width: 36),
              Expanded(
                  child: Text(
                value,
                maxLines: 3,
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Divider(),
        )
      ],
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;

  String getMonth(int month) {
    String value = '';
    switch (month) {
      case 1:
        value = 'Jan';
        break;
      case 2:
        value = 'Feb';

        break;
      case 3:
        value = 'Mar';

        break;
      case 4:
        value = 'Apr';

        break;
      case 5:
        value = 'May';

        break;
      case 6:
        value = 'Jun';

        break;
      case 7:
        value = 'Jul';

        break;
      case 8:
        value = 'Aug';

        break;
      case 9:
        value = 'Sep';

        break;
      case 10:
        value = 'Oct';

        break;
      case 11:
        value = 'Nov';

        break;
      case 12:
        value = 'Dec';

        break;
    }
    return value;
  }
}
