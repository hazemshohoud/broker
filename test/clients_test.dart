import 'package:broker/core/error/failures.dart';
import 'package:broker/features/clients/domain/entities/broker_client.dart';
import 'package:broker/features/clients/domain/repositories/clients_repository.dart';
import 'package:broker/features/clients/domain/usecases/add_client.dart';
import 'package:broker/features/clients/domain/usecases/delete_client.dart';
import 'package:broker/features/clients/domain/usecases/get_clients.dart';
import 'package:broker/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

final _date = DateTime(2026);

BrokerClient _client(String id, String name) => BrokerClient(
  id: id,
  brokerId: 'b1',
  name: name,
  phone: '01011112222',
  interest: 'مدن',
  createdAt: _date,
);

class _FakeRepository implements ClientsRepository {
  final clients = <BrokerClient>[];
  List<String> compoundNames = const ['مدن', 'ماونتن فيو'];
  bool failAdd = false;

  @override
  Future<Either<Failure, List<BrokerClient>>> getClients() async =>
      Right(List.of(clients));

  @override
  Future<Either<Failure, List<String>>> getCompoundNames() async =>
      Right(compoundNames);

  @override
  Future<Either<Failure, Unit>> addClient({
    required String name,
    required String phone,
    required String interest,
    String? note,
  }) async {
    if (failAdd) return const Left(ServerFailure('فشل'));
    clients.add(
      BrokerClient(
        id: 'c${clients.length}',
        brokerId: 'b1',
        name: name,
        phone: phone,
        interest: interest,
        note: note,
        createdAt: _date,
      ),
    );
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteClient(String clientId) async {
    clients.removeWhere((client) => client.id == clientId);
    return const Right(unit);
  }
}

ClientsCubit _cubit(_FakeRepository repo) => ClientsCubit(
  getClients: GetClients(repo),
  getCompoundNames: GetCompoundNames(repo),
  addClient: AddClient(repo),
  deleteClient: DeleteClient(repo),
);

void main() {
  group('AddClient usecase', () {
    test('trims fields and drops empty note', () async {
      final repo = _FakeRepository();
      await AddClient(repo)(
        const AddClientParams(
          name: '  أحمد  ',
          phone: ' 01011112222 ',
          interest: ' مدن ',
          note: '   ',
        ),
      );
      final client = repo.clients.single;
      expect(client.name, 'أحمد');
      expect(client.phone, '01011112222');
      expect(client.interest, 'مدن');
      expect(client.note, isNull);
    });
  });

  group('ClientsCubit', () {
    test('add reloads the list; failure surfaces error', () async {
      final repo = _FakeRepository();
      final cubit = _cubit(repo);

      await cubit.load();
      expect(cubit.state.clients, isEmpty);

      await cubit.addClient(
        const AddClientParams(
          name: 'أحمد',
          phone: '01011112222',
          interest: 'مدن',
        ),
      );
      expect(cubit.state.addStatus, AddClientStatus.success);
      expect(cubit.state.clients.single.name, 'أحمد');

      repo.failAdd = true;
      await cubit.addClient(
        const AddClientParams(
          name: 'سارة',
          phone: '01033334444',
          interest: 'سوديك',
        ),
      );
      expect(cubit.state.addStatus, AddClientStatus.failure);
      expect(cubit.state.addError, 'فشل');
      expect(cubit.state.clients, hasLength(1));
    });

    test('delete removes the client locally', () async {
      final repo = _FakeRepository()..clients.add(_client('c1', 'أحمد'));
      final cubit = _cubit(repo);

      await cubit.load();
      expect(cubit.state.clients, hasLength(1));

      await cubit.deleteClient('c1');
      expect(cubit.state.clients, isEmpty);
    });

    test('search filters clients by name, phone, or interest', () async {
      final repo = _FakeRepository()
        ..clients.addAll([
          BrokerClient(
            id: 'c1',
            brokerId: 'b1',
            name: 'أحمد محمود',
            phone: '01011112222',
            interest: 'بادية بالم هيلز',
            note: 'مهتم بالفيلا',
            createdAt: _date,
          ),
          BrokerClient(
            id: 'c2',
            brokerId: 'b1',
            name: 'سارة إبراهيم',
            phone: '01155556666',
            interest: 'سوديك إيست',
            createdAt: _date,
          ),
        ]);
      final cubit = _cubit(repo);
      await cubit.load();

      expect(cubit.state.clients, hasLength(2));
      expect(cubit.state.filteredClients, hasLength(2));

      // بحث بالاسم
      cubit.updateSearchQuery('أحمد');
      expect(cubit.state.filteredClients, hasLength(1));
      expect(cubit.state.filteredClients.first.name, 'أحمد محمود');

      // بحث برقم الهاتف
      cubit.updateSearchQuery('01155');
      expect(cubit.state.filteredClients, hasLength(1));
      expect(cubit.state.filteredClients.first.name, 'سارة إبراهيم');

      // بحث باسم المشروع أو الاهتمام
      cubit.updateSearchQuery('بادية');
      expect(cubit.state.filteredClients, hasLength(1));
      expect(cubit.state.filteredClients.first.interest, 'بادية بالم هيلز');

      // بحث بالملاحظات
      cubit.updateSearchQuery('فيلا');
      expect(cubit.state.filteredClients, hasLength(1));

      // مسح البحث
      cubit.clearSearch();
      expect(cubit.state.filteredClients, hasLength(2));
    });
  });
}
