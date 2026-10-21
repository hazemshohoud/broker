import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/registration_request.dart';
import '../../domain/usecases/submit_registration.dart';

part 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._submitRegistration)
    : super(const RegistrationInitial());

  final SubmitRegistration _submitRegistration;

  Future<void> submit(RegistrationRequest request) async {
    emit(const RegistrationSubmitting());
    final result = await _submitRegistration(SubmitRegistrationParams(request));
    result.fold(
      (failure) => emit(RegistrationFailure(failure.message)),
      (_) => emit(const RegistrationSuccess()),
    );
  }
}
