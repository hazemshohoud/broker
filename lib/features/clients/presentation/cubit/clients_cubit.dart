import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/broker_client.dart';
import '../../domain/usecases/add_client.dart';
import '../../domain/usecases/delete_client.dart';
import '../../domain/usecases/get_clients.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit({
    required GetClients getClients,
    required GetCompoundNames getCompoundNames,
    required AddClient addClient,
    required DeleteClient deleteClient,
  }) : _getClients = getClients,
       _getCompoundNames = getCompoundNames,
       _addClient = addClient,
       _deleteClient = deleteClient,
       super(const ClientsState());

  final GetClients _getClients;
  final GetCompoundNames _getCompoundNames;
  final AddClient _addClient;
  final DeleteClient _deleteClient;

  Future<void> load() async {
    if (state.status == ClientsStatus.failure) {
      emit(state.copyWith(status: ClientsStatus.loading));
    }
    final result = await _getClients(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (clients) =>
          emit(state.copyWith(status: ClientsStatus.success, clients: clients)),
    );
  }

  /// أسماء الكمبوندات لاقتراحات حقل الاهتمام — بتتجاب مرة وتتخزن في الستيت.
  Future<void> loadCompoundNames() async {
    if (state.compoundNames != null) return;
    final result = await _getCompoundNames(const NoParams());
    result.fold(
      // الاقتراحات اختيارية — الفشل مش بيمنع إضافة عميل.
      (_) {},
      (names) => emit(state.copyWith(compoundNames: names)),
    );
  }

  Future<void> addClient(AddClientParams params) async {
    emit(state.copyWith(addStatus: AddClientStatus.submitting));
    final result = await _addClient(params);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          addStatus: AddClientStatus.failure,
          addError: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(addStatus: AddClientStatus.success));
        await load();
      },
    );
  }

  Future<void> deleteClient(String clientId) async {
    final result = await _deleteClient(clientId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          clients: state.clients
              .where((client) => client.id != clientId)
              .toList(),
        ),
      ),
    );
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
  }

  void resetAddStatus() =>
      emit(state.copyWith(addStatus: AddClientStatus.idle, addError: null));
}
