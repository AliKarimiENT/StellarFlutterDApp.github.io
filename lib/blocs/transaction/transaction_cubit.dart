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
}
