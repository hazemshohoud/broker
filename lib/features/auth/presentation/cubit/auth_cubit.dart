import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/usecases/get_session_status.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GetSessionStatus getSessionStatus,
    required SignIn signIn,
    required SignOut signOut,
  }) : _getSessionStatus = getSessionStatus,
       _signIn = signIn,
       _signOut = signOut,
       super(const AuthInitial());

  final GetSessionStatus _getSessionStatus;
  final SignIn _signIn;
  final SignOut _signOut;

  Future<void> checkSession() async {
    emit(const AuthChecking());
    final result = await _getSessionStatus(const NoParams());
    result.fold((failure) => emit(AuthFailure(failure.message)), (status) {
      if (status == null) {
        emit(const AuthNeedsLogin());
      } else {
        _emitForStatus(status);
      }
    });
  }

  Future<void> signIn({required String phone, required String pin}) async {
    emit(const AuthSubmitting());
    final result = await _signIn(SignInParams(phone: phone, pin: pin));
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      _emitForStatus,
    );
  }

  Future<void> signOut() async {
    await _signOut(const NoParams());
    emit(const AuthNeedsLogin());
  }

  void _emitForStatus(AccountStatus status) {
    switch (status) {
      case AccountStatus.admin:
        emit(const AuthAdmin());
      case AccountStatus.approved:
        emit(const AuthApproved());
      case AccountStatus.pending:
        emit(const AuthPending());
      case AccountStatus.rejected:
        emit(const AuthRejected('تم رفض طلب التسجيل'));
    }
  }
}
