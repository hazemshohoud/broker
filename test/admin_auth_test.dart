import 'package:broker/features/admin/presentation/cubit/admin_auth_cubit.dart';
import 'package:broker/features/admin/presentation/cubit/admin_auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminAuthCubit', () {
    late AdminAuthCubit cubit;

    setUp(() {
      cubit = AdminAuthCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is AdminAuthInitial', () {
      expect(cubit.state, const AdminAuthInitial());
    });

    test('emits authenticated when valid credentials are provided', () async {
      final future = cubit.signIn(
        phone: '01088888888',
        password: '88888888',
      );

      expect(cubit.state, const AdminAuthLoading());
      await future;

      expect(
        cubit.state,
        const AdminAuthAuthenticated(phone: '01088888888'),
      );
    });

    test('accepts 4-digit PIN 8888', () async {
      await cubit.signIn(
        phone: '01088888888',
        password: '8888',
      );

      expect(
        cubit.state,
        const AdminAuthAuthenticated(phone: '01088888888'),
      );
    });

    test('accepts alternate admin phone 01000000000', () async {
      await cubit.signIn(
        phone: '01000000000',
        password: '88888888',
      );

      expect(
        cubit.state,
        const AdminAuthAuthenticated(phone: '01000000000'),
      );
    });

    test('emits failure when password is wrong', () async {
      await cubit.signIn(
        phone: '01088888888',
        password: 'wrong_password',
      );

      expect(cubit.state, isA<AdminAuthFailure>());
    });

    test('emits failure when phone is wrong', () async {
      await cubit.signIn(
        phone: '01012345678',
        password: '88888888',
      );

      expect(cubit.state, isA<AdminAuthFailure>());
    });

    test('signOut resets state to AdminAuthInitial', () async {
      await cubit.signIn(
        phone: '01088888888',
        password: '88888888',
      );
      expect(cubit.state, isA<AdminAuthAuthenticated>());

      cubit.signOut();
      expect(cubit.state, const AdminAuthInitial());
    });
  });
}
