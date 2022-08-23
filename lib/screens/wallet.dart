import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/blocs/account%20basic%20info/basic_info_cubit.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit_cubit.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/models/account.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

late String activeAccountId;
late List<Account> accounts = [];
late BasicInfoCubit _infoCubit;

class WalletPage extends StatefulWidget {
  const WalletPage(this.accountId, {Key? key}) : super(key: key);
  final String accountId;
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late bool funded = false;

  @override
  void initState() {
    super.initState();

    _infoCubit = BasicInfoCubit();
    loadAccountInfo();
    activeAccountId = widget.accountId;
  }

  Future<void> loadAccountInfo() async {
    final pref = await SharedPreferences.getInstance();
    funded = pref.getBool('funded')!;
    if (funded == false) {
      _infoCubit.fundAccount(widget.accountId);
    } else {
      _infoCubit.getBasicAccountInfo(pref.getString('accountId')!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                'assets/stellarLogo.svg',
              ),
            ),
            const Text(
              'Stellar Wallet',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        leading: const Icon(
          Icons.menu_rounded,
          color: Colors.black,
        ),
        actions: [
          Container(
            width: 56,
          )
        ],
      ),
      body: BlocProvider(
        create: (context) => _infoCubit,
        child: BlocConsumer<BasicInfoCubit, BasicInfoState>(
          bloc: _infoCubit,
          listener: (context, state) {
            if (state is FundAccountDone) {
              if (state.result) {
                _infoCubit.getBasicAccountInfo(widget.accountId);
                this.funded = true;
              }
            }
          },
          builder: (context, state) {
            if (state is FundAccountLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.all(8),
                      width: 24,
                      height: 24,
                      child: const CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Text(
                      'Funding your account on Stellar TestNet',
                      style: TextStyle(color: Colors.black),
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
                          icon: Icon(Icons.replay))
                    ],
                  ),
                );
              }
            } else if (state is AccountInfoLoaded) {
              var newAccount = Account(
                  imageUrl: imageUrl,
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
                accounts.add(newAccount);
                accounts.add(Account(
                  imageUrl: imageUrl,
                  accountId: accountId2,
                  index: accounts.length + 1,
                ));
              }
              var id = state.account.accountId;
              var xlmAmount;
              for (stl.Balance? balance in state.account.balances!) {
                switch (balance!.assetType) {
                  case stl.Asset.TYPE_NATIVE:
                    xlmAmount = balance.balance;
                    print("Balance: ${balance.balance} XLM");
                    break;
                  default:
                    print(
                        "Balance: ${balance.balance} ${balance.assetCode} Issuer: ${balance.assetIssuer}");
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
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // Container(
                        //   height: 500,
                        //   color: Colors.purple,
                        // ),
                        // Container(
                        //   height: 500,
                        //   color: Colors.red,
                        // ),
                      ],
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
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 12),
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
                    margin: EdgeInsets.all(8),
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Text(
                    'Loading Account Info',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String accountId2 =
      'GCWTQYKL4Z6H262JW7BP76V2TZIGFE6FU5HDMOCZJ6327ZL3B6RVUABO';
  String imageUrl =
      'https://img.seadn.io/files/7a485f43de73d372b34ef909e8e60aa7.png?fit=max&w=600';
  SliverChildListDelegate sliverAccountInfoHeader(
      xlmAmount, Account account, BuildContext context) {
    return SliverChildListDelegate(
      [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                var account1length = widget.accountId.length;
                return Wrap(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              setState(() {
                                _infoCubit
                                    .getBasicAccountInfo(widget.accountId);
                                activeAccountId = widget.accountId;
                              });
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              'Account 1: ${widget.accountId.toString().substring(0, 8)}...${widget.accountId.toString().substring(account1length - 8, account1length)}',
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(2),
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
                                    imageUrl,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                _infoCubit.getBasicAccountInfo(accountId2);
                                activeAccountId = accountId2;
                                Navigator.of(context).pop();
                              });
                            },
                            title: Text(
                              'Account 2: ${accountId2.toString().substring(0, 8)}...${accountId2.toString().substring(accountId2.length - 8, accountId2.length)}',
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(2),
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
                                    imageUrl,
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
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
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
          margin: EdgeInsets.only(top: 24, bottom: 0),
          padding: EdgeInsets.all(2),
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
          style: TextStyle(fontSize: 16),
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
                  borderRadius: BorderRadius.all(Radius.circular(25))),
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
                  content: Text('Account id copied to your clipboard'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
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
}

class SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double height;

  SectionHeaderDelegate(this.title, [this.height = 65]);
  final TransactionCubit _transactionCubit = TransactionCubit();
  double amount = 0;

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return BlocProvider(
      create: (context) => _transactionCubit,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 0),
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
                    icon: Icon(Icons.credit_card_rounded),
                    onPressed: () {},
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
                    // iconSize: 16,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      late Account sender, receiver;
                      for (Account account in accounts) {
                        if (account.accountId == activeAccountId) {
                          sender = account;
                        } else {
                          receiver = account;
                        }
                      }
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 16),
                                        child: Text(
                                            'Enter amount of XLM want to send'),
                                      ),
                                      Container(
                                        height: 48,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppTheme.primaryColor,
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: TextFormField(
                                          autocorrect: false,
                                          decoration: const InputDecoration(
                                            fillColor: Colors.white,
                                            focusColor: Colors.white,
                                          ),
                                          onChanged: (value) {
                                            amount = double.parse(value);
                                          },
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 24,
                                            right: 24,
                                            top: 8,
                                            bottom: 16),
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          child: RawMaterialButton(
                                            onPressed: () {
                                              _transactionCubit
                                                  .sendNativePayment(
                                                      senderId:
                                                          sender.accountId,
                                                      destinationId:
                                                          receiver.accountId,
                                                      amount:
                                                          amount.toString());
                                            },
                                            // hoverColor: Colors.blue,
                                            elevation: 0,
                                            fillColor: AppTheme.primaryColor,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12),
                                              child: BlocBuilder<
                                                  TransactionCubit,
                                                  TransactionCubitState>(
                                                bloc: _transactionCubit,
                                                builder: (contextModal, state) {
                                                  if (state
                                                      is TransactionPaymentSending) {
                                                    return Row(
                                                      children: [
                                                        const Text(
                                                          'Transaction Sending',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child:
                                                              const CircularProgressIndicator(),
                                                          width: 16,
                                                          height: 16,
                                                        )
                                                      ],
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                    );
                                                  } else if (state
                                                      is TransactionPaymentSent) {
                                                    Navigator.of(contextModal)
                                                        .pop();
                                                    _infoCubit
                                                        .getBasicAccountInfo(
                                                            sender.accountId);
                                                  } else if (state
                                                      is TransactionPaymentFailure) {
                                                    return const Text(
                                                        'An Error Accord',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white));
                                                  }

                                                  return const Text('Submit',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                          color: Colors.white));
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      BlocBuilder(
                                        builder: (context, state) {
                                          if (state
                                              is TransactionPaymentFailure) {
                                            return Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                  'Error : ${state.message}',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center),
                                            );
                                          }
                                          return Container();
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    color: Colors.white,
                  ),
                ),
                Text(
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
                    icon: Icon(Icons.swap_horiz),
                    onPressed: () {},
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Swap',
                  style: TextStyle(color: AppTheme.primaryColor),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
