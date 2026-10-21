import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/compound.dart';
import '../../../home/domain/entities/developer.dart';
import '../../../home/domain/entities/filter_options.dart';
import '../../../home/domain/entities/offer.dart';
import '../../domain/entities/admin_commission.dart';
import '../../domain/entities/admin_registration.dart';
import '../../domain/entities/admin_viewing_request.dart';
import '../../domain/entities/admin_withdrawal.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remoteDataSource);

  final AdminRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<AdminRegistration>>> getRegistrations() async {
    try {
      final result = await _remoteDataSource.getRegistrations();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRegistrationStatus(String id, String status) async {
    try {
      await _remoteDataSource.updateRegistrationStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRegistration(String id) async {
    try {
      await _remoteDataSource.deleteRegistration(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Compound>>> getCompounds() async {
    try {
      final result = await _remoteDataSource.getCompounds();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveCompound(Compound compound, {bool isNew = false}) async {
    try {
      await _remoteDataSource.saveCompound(compound, isNew: isNew);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCompound(String id) async {
    try {
      await _remoteDataSource.deleteCompound(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Developer>>> getDevelopers() async {
    try {
      final result = await _remoteDataSource.getDevelopers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDeveloper({
    String? id,
    required String name,
    String? logoUrl,
    String? description,
    String? phone,
    String? whatsapp,
    int order = 0,
  }) async {
    try {
      await _remoteDataSource.saveDeveloper(
        id: id,
        name: name,
        logoUrl: logoUrl,
        description: description,
        phone: phone,
        whatsapp: whatsapp,
        order: order,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeveloper(String id) async {
    try {
      await _remoteDataSource.deleteDeveloper(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminViewingRequest>>> getViewingRequests() async {
    try {
      final result = await _remoteDataSource.getViewingRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateViewingRequestStatus(String id, String status) async {
    try {
      await _remoteDataSource.updateViewingRequestStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminCommission>>> getCommissions() async {
    try {
      final result = await _remoteDataSource.getCommissions();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCommissionStatus(String id, String status) async {
    try {
      await _remoteDataSource.updateCommissionStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Offer>>> getOffers() async {
    try {
      final result = await _remoteDataSource.getOffers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveOffer({
    String? id,
    required String title,
    String? imageUrl,
    int order = 0,
  }) async {
    try {
      await _remoteDataSource.saveOffer(
        id: id,
        title: title,
        imageUrl: imageUrl,
        order: order,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOffer(String id) async {
    try {
      await _remoteDataSource.deleteOffer(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminWithdrawal>>> getWithdrawals() async {
    try {
      final result = await _remoteDataSource.getWithdrawals();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWithdrawalStatus(String id, String status) async {
    try {
      await _remoteDataSource.updateWithdrawalStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> grantCommission({
    required String brokerId,
    required double amount,
    required String title,
    required String status,
  }) async {
    try {
      await _remoteDataSource.grantCommission(
        brokerId: brokerId,
        amount: amount,
        title: title,
        status: status,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendNotification({
    required String title,
    required String body,
    String? brokerId,
  }) async {
    try {
      await _remoteDataSource.sendBroadcastNotification(
        title: title,
        body: body,
        brokerId: brokerId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FilterOptions>> getFilterOptions() async {
    try {
      final result = await _remoteDataSource.getFilterOptions();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveFilterOptions(FilterOptions options) async {
    try {
      await _remoteDataSource.saveFilterOptions(options);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(String filePath, {String? folder}) async {
    try {
      final result = await _remoteDataSource.uploadImage(filePath, folder: folder);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
