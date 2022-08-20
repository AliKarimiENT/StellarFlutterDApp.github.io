part of 'key_generation_cubit.dart';

abstract class KeyGenerationState extends Equatable {
  const KeyGenerationState();
}

class KeyGenerationInitial extends KeyGenerationState {
  @override
  List<Object> get props => [];
}

class KeyGenerationDone extends KeyGenerationState {
  GeneratedKey keys;
  KeyGenerationDone(this.keys);

  @override
  List<Object?> get props => [keys];
}

class KeyGenerationFailure extends KeyGenerationState {
  String message;
  KeyGenerationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class KeyGenerationLoading extends KeyGenerationState{
  @override
  List<Object?> get props => []; 
}