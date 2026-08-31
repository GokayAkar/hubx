part of '../home_impl.dart';

/// The two endpoints the home page reads.
///
/// Endpoints and parsers, and nothing else: the shapes themselves are in
/// `home_dtos.dart`, and the error translation is `RemoteService`'s.
class _HomeService extends RemoteService {
  const _HomeService(super.dio, super.logger);

  Future<List<Question>> fetchQuestions() => get('/getQuestions', (json) {
    final items = [
      for (final item in json! as List)
        _QuestionDto.fromJson(item as Map<String, dynamic>),
    ]..sort((a, b) => a.order.compareTo(b.order));

    return [for (final item in items) item.toDomain()];
  });

  Future<ResultPage<PlantCategory>> fetchCategories({
    required int page,
    required int pageSize,
  }) => get(
    '/getCategories',
    (json) =>
        _CategoryPageDto.fromJson(json! as Map<String, dynamic>).toDomain(),
    query: {'page': page, 'pageSize': pageSize},
  );
}
