import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Guard tests - no empty callbacks', () {
    final libDir = Directory('lib');

    test('No empty onTap/onPressed callbacks', () {
      final violations = <String>[];
      final dartFiles = _findDartFiles(libDir);

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          final lineNumber = i + 1;

          // Check for empty onTap callbacks
          if (_hasEmptyCallback(line, 'onTap') ||
              _hasEmptyCallback(line, 'onPressed') ||
              _hasEmptyCallback(line, 'onChanged') ||
              _hasEmptyCallback(line, 'onSubmitted') ||
              _hasEmptyCallback(line, 'onTapUp') ||
              _hasEmptyCallback(line, 'onTapDown') ||
              _hasEmptyCallback(line, 'onLongPress') ||
              _hasEmptyCallback(line, 'onDoubleTap')) {
            violations.add('${file.path}:$lineNumber - Empty callback: $line');
          }

          // Check for null onPressed on non-disabled buttons
          if (_hasNullOnPressed(line)) {
            violations.add('${file.path}:$lineNumber - Null onPressed: $line');
          }

          // Check for TODO: Implement
          if (line.contains('TODO: Implement') ||
              line.contains('TODO: implement')) {
            violations.add(
              '${file.path}:$lineNumber - TODO: Implement found: $line',
            );
          }
        }
      }

      if (violations.isNotEmpty) {
        final message =
            'Found ${violations.length} violations:\n${violations.join('\n')}';
        fail(message);
      }
    });
  });
}

List<File> _findDartFiles(Directory dir) {
  final files = <File>[];
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Skip generated files
      if (!entity.path.contains('.g.dart') &&
          !entity.path.contains('.freezed.dart')) {
        files.add(entity);
      }
    }
  }
  return files;
}

bool _hasEmptyCallback(String line, String callbackName) {
  // Match patterns like: onTap: () {}, onPressed: () => {}, onChanged: (_) {}
  final pattern = RegExp(
    r'$callbackName\s*:\s*\(\s*\)\s*=>\s*\{\s*\}|$callbackName\s*:\s*\(\s*\)\s*\{\s*\}|$callbackName\s*:\s*\(\s*[^)]*\s*\)\s*=>\s*\{\s*\}|$callbackName\s*:\s*\(\s*[^)]*\s*\)\s*\{\s*\}',
  );
  return pattern.hasMatch(line);
}

bool _hasNullOnPressed(String line) {
  // Match onPressed: null but not when the widget is explicitly disabled
  // This is a heuristic - we flag onPressed: null unless there's an enabled: false nearby
  if (!line.contains('onPressed: null')) return false;

  // Allow if the line also has enabled: false
  if (line.contains('enabled: false')) return false;

  return true;
}
