import 'package:equatable/equatable.dart';

/// One page of a collection that arrives a slice at a time.
///
/// [hasMore] comes from the server's own count rather than from the length of
/// [items], so the last page costs one request instead of two: a client that
/// guesses "a full page means there may be another" always asks once more and
/// gets nothing back.
///
/// Named for the page of results, not `Page` — Flutter already has one of
/// those, and a route and a slice of a list are not the same thing.
class ResultPage<T> extends Equatable {
  const ResultPage({required this.items, required this.hasMore});

  const ResultPage.last(this.items) : hasMore = false;

  final List<T> items;
  final bool hasMore;

  @override
  List<Object?> get props => [items, hasMore];
}
