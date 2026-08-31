import 'package:equatable/equatable.dart';

/// An article promoted on the home page.
class Question extends Equatable {
  const Question({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.articleUrl,
  });

  final int id;
  final String title;

  /// The band the article belongs to — "Life Style", "Plant Identify".
  final String subtitle;

  final String imageUrl;

  /// Where the article lives on the web. Not opened yet; the detail screen
  /// stands in for it.
  final String articleUrl;

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, articleUrl];
}
