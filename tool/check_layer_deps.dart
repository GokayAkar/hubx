// Fails when an implementation library is imported outside the composition
// root. Dart's own privacy already hides the classes inside `impl/src/`; this
// only guards the remaining hole — the `register*` entry points themselves.
//
// Run with: dart run tool/check_layer_deps.dart
import 'dart:io';

/// Files allowed to import an `impl/` library: the composition root.
const _allowedPrefixes = ['lib/app/di/'];

/// Matches any import, so relative paths are caught as well as package URIs.
final _import = RegExp(r"""import\s+'([^']+)'""");

Future<void> main() async {
  final violations = <String>[];

  await for (final entity in Directory('lib').list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final path = entity.path;
    if (_allowedPrefixes.any(path.startsWith)) continue;

    for (final match in _import.allMatches(entity.readAsStringSync())) {
      final uri = match.group(1)!;
      if (!uri.contains('impl/')) continue;
      // Another package's internals are its own business.
      if (uri.startsWith('package:') && !uri.startsWith('package:hubx/')) {
        continue;
      }
      violations.add('$path -> $uri');
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Layer check passed.');
    return;
  }

  stderr
    ..writeln(
      'Implementation libraries may only be imported from '
      '${_allowedPrefixes.join(', ')}:',
    )
    ..writeln(violations.map((v) => '  $v').join('\n'));
  exitCode = 1;
}
