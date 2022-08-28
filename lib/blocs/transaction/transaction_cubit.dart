import 'dart:convert';
import "dart:math";
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionCubitState> {
  TransactionCubit() : super(TransactionCubitInitial());

  Future<void> sendNativePayment(
      {required String destinationId,
      required String senderId,
      required String amount}) async {
    try {
      emit(TransactionPaymentSending());
      final pref = await SharedPreferences.getInstance();
      String encodedKeys = pref.getString('keys')!;
      Map<String, dynamic> keys = json.decode(encodedKeys);
      var secretSeed = keys[senderId];
      stl.KeyPair senderKeyPair = stl.KeyPair.fromSecretSeed(secretSeed);

      // Load sender's account data from the stellar network. It contains the current sequence number.
      stl.AccountResponse sender =
          await sdk.accounts.account(senderKeyPair.accountId);

      stl.Transaction transaction = stl.TransactionBuilder(sender)
          .addOperation(stl.PaymentOperationBuilder(
                  destinationId, stl.Asset.NATIVE, amount)
              .build())
          .build();

      // Sign the transaction with the sender's key pair.
      transaction.sign(senderKeyPair, stl.Network.TESTNET);

      // Submit the transaction to the stellar network.
      stl.SubmitTransactionResponse response =
          await sdk.submitTransaction(transaction);
      if (response.success) {
        print("Payment sent");
        emit(
          TransactionPaymentSent(
            transaction,
            DateTime.now(),
            transaction.fee!.toDouble() * pow(10, -7).toDouble(),
            destinationId,
            amount,
          ),
        );
      }

      var transactions = sdk.transactions.forAccount(senderId).execute();
      var operations = sdk.operations.forAccount(senderId).execute();
      stl.Page<stl.OperationResponse> payments =
          await sdk.payments.forAccount(senderId).execute();
    } catch (e) {
      TransactionPaymentFailure(e.toString());
    }
  }

  Future<void> createTrustline(
      String issuerSecretSeed, String trusterSecretSeed) async {
    // First we create the trustor key pair from the seed of the trustor so that we can use it to sign the transaction.
    stl.KeyPair trustorKeyPair = stl.KeyPair.fromSecretSeed(trusterSecretSeed);

    // Account Id of the trustor account.
    String trustorAccountId = trustorKeyPair.accountId;

    // Load the trustor's account details including it's current sequence number.
    stl.AccountResponse trustor = await sdk.accounts.account(trustorAccountId);

    stl.KeyPair issuerKeyPair = stl.KeyPair.fromSecretSeed(issuerSecretSeed);

    // Account Id of the issuer account
    String issuerAccountId = issuerKeyPair.accountId;

    // Define our custom token/asset "IOM" issued by the upper issuer account.
    stl.Asset iomAsset = stl.AssetTypeCreditAlphaNum4("IOM", issuerAccountId);

    // Prepare the change trust operation to trust the IOM asset/token defined above.
    // We limit the trusted/credit amount to 30.000.
    stl.ChangeTrustOperationBuilder changeTrustOperation =
        stl.ChangeTrustOperationBuilder(iomAsset, "30000");

    // Build the transaction.
    stl.Transaction transaction = stl.TransactionBuilder(trustor)
        .addOperation(changeTrustOperation.build())
        .build();

    // The trustor signs the transaction.
    transaction.sign(trustorKeyPair, stl.Network.TESTNET);

    // Submit the transaction.
    stl.SubmitTransactionResponse response =
        await sdk.submitTransaction(transaction);

    if (!response.success) {
      print("something went wrong.");
    }

    // Now we can send 1000 IOM from the issuer to the trustor.
    // Load the issuer's account details including its current sequence number.
    stl.AccountResponse issuer = await sdk.accounts.account(issuerAccountId);

    // Send 1000 IOM non native payment from the issuer to the trustor.
    transaction = stl.TransactionBuilder(issuer)
        .addOperation(
            stl.PaymentOperationBuilder(trustorAccountId, iomAsset, "1000")
                .build())
        .build();

    // The issuer signs the transaction.
    transaction.sign(issuerKeyPair, stl.Network.TESTNET);

    // Submit the transaction to the stellar network.
    response = await sdk.submitTransaction(transaction);

    if (!response.success) {
      print("something went wrong.");
    }

    // (info) check the trustor account data to see if the trustor received the payment.
    trustor = await sdk.accounts.account(trustorAccountId);
    for (stl.Balance? balance in trustor.balances!) {
      if (balance!.assetType != stl.Asset.TYPE_NATIVE &&
          balance.assetCode == "IOM" &&
          double.parse(balance.balance!) > 90) {
        print("trustor received IOM payment");
        break;
      }
    }
  }
}
