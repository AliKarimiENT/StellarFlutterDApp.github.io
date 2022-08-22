part of 'basic_info_cubit.dart';

abstract class BasicInfoState extends Equatable {
  const BasicInfoState();
}

class BasicInfoInitial extends BasicInfoState {
  @override
  List<Object?> get props => [];
}

class FundAccountLoading extends BasicInfoState {
  @override
  List<Object?> get props => [];
}

class FundAccountDone extends BasicInfoState {
  bool result;
  FundAccountDone(this.result);
  @override
  List<Object?> get props => [result];
}

class FundAccountFailure extends BasicInfoState {
  String message;
  FundAccountFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AccountInfoLoading extends BasicInfoState {
  @override
  List<Object?> get props => [];
}

class AccountInfoLoaded extends BasicInfoState {
  AccountResponse account;
  AccountInfoLoaded(this.account);
  @override
  List<Object?> get props => [account];
}

class AccountInfoFailure extends BasicInfoState {
  String message;
  AccountInfoFailure(this.message);
  @override
  List<Object?> get props => [message];
}
