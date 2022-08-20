import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
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
