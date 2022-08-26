import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/models/generated_key.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

part 'key_generation_state.dart';

class KeyGenerationCubit extends Cubit<KeyGenerationState> {
  KeyGenerationCubit() : super(KeyGenerationInitial());
  late KeyPair keyPair1;
  late KeyPair keyPair2;
  Future<void> generateKeys() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      emit(KeyGenerationLoading());
      keyPair1 = KeyPair.random();
      // Generate another key pair for account2
      keyPair2 = KeyPair.random();
      String? encodedKeys = prefs.getString('keys');
      Map<String, dynamic> keys = {};
      if (encodedKeys == null) {
        await prefs.setString('accountId', keyPair1.accountId);
        await prefs.setBool('funded', false);

        keys = {
          keyPair1.accountId: keyPair1.secretSeed,
          keyPair2.accountId: keyPair2.secretSeed
        };

        String encodedKeys = json.encode(keys);
        print(encodedKeys);

        prefs.setString('keys', encodedKeys);

        Map<String, dynamic> funds = {
          keyPair1.accountId: false,
          keyPair2.accountId: false
        };
        String encodedFunds = json.encode(funds);
        prefs.setString('funds', encodedFunds);

        // generate mnemonic words

      } else {
        keys = json.decode(encodedKeys);
        print(keys.toString());
      }

      String mnemonic = await Wallet.generate12WordsMnemonic();
      print(mnemonic);

      emit(
        KeyGenerationDone(
          GeneratedKey(
            pubkey: keys.keys.toList()[0],
            secretSeed: keys.values.toList()[0],
            mnemonicWords: mnemonic.split(' '),
          ),
        ),
      );
    } catch (e) {
      emit(KeyGenerationFailure(e.toString()));
      print(e.toString());
    }
  }
}
