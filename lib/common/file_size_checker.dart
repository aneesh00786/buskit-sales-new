import 'dart:io';

Future<bool> isFileSizeWithinLimit(File file) async {
  try {
    final int fileSize = await file.length();
    const int maxSizeInBytes = 1048576;
    return fileSize <= maxSizeInBytes;
  } catch (e) {
    print('Error checking file size: $e');
    return false;
  }
}

void checkFile(File file) async {
  bool isValid = await isFileSizeWithinLimit(file);
  if (isValid) {
    print('File is within size limit.');
  } else {
    print('File exceeds 1MB.');
  }
}
