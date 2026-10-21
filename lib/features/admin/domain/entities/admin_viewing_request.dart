import 'package:equatable/equatable.dart';

class AdminViewingRequest extends Equatable {
  const AdminViewingRequest({
    required this.id,
    this.brokerId,
    required this.brokerName,
    this.brokerPhone,
    this.brokerEmail,
    this.compoundId,
    required this.compoundName,
    this.developerName,
    this.location,
    required this.clientName,
    required this.clientPhone,
    required this.viewingDate,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String? brokerId;
  final String brokerName;
  final String? brokerPhone;
  final String? brokerEmail;
  final String? compoundId;
  final String compoundName;
  final String? developerName;
  final String? location;
  final String clientName;
  final String clientPhone;
  final DateTime viewingDate;
  final String? notes;
  final String status;
  final DateTime createdAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  @override
  List<Object?> get props => [
    id,
    brokerId,
    brokerName,
    brokerPhone,
    brokerEmail,
    compoundId,
    compoundName,
    developerName,
    location,
    clientName,
    clientPhone,
    viewingDate,
    notes,
    status,
    createdAt,
  ];
}
