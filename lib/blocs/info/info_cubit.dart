import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/main.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

part 'info_state.dart';

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(BasicInfoInitial());

  Future<void> fundAccount(String accountId) async {
    try {
      emit(FundAccountLoading());
      Wallet x = await Wallet.from(
          'animal regret quality grit coffee adult utility pair snack prepare buyer decorate');
      KeyPair keyPair0 = await x.getKeyPair(index: 0);

      bool funded = await FriendBot.fundTestAccount(accountId);

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
      // Reload the account.
      account = await sdk.accounts.account(accountId);

      // Get the value for our key as bytes.
      Uint8List resultBytes = account.data!.getDecoded(key);

      // Convert it back to a string.
      String restltValue = String.fromCharCodes(resultBytes);

      // Compare.
      if (imageUri == restltValue) {
        print("okay");
      } else {
        print("failed");
      }

      await sdk.submitTransaction(transaction);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> editProfile({
    required String? name,
    required String? address,
    required String? email,
    required String secretSeed,
    required bool hasNameKeyValue,
    required bool hasEmailKeyValue,
    required bool nameChanged,
    required bool emailChanged,
  }) async {
    try {
      emit(EditingProfile());
      // load user's key pair
      KeyPair keyPair = KeyPair.fromSecretSeed(secretSeed);

      // load account data
      AccountResponse account = await sdk.accounts.account(keyPair.accountId);
      if (nameChanged) {
        if (name != null) {
          await sendManageDataTransaction(
            key: 'name',
            value: name,
            account: account,
            keyPair: keyPair,
          );
        } else {
          if (hasNameKeyValue) {
            await sendManageDataTransaction(
              key: 'name',
              value: name,
              account: account,
              keyPair: keyPair,
            );
          }
        }
      }

      // if (address != null) {
      //   await sendManageDataTransaction(
      //     key: 'stellarAddress',
      //     value: address,
      //     account: account,
      //     keyPair: keyPair,
      //   );
      //   FederationResponse response =
      //       await Federation.resolveStellarAddress(address);
      //   print(response.stellarAddress);
      //   // bob*soneso.com

      //   print(response.accountId);
      //   // GBVPKXWMAB3FIUJB6T7LF66DABKKA2ZHRHDOQZ25GBAEFZVHTBPJNOJI

      //   print(response.memoType);
      //   // text

      //   print(response.memo);
      //   // hello memo text
      // }

      if (emailChanged) {
        if (email != null) {
          await sendManageDataTransaction(
              key: 'email', value: email, account: account, keyPair: keyPair);
        } else {
          if (hasEmailKeyValue) {
            await sendManageDataTransaction(
              key: 'email',
              value: email,
              account: account,
              keyPair: keyPair,
            );
          }
        }
      }

      emit(EditedProfile());
    } catch (e) {
      emit(EditingProfileFailed(e.toString()));
    }
  }

  Future<void> sendManageDataTransaction({
    required String key,
    required String? value,
    required AccountResponse account,
    required KeyPair keyPair,
  }) async {
    var valueBytes = value != null ? convertKeyToUint8List(value) : null;

    ManageDataOperationBuilder manageDataOperationBuilder =
        ManageDataOperationBuilder(key, valueBytes);

    // create the transaction
    Transaction transaction = TransactionBuilder(account)
        .addOperation(manageDataOperationBuilder.build())
        .build();
    // sign the transaction
    transaction.sign(keyPair, Network.TESTNET);

    // submit the transaction to stellar
    await sdk.submitTransaction(transaction);

    // reload the account
    account = await sdk.accounts.account(keyPair.accountId);

    if (value == null) {
      print('$key entity has been deleted');
    } else {
      // get the value for our key as bytes
      Uint8List resultBytes = account.data!.getDecoded(key);

      // convert it back to a string
      String resultValue = String.fromCharCodes(resultBytes);

      // compare
      if (value == resultValue) {
        print('Your $key is edited');
      } else {
        emit(EditingProfileFailed('There was a problem to edit $key value'));
      }
    }
  }

  Uint8List convertKeyToUint8List(String key) {
    List<int> list = key.codeUnits;
    Uint8List valueBytes = Uint8List.fromList(list);
    return valueBytes;
  }
}
