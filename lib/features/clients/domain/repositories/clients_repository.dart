import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/broker_client.dart';

abstract class ClientsRepository {
  /// عملاء الوسيط الحالي.
  Future<Either<Failure, List<BrokerClient>>> getClients();

  /// أسماء الكمبوندات — اقتراحات لحقل "كان مهتم بـ".
  Future<Either<Failure, List<String>>> getCompoundNames();

  Future<Either<Failure, Unit>> addClient({
    required String name,
    required String phone,
    required String interest,
    String? note,
  });

  Future<Either<Failure, Unit>> deleteClient(String clientId);
}
