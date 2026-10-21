import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/current_user.dart';
import '../../../auth/domain/usecases/sign_out.dart';
import '../../domain/entities/broker_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_payout_details.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({
    required GetProfile getProfile,
    required SignOut signOut,
    required UpdatePayoutDetails updatePayoutDetails,
  })  : _getProfile = getProfile,
        _signOut = signOut,
        _updatePayoutDetails = updatePayoutDetails,
        super(const AccountState());

  final GetProfile _getProfile;
  final SignOut _signOut;
  final UpdatePayoutDetails _updatePayoutDetails;

  Future<void> load() async {
    final result = await _getProfile(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AccountStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) {
        CurrentUserHolder.cachedUserName = profile.fullName;
        CurrentUserHolder.cachedPhotoUrl = profile.photoUrl;
        emit(state.copyWith(status: AccountStatus.success, profile: profile));
      },
    );
  }

  Future<void> signOut() async {
    await _signOut(const NoParams());
    emit(state.copyWith(status: AccountStatus.signedOut));
  }

  Future<bool> savePayoutDetails({
    String? instaPayNumber,
    String? walletNumber,
  }) async {
    final result = await _updatePayoutDetails(
      UpdatePayoutParams(
        instaPayNumber: instaPayNumber,
        walletNumber: walletNumber,
      ),
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: AccountStatus.failure,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) async {
        await load();
        return true;
      },
    );
  }
}
