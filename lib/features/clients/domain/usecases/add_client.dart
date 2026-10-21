import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/clients_repository.dart';

class AddClient extends UseCase<Unit, AddClientParams> {
  AddClient(this._repository);

  final ClientsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AddClientParams params) =>
      _repository.addClient(
        name: params.name.trim(),
        phone: params.phone.trim(),
        interest: params.interest.trim(),
        note: params.note?.trim().isEmpty ?? true ? null : params.note!.trim(),
      );
}

class AddClientParams extends Equatable {
  const AddClientParams({
    required this.name,
    required this.phone,
    required this.interest,
    this.note,
  });

  final String name;
  final String phone;
  final String interest;
  final String? note;

  @override
  List<Object?> get props => [name, phone, interest, note];
}
