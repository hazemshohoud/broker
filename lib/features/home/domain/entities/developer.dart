import 'package:equatable/equatable.dart';

class Developer extends Equatable {
  const Developer({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    this.phone,
    this.whatsapp,
    this.order = 0,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final String? phone;
  final String? whatsapp;
  final int order;

  @override
  List<Object?> get props => [id, name, logoUrl, description, phone, whatsapp, order];
}
