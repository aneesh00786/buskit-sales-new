import 'package:flutter/material.dart';

double fullScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double fullScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.shortestSide >= 600;
}

bool isTabletOrPhoneLandscape(context) {
  if (isTablet(context) ||
      (!isTablet(context) &&
          MediaQuery.of(context).orientation == Orientation.landscape)) {
    return true;
  } else {
    return false;
  }
}

bool isTabletOrPhonePortrait(context) {
  if (isTablet(context) ||
      (!isTablet(context) &&
          MediaQuery.of(context).orientation == Orientation.portrait)) {
    return true;
  } else {
    return false;
  }
}

bool isPhoneLandscape(context) {
  if ((!isTablet(context) &&
      MediaQuery.of(context).orientation == Orientation.landscape)) {
    return true;
  } else {
    return false;
  }
}

bool isPhonePortrait(context) {
  if ((!isTablet(context) &&
      MediaQuery.of(context).orientation == Orientation.portrait)) {
    return true;
  } else {
    return false;
  }
}
