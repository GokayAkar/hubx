import 'package:equatable/equatable.dart';

/// A group of plants the user can browse.
class PlantCategory extends Equatable {
  const PlantCategory({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String imageUrl;

  @override
  List<Object?> get props => [id, title, imageUrl];
}
