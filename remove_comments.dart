// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ No "lib" folder found in current directory.');
    return;
  }

  print('🔍 Removing comments from Dart files in lib/...');

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await _processFile(entity);
    }
  }

  print('✅ All comments removed successfully!');
}

Future<void> _processFile(File file) async {
  try {
    String content = await file.readAsString();

    // Skip files that don't contain comment patterns
    if (!content.contains('//') && !content.contains('/*')) return;

    // Remove all comments safely
    final newContent = _removeComments(content);

    if (content != newContent) {
      await file.writeAsString(newContent);
      print('✏️ Updated: ${file.path}');
    }
  } catch (e) {
    print('⚠️ Error processing ${file.path}: $e');
  }
}

/// Removes single-line and block comments from Dart source code.
String _removeComments(String code) {
  // 1️⃣ Preserve string literals (so we don’t remove // inside them)
  final stringLiterals = <String>[];
  final stringPattern = RegExp(r'''(["']{1,3})(?:(?!\1)[\s\S])*?\1''');

  String placeholderCode = code.replaceAllMapped(stringPattern, (match) {
    stringLiterals.add(match.group(0)!);
    return '___STRING_LITERAL_${stringLiterals.length - 1}___';
  });

  // 2️⃣ Remove all block comments (/* ... */)
  placeholderCode = placeholderCode.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

  // 3️⃣ Remove all single-line comments (// ...)
  placeholderCode = placeholderCode.replaceAll(RegExp(r'//.*(?=\n|$)'), '');

  // 4️⃣ Restore string literals
  for (int i = 0; i < stringLiterals.length; i++) {
    placeholderCode = placeholderCode.replaceAll(
      '___STRING_LITERAL_${i}___',
      stringLiterals[i],
    );
  }

  // 5️⃣ Clean up extra blank lines
  placeholderCode = placeholderCode.replaceAll(RegExp(r'\n\s*\n+'), '\n\n');

  return '${placeholderCode.trim()}\n';
}
