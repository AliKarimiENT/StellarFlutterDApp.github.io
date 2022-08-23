import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/models/generated_key.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

part 'key_generation_state.dart';

class KeyGenerationCubit extends Cubit<KeyGenerationState> {
  KeyGenerationCubit() : super(KeyGenerationInitial());

  Future<void> generateKeys() async {
    try {
      emit(KeyGenerationLoading());
      KeyPair keyPair = KeyPair.random();
      print('Account ID');
      print("${keyPair.accountId}");
      print('Secret Seed');
      print("${keyPair.secretSeed}");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accountId', keyPair.accountId);
      await prefs.setBool('funded', false);
      Map<String, String> keys = {
        keyPair.accountId: keyPair.secretSeed,
        'GCWTQYKL4Z6H262JW7BP76V2TZIGFE6FU5HDMOCZJ6327ZL3B6RVUABO':
            'SAIJCZ4C7UK27ORZVZ4SQHJNLMKPHG3CWBLAWTML45ZKTHWFKB2SUAJA'
      };
      String encodedKeys = json.encode(keys);
      print(encodedKeys);

      prefs.setString('keys', encodedKeys);
      // generate mnemonic workds
      String mnemonic = await Wallet.generate12WordsMnemonic();
      print(mnemonic);
      emit(KeyGenerationDone(GeneratedKey(
          pubkey: keyPair.accountId,
          secretSeed: keyPair.secretSeed,
          mnemonicWords: mnemonic.split(' '))));
    } catch (e) {
      emit(KeyGenerationFailure(e.toString()));
    }
  }
}
