part of '../home_impl.dart';

/// The two endpoints the home page reads.
///
/// Parsing lives here rather than on the models: the shape the server happens
/// to send is this layer's problem, and keeping it out of `api` means a change
/// at the far end cannot reach the rest of the app.
class _HomeService extends RemoteService {
  const _HomeService(super.dio, super.logger);

  Future<List<Question>> fetchQuestions() => get('/getQuestions', (json) {
    final items = (json! as List).cast<Map<String, Object?>>()
      // The server sends an `order` field; trusting it beats trusting the
      // order the list happened to arrive in.
      ..sort((a, b) => (a['order']! as int).compareTo(b['order']! as int));

    return [for (final item in items) _questionFrom(item)];
  });

  Future<ResultPage<PlantCategory>> fetchCategories({
    required int page,
    required int pageSize,
  }) => get('/getCategories', (json) {
    final body = json! as Map<String, Object?>;
    final items = (body['data']! as List).cast<Map<String, Object?>>();
    final pagination =
        (body['meta']! as Map<String, Object?>)['pagination']!
            as Map<String, Object?>;

    return ResultPage(
      items: [for (final item in items) _categoryFrom(item)],
      hasMore: (pagination['page']! as int) < (pagination['pageCount']! as int),
    );
  }, query: {'page': page, 'pageSize': pageSize});

  Question _questionFrom(Map<String, Object?> json) => Question(
    id: json['id']! as int,
    title: json['title']! as String,
    subtitle: json['subtitle']! as String,
    imageUrl: json['image_uri']! as String,
    articleUrl: json['uri']! as String,
  );

  PlantCategory _categoryFrom(Map<String, Object?> json) => PlantCategory(
    id: json['id']! as int,
    title: json['title']! as String,
    imageUrl: (json['image']! as Map<String, Object?>)['url']! as String,
  );
}
