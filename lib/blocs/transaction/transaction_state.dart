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
  TransactionPaymentSent(
    this.transaction,
    this.time,
    this.fee,
    this.receiver,
    this.amount,
  );
  @override
  List<Object?> get props => [transaction, time, fee, receiver,amount];
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
