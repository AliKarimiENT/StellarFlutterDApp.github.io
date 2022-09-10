import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

part 'info_state.dart';

class InfoCubit extends Cubit<BasicInfoState> {
  InfoCubit() : super(BasicInfoInitial());

  Future<void> fundAccount(String accountId) async {
    try {
      emit(FundAccountLoading());
      Wallet x = await Wallet.from(
          'animal regret quality grit coffee adult utility pair snack prepare buyer decorate');
      KeyPair keyPair0 = await x.getKeyPair(index: 0);

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
      print('account address ${account.accountId}');
      emit(AccountInfoLoaded(account));
    } catch (e) {
      emit(AccountInfoFailure(e.toString()));
    }
  }

  Future<void> setUserProfileImage(
      String imageUri, String accountId, String secretSeed) async {
    try {
      // load key pair
      KeyPair keyPair = KeyPair.fromSecretSeed(secretSeed);

      // Load account data with its accountId
      AccountResponse account = await sdk.accounts.account(accountId);

      String key = 'image';

      // Our value is imageUri
      // Convert the value to bytes
      List<int> list = imageUri.codeUnits;
      Uint8List valueBytes = Uint8List.fromList(list);

      // Prepare the manage data operation
      ManageDataOperationBuilder manageDataOperationBuilder =
          ManageDataOperationBuilder(key, valueBytes);

      // Create the transaction
      Transaction transaction = TransactionBuilder(account)
          .addOperation(manageDataOperationBuilder.build())
          .build();

      // Sign the transaction
      transaction.sign(keyPair, Network.TESTNET);

      await sdk.submitTransaction(transaction);
    } catch (e) {
      print(e.toString());
    }
  }
}
