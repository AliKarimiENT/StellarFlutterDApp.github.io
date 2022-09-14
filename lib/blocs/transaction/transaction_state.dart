part of 'transaction_cubit.dart';

abstract class TransactionCubitState extends Equatable {
  const TransactionCubitState();
}

class TransactionCubitInitial extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class TransactionPaymentSending extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class TransactionPaymentSent extends TransactionCubitState {
  stl.Transaction transaction;
  DateTime time;
  double fee; // based on XLM
  String receiver;
  String amount;
  String? type;
  TransactionPaymentSent(
      {required this.transaction,
      required this.time,
      required this.fee,
      required this.receiver,
      required this.amount,
      this.type});
  @override
  List<Object?> get props => [
        transaction,
        time,
        fee,
        receiver,
        amount,
      ];
}

class TransactionPaymentFailed extends TransactionCubitState {
  final String message;
  const TransactionPaymentFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionPaymentConfirmed extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class ChangingTokenTrust extends TransactionCubitState {
  ChangeTrustType type;
  ChangingTokenTrust({
    required this.type,
  });
  @override
  List<Object?> get props => [type];
}

class TrustingTokenDone extends TransactionCubitState {
  bool trusted;
  int limit;
  ChangeTrustType type;
  TrustingTokenDone({
    required this.trusted,
    required this.limit,
    required this.type,
  });
  @override
  List<Object?> get props => [trusted];
}

class TrustingTokenFailed extends TransactionCubitState {
  String message;
  TrustingTokenFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class ProcessingOffer extends TransactionCubitState {
  OfferOperationType type;
  ProcessingOffer({
    required this.type,
  });
  @override
  List<Object?> get props => [];
}

class OfferProcessDone extends TransactionCubitState {
  OfferOperationType type;
  OfferProcessDone({
    required this.type,
  });

  @override
  List<Object?> get props => [];
}

class OfferProcessFailed extends TransactionCubitState {
  String message;

  OfferProcessFailed({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class LoadingOffers extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class LoadedOffers extends TransactionCubitState {
  List<stl.OfferResponse> records;
  LoadedOffers({
    required this.records,
  });
  @override
  List<Object?> get props => [];
}

class LoadingOffersFailed extends TransactionCubitState {
  String message;
  LoadingOffersFailed({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

class LoadingTransactions extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class LoadedTransactions extends TransactionCubitState {
  List<stl.TransactionResponse> records;
  LoadedTransactions({
    required this.records,
  });
  @override
  List<Object?> get props => [records];
}

class LoadingTransactionsFailed extends TransactionCubitState {
  String message;
  LoadingTransactionsFailed({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

class LoadingOperations extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class LoadedOperations extends TransactionCubitState {
  List<stl.OperationResponse> records;
  LoadedOperations({
    required this.records,
  });
  @override
  List<Object?> get props => [records];
}

class LoadingOperationsFailed extends TransactionCubitState {
  String message;
  LoadingOperationsFailed({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}