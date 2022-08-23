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
      await pref.setBool('funded', funded);
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
      emit(AccountInfoLoaded(account));
    } catch (e) {
      emit(AccountInfoFailure(e.toString()));
    }
  }
}
