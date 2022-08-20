part of 'key_generation_cubit.dart';

abstract class KeyGenerationState extends Equatable {
  const KeyGenerationState();
}

class KeyGenerationInitial extends KeyGenerationState {
  @override
  List<Object> get props => [];
}

class KeyGenerationDone extends KeyGenerationState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
  
}
