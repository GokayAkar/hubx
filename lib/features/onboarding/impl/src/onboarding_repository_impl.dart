part of '../onboarding_impl.dart';

class _OnboardingRepositoryImpl implements OnboardingRepository {
  const _OnboardingRepositoryImpl(this._storage);

  static const _completed = StorageKey<bool>('completed');

  final KeyValueStorage _storage;

  @override
  Future<bool> isCompleted() async => await _storage.read(_completed) ?? false;

  @override
  Future<void> markCompleted() => _storage.write(_completed, true);
}
