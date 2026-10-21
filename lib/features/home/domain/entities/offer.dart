import 'package:equatable/equatable.dart';

class Offer extends Equatable {
  const Offer({required this.id, required this.title, this.imageUrl});

  final String id;
  final String title;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, title, imageUrl];
}
