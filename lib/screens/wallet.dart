import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stellar_flutter_dapp/app_theme.dart';
import 'package:stellar_flutter_dapp/blocs/account%20basic%20info/basic_info_cubit.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

import '../widgets/custom_appbar.dart';

class WalletPage extends StatefulWidget {
  const WalletPage(this.accountId, {Key? key}) : super(key: key);
  final String accountId;
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late BasicInfoCubit _infoCubit;
  @override
  void initState() {
    super.initState();
    _infoCubit = BasicInfoCubit();
    _infoCubit.fundAccount(widget.accountId);
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
        leading: Icon(
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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
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
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade600,
                        )
                      ],
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
                            'https://img.seadn.io/files/7a485f43de73d372b34ef909e8e60aa7.png?fit=max&w=600',
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Account 1',
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'XLM $xlmAmount ',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: widget.accountId.substring(0, 5),
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
                                  text: widget.accountId.substring(
                                      widget.accountId.length - 5,
                                      widget.accountId.length),
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
                            Clipboard.setData(
                                ClipboardData(text: widget.accountId));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Account id copied to your clipboard'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                              backgroundColor: AppTheme.primaryColor,duration: const Duration(milliseconds: 500),
                            ));
                          },
                          splashRadius: 24,
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
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
}
