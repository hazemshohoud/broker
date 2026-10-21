import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  AdminAuthCubit() : super(const AdminAuthInitial());

  /// أرقام الهواتف المعتمدة لإدارة النظام
  static const allowedPhones = ['01088888888', '01000000000'];

  /// كلمات المرور المعتمدة لإدارة النظام
  static const allowedPasswords = ['8888', '88888888'];
  static const allowedPassword = '88888888';

  Future<void> signIn({
    required String phone,
    required String password,
  }) async {
    emit(const AdminAuthLoading());

    // تأخير محاكاة بسيط لأناقة الـ UX ولإظهار الـ loading state
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedPhone = phone.trim();
    final normalizedPassword = password.trim();

    if (allowedPhones.contains(normalizedPhone) &&
        (allowedPasswords.contains(normalizedPassword) ||
            normalizedPassword == allowedPassword)) {
      emit(AdminAuthAuthenticated(phone: normalizedPhone));
    } else {
      emit(
        const AdminAuthFailure(
          'بيانات تسجيل الدخول غير صحيحة، تأكد من رقم الهاتف وكلمة المرور الخاصة بالإدارة',
        ),
      );
    }
  }

  void signOut() {
    emit(const AdminAuthInitial());
  }
}
