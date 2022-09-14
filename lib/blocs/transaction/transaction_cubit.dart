import 'dart:convert';
import "dart:math";
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_dapp/consts.dart';
import 'package:stellar_flutter_dapp/main.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

import '../../enum.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionCubitState> {
  TransactionCubit() : super(TransactionCubitInitial());

  Future<void> sendNativePayment(
      {required String destinationId,
      required String senderId,
      required String amount}) async {
    try {
      emit(TransactionPaymentSending());

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
              transaction: transaction,
              time: DateTime.now(),
              fee: transaction.fee!.toDouble() * pow(10, -7).toDouble(),
              receiver: destinationId,
              amount: amount,
              type: 'XLM'),
        );
      }

      var transactions = sdk.transactions.forAccount(senderId).execute();
      var operations = sdk.operations.forAccount(senderId).execute();
      stl.Page<stl.OperationResponse> payments =
          await sdk.payments.forAccount(senderId).execute();
    } catch (e) {
      TransactionPaymentFailed(e.toString());
    }
  }

  void initTrust() {
    emit(TransactionCubitInitial());
  }

  Future<void> createTrustline({
    required String issuerSecretSeed,
    required String trusterSecretSeed,
    required String tokenName,
    required String trustLimit,
    required ChangeTrustType type,
  }) async {
    try {
      emit(ChangingTokenTrust(type: type));
      // First we create the trustor key pair from the seed of the trustor so that we can use it to sign the transaction.
      stl.KeyPair trustorKeyPair =
          stl.KeyPair.fromSecretSeed(trusterSecretSeed);

      // Account Id of the trustor account.
      String trustorAccountId = trustorKeyPair.accountId;

      // Load the trustor's account details including it's current sequence number.
      stl.AccountResponse trustor =
          await sdk.accounts.account(trustorAccountId);

      if (int.parse(trustLimit) == 0) {
        for (stl.Balance? balance in trustor.balances!) {
          if (balance!.assetCode == tokenName) {
            if (double.tryParse(balance.balance!)!.toInt() != 0) {
              emit(TrustingTokenFailed(
                  'Unable to remove trustline with a non-zero asset balance'));
              break;
            }
          }
        }
      }

      stl.KeyPair issuerKeyPair = stl.KeyPair.fromSecretSeed(issuerSecretSeed);

      // Account Id of the issuer account
      String issuerAccountId = issuerKeyPair.accountId;

      // Define our custom token/asset "IOM" issued by the upper issuer account.
      stl.Asset asset =
          stl.AssetTypeCreditAlphaNum4(tokenName, issuerAccountId);

      // Prepare the change trust operation to trust the IOM asset/token defined above.
      // We limit the trusted/credit amount to 30.000.
      stl.ChangeTrustOperationBuilder changeTrustOperation =
          stl.ChangeTrustOperationBuilder(asset, trustLimit);

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
        emit(TrustingTokenFailed('Something went wrong'));
      }
      print(transaction);
      print(response);
      if (double.tryParse(trustLimit) == 0) {
        emit(
          TrustingTokenDone(
              trusted: false, limit: int.tryParse(trustLimit)!, type: type),
        );
      } else {
        emit(
          TrustingTokenDone(
              trusted: true, limit: int.tryParse(trustLimit)!, type: type),
        );
      }
    } catch (e) {
      emit(TrustingTokenFailed(e.toString()));
    }
  }

  Future<void> sendNonNativePayment(
      {required String issuerSecretSeed,
      required String senderSecretSeed,
      required String trusterSecretSeed,
      required String tokenName,
      required String amount,
      required TransactionPaymentType type}) async {
    try {
      emit(TransactionPaymentSending());
      stl.KeyPair trustorKeyPair =
          stl.KeyPair.fromSecretSeed(trusterSecretSeed);
      String trustorAccountId = trustorKeyPair.accountId;

      stl.KeyPair issuerKeyPair = stl.KeyPair.fromSecretSeed(issuerSecretSeed);
      String issuerAccountId = issuerKeyPair.accountId;
      // stl.AccountResponse issuer = await sdk.accounts.account(issuerAccountId);

      stl.KeyPair senderKeyPair = stl.KeyPair.fromSecretSeed(senderSecretSeed);

      stl.AccountResponse sender =
          await sdk.accounts.account(senderKeyPair.accountId);

      stl.Asset asset =
          stl.AssetTypeCreditAlphaNum4(tokenName, issuerAccountId);

      stl.AccountResponse trustor =
          await sdk.accounts.account(trustorAccountId);

      stl.Transaction transaction = stl.TransactionBuilder(sender)
          .addOperation(
              stl.PaymentOperationBuilder(trustorAccountId, asset, amount)
                  .build())
          .build();

      // The issuer signs the transaction.
      transaction.sign(senderKeyPair, stl.Network.TESTNET);

      stl.SubmitTransactionResponse response =
          await sdk.submitTransaction(transaction);

      // Submit the transaction to the stellar network.
      response = await sdk.submitTransaction(transaction);
      late String failureMessage = 'something went wrong';
      if (!response.success) {
        print(failureMessage);
        for (stl.Balance? balance in trustor.balances!) {
          if (balance!.assetType != stl.Asset.TYPE_NATIVE &&
              balance.assetCode == tokenName &&
              double.parse(balance.balance!) + double.parse(amount) >=
                  double.parse(balance.limit!)) {
            if (type == TransactionPaymentType.buy) {
              failureMessage =
                  "You are not allowed to buy asset more then amount you trusted";
            } else {
              failureMessage =
                  "You are not allowed to send asset more then amount other account is trusted";
            }
            emit(TransactionPaymentFailed(failureMessage));
            break;
          }
        }
        emit(TransactionPaymentFailed(failureMessage));
      } else {
        emit(
          TransactionPaymentSent(
            transaction: transaction,
            time: DateTime.now(),
            fee: transaction.fee!.toDouble() * pow(10, -7).toDouble(),
            receiver: trustorAccountId,
            amount: amount,
            type: tokenName,
          ),
        );

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
    } catch (e) {
      emit(TransactionPaymentFailed(e.toString()));
    }
  }

  Future<void> manageOffer({
    required OfferOperationType type,
    required String issuerSecretSeed,
    required String sellerSecretSeed,
    required String sellingAssetName,
    required String buyingAssetName,
    required int amountSelling, // amount of asset want to sell
    required int amountBuying,
    required String? offerId,
    required String? memo,
    required bool passiveOffer,
  }) async {
    try {
      emit(ProcessingOffer(type: type));
      // seller key pair
      stl.KeyPair sellerKeyPair = stl.KeyPair.fromSecretSeed(sellerSecretSeed);
      String sellerAccountId = sellerKeyPair.accountId;

      // issuer key pair
      stl.KeyPair issuerKeyPair = stl.KeyPair.fromSecretSeed(issuerSecretSeed);
      String issuerAccountId = issuerKeyPair.accountId;

      stl.AccountResponse selller = await sdk.accounts.account(sellerAccountId);

      // define our assets
      late stl.Asset sellingAsset;
      if (sellingAssetName == "XLM") {
        sellingAsset = stl.Asset.NATIVE;
      } else {
        sellingAsset =
            stl.AssetTypeCreditAlphaNum4(sellingAssetName, issuerAccountId);
      }

      late stl.Asset buyingAsset;
      if (buyingAssetName == "XLM") {
        buyingAsset = stl.Asset.NATIVE;
      } else {
        buyingAsset =
            stl.AssetTypeCreditAlphaNum4(buyingAssetName, issuerAccountId);
      }

      // Create the offer
      // Price of 1 unit of selling in terms of buying
      var price;
      if (amountSelling == 0) {
        price = '1';
      } else {
        price = (double.tryParse(amountBuying.toString())! /
                double.tryParse(amountSelling.toString())!)
            .toString();
      }
      // Create the manage sell offer operation
      late stl.ManageSellOfferOperation ms;
      late stl.Transaction transaction;
      if (!passiveOffer) {
        if (type == OfferOperationType.create) {
          ms = stl.ManageSellOfferOperationBuilder(
                  sellingAsset, buyingAsset, amountSelling.toString(), price)
              .build();
        } else {
          ms = stl.ManageSellOfferOperationBuilder(
                  sellingAsset, buyingAsset, amountSelling.toString(), price)
              .setOfferId(offerId!)
              .build();
        }
        transaction = stl.TransactionBuilder(selller).addOperation(ms).build();
      } else {
        stl.CreatePassiveSellOfferOperation cspo =
            stl.CreatePassiveSellOfferOperationBuilder(
                    sellingAsset, buyingAsset, amountSelling.toString(), price)
                .build();
        transaction =
            stl.TransactionBuilder(selller).addOperation(cspo).build();
      }

      // Sign
      transaction.sign(sellerKeyPair, stl.Network.TESTNET);
      stl.SubmitTransactionResponse response =
          await sdk.submitTransaction(transaction).catchError((error) {
        print(error.toString());
      });

      if (!response.success) {
        String failureMessage = '';
        for (var error
            in response.extras!.resultCodes!.operationsResultCodes!.toList()) {
          failureMessage += '$error';
        }
        emit(OfferProcessFailed(message: failureMessage));
      } else {
        emit(OfferProcessDone(type: type));
      }
    } catch (e) {
      emit(OfferProcessFailed(message: e.toString()));
    }
  }

  Future<void> getOffers({required String accountId}) async {
    try {
      emit(LoadingOffers());
      stl.Page<stl.OfferResponse> offers = await sdk.offers
          .forAccount(accountId)
          .order(stl.RequestBuilderOrder.DESC)
          .execute();
      emit(LoadedOffers(records: offers.records!.toList()));
    } catch (e) {
      emit(LoadingOffersFailed(message: e.toString()));
    }
  }

  Future<void> getTransaction({required String accountId}) async {
    try {
      emit(LoadingTransactions());
      stl.Page<stl.TransactionResponse> transactions = await sdk.transactions
          .forAccount(accountId)
          .order(stl.RequestBuilderOrder.DESC)
          .includeFailed(true)
          .execute();
      emit(LoadedTransactions(records: transactions.records!.toList()));
    } catch (e) {
      emit(LoadingTransactionsFailed(message: e.toString()));
    }
  }
Future<void> getOperations({required String accountId}) async {
    try {
      emit(LoadingOperations());
      stl.Page<stl.OperationResponse> transactions = await sdk.operations
          .forAccount(accountId)
          .order(stl.RequestBuilderOrder.DESC)
          .includeFailed(true)
          .execute();
      emit(LoadedOperations(records: transactions.records!.toList()));
    } catch (e) {
      emit(LoadingOperationsFailed(message: e.toString()));
    }
  }  

}
