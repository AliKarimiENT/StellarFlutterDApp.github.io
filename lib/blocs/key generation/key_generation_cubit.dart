import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/main.dart';
import 'package:stellar_flutter_dapp/models/generated_key.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

part 'key_generation_state.dart';

class KeyGenerationCubit extends Cubit<KeyGenerationState> {
  KeyGenerationCubit() : super(KeyGenerationInitial());
  late KeyPair keyPair1;
  late KeyPair keyPair2;
  Future<void> generateKeys() async {

    try {
      emit(KeyGenerationLoading());
      // Generate another key pair for account2
      String? mnemonicWords = pref.getString('mnemonic');
      if (mnemonicWords == null) {
        String mnemonic = await Wallet.generate12WordsMnemonic();
        mnemonicWords = mnemonic;
        await pref.setString('mnemonic', mnemonic);
      }
      print(mnemonicWords);
      Wallet wallet = await Wallet.from(mnemonicWords);
      keyPair1 = await wallet.getKeyPair(index: 0);
      keyPair2 = await wallet.getKeyPair(index: 1);

      String? encodedKeys = pref.getString('keys');
      Map<String, dynamic> keys = {};
      if (encodedKeys == null) {
        await pref.setString('accountId', keyPair1.accountId);
        await pref.setBool('funded', false);

        keys = {
          keyPair1.accountId: keyPair1.secretSeed,
          keyPair2.accountId: keyPair2.secretSeed
        };

        String encodedKeys = json.encode(keys);
        print(encodedKeys);

        pref.setString('keys', encodedKeys);

        Map<String, dynamic> funds = {
          keyPair1.accountId: false,
          keyPair2.accountId: false
        };
        String encodedFunds = json.encode(funds);
        pref.setString('funds', encodedFunds);

        // generate mnemonic words

      } else {
        keys = json.decode(encodedKeys);
        print(keys.toString());
      }

      emit(
        KeyGenerationDone(
          GeneratedKey(
            pubkey: keys.keys.toList()[0],
            secretSeed: keys.values.toList()[0],
            mnemonicWords: mnemonicWords.split(' '),
          ),
        ),
      );
    } catch (e) {
      emit(KeyGenerationFailure(e.toString()));
      print(e.toString());
    }
  }
}
