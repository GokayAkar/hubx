import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/home/ui/home_ui.dart';

void main() {
  group('HomeBloc', () {
    blocTest<HomeBloc, HomeState>(
      'counts taps',
      build: HomeBloc.new,
      act: (bloc) => bloc
        ..add(const HomeTapped())
        ..add(const HomeTapped()),
      expect: () => const [HomeState(count: 1), HomeState(count: 2)],
    );

    test('is registered as a factory, not a singleton', () async {
      await DependencyProvider.reset();
      registerHomeUi();

      expect(
        DependencyProvider.get<HomeBloc>(),
        isNot(same(DependencyProvider.get<HomeBloc>())),
      );
    });
  });
}
