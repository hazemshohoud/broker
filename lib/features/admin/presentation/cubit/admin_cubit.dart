import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/compound.dart';
import '../../../home/domain/entities/filter_options.dart';
import '../../domain/entities/admin_registration.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends BlocBase<AdminState> {
  AdminCubit(this._repository) : super(const AdminState());

  final AdminRepository _repository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: AdminStatus.loading));
    final regRes = await _repository.getRegistrations();
    final compRes = await _repository.getCompounds();
    final devRes = await _repository.getDevelopers();
    final offRes = await _repository.getOffers();
    final withRes = await _repository.getWithdrawals();
    final filRes = await _repository.getFilterOptions();
    final viewRes = await _repository.getViewingRequests();
    final commRes = await _repository.getCommissions();

    emit(
      state.copyWith(
        status: AdminStatus.success,
        registrations: regRes.fold((_) => state.registrations, (r) => r),
        compounds: compRes.fold((_) => state.compounds, (c) => c),
        developers: devRes.fold((_) => state.developers, (d) => d),
        offers: offRes.fold((_) => state.offers, (o) => o),
        withdrawals: withRes.fold((_) => state.withdrawals, (w) => w),
        filterOptions: filRes.fold((_) => state.filterOptions, (f) => f),
        viewingRequests: viewRes.fold((_) => state.viewingRequests, (v) => v),
        commissions: commRes.fold((_) => state.commissions, (c) => c),
      ),
    );
  }

  Future<void> loadRegistrations() async {
    final result = await _repository.getRegistrations();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (registrations) => emit(state.copyWith(registrations: registrations)),
    );
  }

  Future<bool> updateRegistrationStatus(String id, String status) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.updateRegistrationStatus(id, status);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        final updated = state.registrations.map((r) {
          if (r.id == id) {
            return AdminRegistration(
              id: r.id,
              fullName: r.fullName,
              birthDate: r.birthDate,
              governorate: r.governorate,
              phone: r.phone,
              whatsapp: r.whatsapp,
              status: status,
              createdAt: r.createdAt,
              instaPayNumber: r.instaPayNumber,
              walletNumber: r.walletNumber,
              photoUrl: r.photoUrl,
            );
          }
          return r;
        }).toList();
        emit(
          state.copyWith(
            isSaving: false,
            registrations: updated,
            actionMessage: status == 'approved' ? 'تم اعتماد الحساب بنجاح' : 'تم تحديث حالة الحساب',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> deleteRegistration(String id) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.deleteRegistration(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        final updated = state.registrations.where((r) => r.id != id).toList();
        emit(
          state.copyWith(
            isSaving: false,
            registrations: updated,
            actionMessage: 'تم حذف طلب التسجيل بنجاح',
          ),
        );
        return true;
      },
    );
  }

  Future<void> loadCompounds() async {
    final result = await _repository.getCompounds();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (compounds) => emit(state.copyWith(compounds: compounds)),
    );
  }

  Future<bool> saveCompound(Compound compound, {bool isNew = false}) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.saveCompound(compound, isNew: isNew);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: isNew ? 'تمت إضافة الكمبوند بنجاح' : 'تم تحديث بيانات الكمبوند بنجاح',
          ),
        );
        loadCompounds();
        return true;
      },
    );
  }

  Future<bool> deleteCompound(String id) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.deleteCompound(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        final updated = state.compounds.where((c) => c.id != id).toList();
        emit(
          state.copyWith(
            isSaving: false,
            compounds: updated,
            actionMessage: 'تم حذف الكمبوند بنجاح',
          ),
        );
        return true;
      },
    );
  }

  Future<void> loadDevelopers() async {
    final result = await _repository.getDevelopers();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (developers) => emit(state.copyWith(developers: developers)),
    );
  }

  Future<bool> saveDeveloper({
    String? id,
    required String name,
    String? logoUrl,
    String? description,
    String? phone,
    String? whatsapp,
    int order = 0,
  }) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.saveDeveloper(
      id: id,
      name: name,
      logoUrl: logoUrl,
      description: description,
      phone: phone,
      whatsapp: whatsapp,
      order: order,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: 'تم حفظ المطور العقاري بنجاح',
          ),
        );
        loadDevelopers();
        return true;
      },
    );
  }

  Future<void> loadViewingRequests() async {
    final result = await _repository.getViewingRequests();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (requests) => emit(state.copyWith(viewingRequests: requests)),
    );
  }

  Future<bool> updateViewingRequestStatus(String id, String status) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.updateViewingRequestStatus(id, status);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: 'تم تحديث حالة طلب المعاينة بنجاح',
          ),
        );
        loadViewingRequests();
        return true;
      },
    );
  }

  Future<void> loadCommissions() async {
    final result = await _repository.getCommissions();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (commissions) => emit(state.copyWith(commissions: commissions)),
    );
  }

  Future<bool> updateCommissionStatus(String id, String status) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.updateCommissionStatus(id, status);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: status == 'approved' ? 'تم اعتماد العمولة بنجاح' : 'تم تحديث حالة العمولة',
          ),
        );
        loadCommissions();
        return true;
      },
    );
  }

  Future<bool> deleteDeveloper(String id) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.deleteDeveloper(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        final updated = state.developers.where((d) => d.id != id).toList();
        emit(
          state.copyWith(
            isSaving: false,
            developers: updated,
            actionMessage: 'تم حذف المطور العقاري بنجاح',
          ),
        );
        return true;
      },
    );
  }

  Future<void> loadOffers() async {
    final result = await _repository.getOffers();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (offers) => emit(state.copyWith(offers: offers)),
    );
  }

  Future<bool> saveOffer({
    String? id,
    required String title,
    String? imageUrl,
    int order = 0,
  }) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.saveOffer(
      id: id,
      title: title,
      imageUrl: imageUrl,
      order: order,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: 'تم حفظ العرض بنجاح',
          ),
        );
        loadOffers();
        return true;
      },
    );
  }

  Future<bool> deleteOffer(String id) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.deleteOffer(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        final updated = state.offers.where((o) => o.id != id).toList();
        emit(
          state.copyWith(
            isSaving: false,
            offers: updated,
            actionMessage: 'تم حذف العرض بنجاح',
          ),
        );
        return true;
      },
    );
  }

  Future<void> loadWithdrawals() async {
    final result = await _repository.getWithdrawals();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (withdrawals) => emit(state.copyWith(withdrawals: withdrawals)),
    );
  }

  Future<bool> updateWithdrawalStatus(String id, String status) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.updateWithdrawalStatus(id, status);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: status == 'completed' ? 'تم تأكيد تحويل المبلغ للوسيط' : 'تم رفض طلب السحب',
          ),
        );
        loadWithdrawals();
        return true;
      },
    );
  }

  Future<bool> grantCommission({
    required String brokerId,
    required double amount,
    required String title,
    required String status,
  }) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.grantCommission(
      brokerId: brokerId,
      amount: amount,
      title: title,
      status: status,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: 'تم إسناد العمولة للوسيط بنجاح',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> sendNotification({
    required String title,
    required String body,
    String? brokerId,
  }) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.sendNotification(
      title: title,
      body: body,
      brokerId: brokerId,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionMessage: 'تم إرسال الإشعار بنجاح',
          ),
        );
        return true;
      },
    );
  }

  Future<void> loadFilterOptions() async {
    final result = await _repository.getFilterOptions();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (options) => emit(state.copyWith(filterOptions: options)),
    );
  }

  Future<bool> saveFilterOptions(FilterOptions options) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.saveFilterOptions(options);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            filterOptions: options,
            actionMessage: 'تم تحديث خيارات التصفية والمناطق بنجاح',
          ),
        );
        return true;
      },
    );
  }

  Future<String?> uploadImage(String filePath, {String? folder}) async {
    final result = await _repository.uploadImage(filePath, folder: folder);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (url) => url,
    );
  }
}
