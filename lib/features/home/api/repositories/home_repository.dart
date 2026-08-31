import 'package:hubx/features/home/api/models/plant_category.dart';
import 'package:hubx/features/home/api/models/question.dart';
import 'package:hubx/features/home/api/models/result_page.dart';

/// What the home page shows.
abstract interface class HomeRepository {
  /// The promoted articles, in the order the server wants them shown.
  Future<List<Question>> fetchQuestions();

  /// One page of plant categories, [page] counting from 1.
  Future<ResultPage<PlantCategory>> fetchCategories({
    required int page,
    required int pageSize,
  });
}
