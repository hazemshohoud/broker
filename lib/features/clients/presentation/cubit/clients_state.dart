part of 'clients_cubit.dart';

enum ClientsStatus { loading, success, failure }

enum AddClientStatus { idle, submitting, success, failure }

class ClientsState extends Equatable {
  const ClientsState({
    this.status = ClientsStatus.loading,
    this.clients = const [],
    this.searchQuery = '',
    this.compoundNames,
    this.addStatus = AddClientStatus.idle,
    this.errorMessage,
    this.addError,
  });

  final ClientsStatus status;
  final List<BrokerClient> clients;
  final String searchQuery;
  final List<String>? compoundNames;
  final AddClientStatus addStatus;
  final String? errorMessage;
  final String? addError;

  /// تصفية العملاء وفقاً لنص البحث (مطابقة بالاسم، الهاتف، المشروع/الاهتمام، أو الملاحظة).
  List<BrokerClient> get filteredClients {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return clients;
    final cleanDigitsQuery = query.replaceAll(RegExp(r'[\s\-\+]'), '');
    return clients.where((client) {
      final name = client.name.toLowerCase();
      final phone = client.phone.replaceAll(RegExp(r'[\s\-\+]'), '').toLowerCase();
      final interest = client.interest.toLowerCase();
      final note = (client.note ?? '').toLowerCase();
      return name.contains(query) ||
          phone.contains(cleanDigitsQuery.isNotEmpty ? cleanDigitsQuery : query) ||
          interest.contains(query) ||
          note.contains(query);
    }).toList();
  }

  ClientsState copyWith({
    ClientsStatus? status,
    List<BrokerClient>? clients,
    String? searchQuery,
    List<String>? compoundNames,
    AddClientStatus? addStatus,
    String? errorMessage,
    String? addError,
  }) => ClientsState(
    status: status ?? this.status,
    clients: clients ?? this.clients,
    searchQuery: searchQuery ?? this.searchQuery,
    compoundNames: compoundNames ?? this.compoundNames,
    addStatus: addStatus ?? this.addStatus,
    errorMessage: errorMessage ?? this.errorMessage,
    addError: addError,
  );

  @override
  List<Object?> get props => [
    status,
    clients,
    searchQuery,
    compoundNames,
    addStatus,
    errorMessage,
    addError,
  ];
}
