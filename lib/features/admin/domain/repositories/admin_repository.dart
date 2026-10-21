import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/compound.dart';
import '../../../home/domain/entities/developer.dart';
import '../../../home/domain/entities/filter_options.dart';
import '../../../home/domain/entities/offer.dart';
import '../entities/admin_commission.dart';
import '../entities/admin_registration.dart';
import '../entities/admin_viewing_request.dart';
import '../entities/admin_withdrawal.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<AdminRegistration>>> getRegistrations();
  Future<Either<Failure, void>> updateRegistrationStatus(String id, String status);
  Future<Either<Failure, void>> deleteRegistration(String id);

  Future<Either<Failure, List<Compound>>> getCompounds();
  Future<Either<Failure, void>> saveCompound(Compound compound, {bool isNew = false});
  Future<Either<Failure, void>> deleteCompound(String id);

  Future<Either<Failure, List<Developer>>> getDevelopers();
  Future<Either<Failure, void>> saveDeveloper({
    String? id,
    required String name,
    String? logoUrl,
    String? description,
    String? phone,
    String? whatsapp,
    int order = 0,
  });
  Future<Either<Failure, void>> deleteDeveloper(String id);

  Future<Either<Failure, List<AdminViewingRequest>>> getViewingRequests();
  Future<Either<Failure, void>> updateViewingRequestStatus(String id, String status);

  Future<Either<Failure, List<AdminCommission>>> getCommissions();
  Future<Either<Failure, void>> updateCommissionStatus(String id, String status);

  Future<Either<Failure, List<Offer>>> getOffers();
  Future<Either<Failure, void>> saveOffer({
    String? id,
    required String title,
    String? imageUrl,
    int order = 0,
  });
  Future<Either<Failure, void>> deleteOffer(String id);

  Future<Either<Failure, List<AdminWithdrawal>>> getWithdrawals();
  Future<Either<Failure, void>> updateWithdrawalStatus(String id, String status);

  Future<Either<Failure, void>> grantCommission({
    required String brokerId,
    required double amount,
    required String title,
    required String status,
  });

  Future<Either<Failure, void>> sendNotification({
    required String title,
    required String body,
    String? brokerId,
  });

  Future<Either<Failure, FilterOptions>> getFilterOptions();
  Future<Either<Failure, void>> saveFilterOptions(FilterOptions options);

  Future<Either<Failure, String>> uploadImage(String filePath, {String? folder});
}
