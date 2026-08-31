part of '../home_impl.dart';

class _HomeRepositoryImpl implements HomeRepository {
  const _HomeRepositoryImpl(this._service);

  final _HomeService _service;

  @override
  Future<List<Question>> fetchQuestions() => _service.fetchQuestions();

  @override
  Future<ResultPage<PlantCategory>> fetchCategories({
    required int page,
    required int pageSize,
  }) => _service.fetchCategories(page: page, pageSize: pageSize);
}
