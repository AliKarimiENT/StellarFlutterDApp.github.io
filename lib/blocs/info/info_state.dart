part of 'info_cubit.dart';

abstract class InfoState extends Equatable {
  const InfoState();
}

class BasicInfoInitial extends InfoState {
  @override
  List<Object?> get props => [];
}

class FundAccountLoading extends InfoState {
  @override
  List<Object?> get props => [];
}

class FundAccountDone extends InfoState {
  bool result;
  FundAccountDone(this.result);
  @override
  List<Object?> get props => [result];
}

class FundAccountFailure extends InfoState {
  String message;
  FundAccountFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AccountInfoLoading extends InfoState {
  @override
  List<Object?> get props => [];
}

class AccountInfoLoaded extends InfoState {
  AccountResponse account;
  AccountInfoLoaded(this.account);
  @override
  List<Object?> get props => [account];
}

class AccountInfoFailure extends InfoState {
  String message;
  AccountInfoFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class EditingProfile extends InfoState {
  @override
  List<Object?> get props => [];
}

class EditingProfileFailed extends InfoState {
  String message;
  EditingProfileFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class EditedProfile extends InfoState {
  @override
  List<Object?> get props => [];
}
