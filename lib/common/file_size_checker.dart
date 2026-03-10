import 'dart:io';

Future<bool> isFileSizeWithinLimit(File file) async {
  try {
    final int fileSize = await file.length();
    const int maxSizeInBytes = 1048576;
    return fileSize <= maxSizeInBytes;
  } catch (e) {
    return false;
  }
}

void checkFile(File file) async {
  bool isValid = await isFileSizeWithinLimit(file);
  if (isValid) {
  } else {
  }
}
