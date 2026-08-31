/// Paths other features navigate to, without seeing this feature's widgets.
abstract final class HomeRoutes {
  static const root = '/home';

  /// What a card on the home page opens into. Pushed with arguments rather
  /// than reached by path, so it carries no id of its own.
  static const detail = '/detail';
}
