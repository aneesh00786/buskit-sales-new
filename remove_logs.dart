import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  await processDirectory(libDir);
}

Future<void> processDirectory(Directory directory) async {
  await for (final entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await processFile(entity);
    }
  }
}

Future<void> processFile(File file) async {
  try {
    String content = await file.readAsString();
    
    // Skip files that don't contain log or print statements
    if (!content.contains('print(') && 
        !content.contains('debugPrint(') && 
        !content.contains('log(') && 
        !content.contains('logger.')) {
      return;
    }
    
    // Parse the file to identify and remove log/print statements
    final lines = content.split('\n');
    final newLines = <String>[];
    
    bool inCatchBlock = false;
    List<String> catchBlockLines = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();
      
      // Check if we're entering a catch block
      if (trimmedLine.startsWith('catch') && trimmedLine.contains('{')) {
        inCatchBlock = true;
        catchBlockLines = [];
      }
      
      // If we're in a catch block, collect lines
      if (inCatchBlock) {
        catchBlockLines.add(line);
        
        // Check if this line closes the catch block
        if (trimmedLine == '}') {
          // Process the catch block
          final processedCatchBlock = processCatchBlock(catchBlockLines);
          newLines.addAll(processedCatchBlock);
          inCatchBlock = false;
          catchBlockLines = [];
        }
      } else {
        // Not in a catch block, check if it's a log/print statement to remove
        if (shouldRemoveLine(trimmedLine)) {
          // Skip this line
        } else {
          newLines.add(line);
        }
      }
    }
    
    final newContent = newLines.join('\n');
    if (content != newContent) {
      await file.writeAsString(newContent);
    }
  } catch (e) {
      //
  }
}

List<String> processCatchBlock(List<String> catchBlockLines) {
  // If the catch block has only one statement and it's a log/print, replace with a comment
  if (catchBlockLines.length == 3) {
    final middleLine = catchBlockLines[1].trim();
    if (shouldRemoveLine(middleLine)) {
      final indent = catchBlockLines[0].indexOf('catch');
      catchBlockLines[1] = ' ' * indent + '  // Error handled silently';
    }
  } else {
    // Process each line in the catch block
    for (int i = 1; i < catchBlockLines.length - 1; i++) {
      final line = catchBlockLines[i];
      final trimmedLine = line.trim();
      if (shouldRemoveLine(trimmedLine)) {
        // Calculate the indentation
        final indent = line.indexOf(trimmedLine);
        catchBlockLines[i] = ' ' * indent + '// Removed log statement';
      }
    }
  }
  
  return catchBlockLines;
}

bool shouldRemoveLine(String line) {
  final trimmed = line.trim();

  // Regex patterns to precisely match standalone log/print calls
  final patterns = [
    RegExp(r'^\s*print\s*\(.*\)\s*;?\s*$'),
    RegExp(r'^\s*debugPrint\s*\(.*\)\s*;?\s*$'),
    RegExp(r'^\s*log\s*\(.*\)\s*;?\s*$'),
    RegExp(r'^\s*logger\..*\(.*\)\s*;?\s*$'),
  ];

  for (final pattern in patterns) {
    if (pattern.hasMatch(trimmed)) return true;
  }

  return false;
}
