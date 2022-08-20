import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'key_generation_state.dart';

class KeyGenerationCubit extends Cubit<KeyGenerationState> {
  KeyGenerationCubit() : super(KeyGenerationInitial());
}
