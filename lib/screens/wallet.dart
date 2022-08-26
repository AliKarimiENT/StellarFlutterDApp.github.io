import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/blocs/account%20basic%20info/basic_info_cubit.dart';
import 'package:stellar_flutter_dapp/blocs/transaction/transaction_cubit.dart';
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
  late Map<String, dynamic> keys;
  late Map<String, dynamic>
      funds; // a mapping for accountId and true/false which shows that an account is funded or not
  late String accountId2;

  @override
  void initState() {
    super.initState();
    loadFunds();

    _infoCubit = BasicInfoCubit();
    loadAccountInfo();
    loadKeys();
    activeAccountId = widget.accountId;
  }

  Future<void> loadFunds() async {
    final pref = await SharedPreferences.getInstance();
    String encodedFunds = pref.getString('funds')!;
    funds = json.decode(encodedFunds);
    //      var secretSeed = keys[senderId];
  }

  Future<void> loadKeys() async {
    final pref = await SharedPreferences.getInstance();
    String encodedKeys = pref.getString('keys')!;
    keys = json.decode(encodedKeys);
    accountId2 = keys.keys.toList()[1];
  }

  Future<void> loadAccountInfo() async {
    final pref = await SharedPreferences.getInstance();

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
                _infoCubit.getBasicAccountInfo(activeAccountId);
                funds[activeAccountId] = true;
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
                          content: Text(
                              'The reciever account is not funded\nTry to change account and it will be funded'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
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
                            color: Colors.black,
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
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
                            padding: EdgeInsets.symmetric(vertical: 12),
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
                                } else if (state is TransactionPaymentFailure) {
                                  return const Text('An Error Accord',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.red));
                                } else if (state is TransactionPaymentSent) {}

                                return const Text('Submit',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white));
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(),
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
