
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:flutter/material.dart';

class BackupDataFunction extends ChangeNotifier {
  static CategoryModel? _categoryAndProductBackup;

  static CategoryModel? get getCategoryAndProductBackup =>
      _categoryAndProductBackup;
  static set categoryAndProductBackup(CategoryModel value) {
    _categoryAndProductBackup = value;
    
  }
}
