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
    this.type}
  );
  @override
  List<Object?> get props => [
        transaction,
        time,
        fee,
        receiver,
        amount,
      ];
}

class TransactionPaymentFailure extends TransactionCubitState {
  final String message;
  const TransactionPaymentFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionPaymentConfirmed extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class TrustingToken extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class TrustingTokenDone extends TransactionCubitState {
  @override
  List<Object?> get props => [];
}

class TrustingTokenFailure extends TransactionCubitState {
  String message;
  TrustingTokenFailure(this.message);
  @override
  List<Object?> get props => [message];
}
