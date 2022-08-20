class GeneratedKey {
  late final String publicKey;
  late final String secretSeed;
  late final List<String> mnemonic;
  GeneratedKey(
      {required String pubkey,
      required String secretSeed,
      required List<String> mnemonicWords}) {
    publicKey = pubkey;
    secretSeed = secretSeed;
    mnemonic = mnemonicWords;
  }
}
