
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AppDimensions extends ChangeNotifier {
  static AppDimensions? _instance;
  static AppDimensions get instance {
    if (_instance == null) {
      throw Exception("AppDimensions instance not initialized. Call AppDimensions.createInstance() first.");
    }
    return _instance!;
  }
  double width = 0;
  double height = 0;
  int gridItemCount = 2;
  Orientation? orientation;

  AppDimensions._internal(BuildContext context, BoxConstraints constraints) {
    _updateDimensions(context, constraints);
    notifyListeners();
  }

  static AppDimensions createInstance(BuildContext context, BoxConstraints constraints) {
    if (_instance == null) {
      Logger().d("Initializing AppDimensions for the first time.");
      _instance = AppDimensions._internal(context, constraints);
    } else {
      Logger().d("Updating existing AppDimensions instance.");
      _instance!._updateDimensions(context, constraints);
    }
    return _instance!;
  }

  void _updateDimensions(BuildContext context, BoxConstraints constraints) {
    orientation = MediaQuery.of(context).orientation;
    width = orientation == Orientation.landscape ? constraints.maxWidth : constraints.maxHeight;
    height = orientation == Orientation.landscape ? constraints.maxHeight : constraints.maxWidth;
    gridItemCount = _getCrossAxisCount(context);
    _logDimensions();
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1000) {
      return 3; 
    } else if (screenWidth >= 800) {
      return 2;
    } else {
      return 1;
    }
  }

  void _logDimensions() {
    // log("SCREEN WIDTH: $width");
    // log("SCREEN HEIGHT: $height");
    // log("ORIENTATION: $orientation");
    // log("GRID ITEM COUNT: $gridItemCount");
  }

  int updateGridCount(BuildContext context) {
    gridItemCount = _getCrossAxisCount(context);
    notifyListeners();
    return gridItemCount;
  }
}
