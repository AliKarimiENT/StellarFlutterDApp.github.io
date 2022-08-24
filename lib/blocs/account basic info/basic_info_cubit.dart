import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

part 'basic_info_state.dart';

class BasicInfoCubit extends Cubit<BasicInfoState> {
  BasicInfoCubit() : super(BasicInfoInitial());

  Future<void> fundAccount(String accountId) async {
    try {
      emit(FundAccountLoading());

      bool funded = await FriendBot.fundTestAccount(accountId);

      final pref = await SharedPreferences.getInstance();
      String encodedFunds = pref.getString('funds')!;
      print('--$encodedFunds');
      Map<String, dynamic> funds = json.decode(encodedFunds);
      print('--- $funds');
      funds[accountId] = funded;
      funds = {
        funds.keys.toList()[0]: funds.values.toList()[0],
        funds.keys.toList()[1]: funds.values.toList()[1],
      };
      encodedFunds = json.encode(funds);
      print(encodedFunds);
      await pref.setString('funds', encodedFunds);

      print('fund account request result : $funded');
      emit(FundAccountDone(funded));
    } catch (e) {
      emit(FundAccountFailure(e.toString()));
    }
  }

  Future<void> getBasicAccountInfo(String accountId) async {
    try {
      emit(AccountInfoLoading());
      AccountResponse account = await sdk.accounts.account(accountId);
      print('Account info loaded');
      print(account.toString());
      print('addount address ${account.accountId}');
      emit(AccountInfoLoaded(account));
    } catch (e) {
      emit(AccountInfoFailure(e.toString()));
    }
  }
}
