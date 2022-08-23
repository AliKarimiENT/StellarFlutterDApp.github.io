part of 'transaction_cubit_cubit.dart';

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
  @override
  List<Object?> get props => [];
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
