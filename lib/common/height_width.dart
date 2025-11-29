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
double salesReturncardWidth(BuildContext context) {
  final fullW = MediaQuery.of(context).size.width;
  final isPortrait = isPhonePortrait(context);

  if (isPortrait) {
    return fullW * 2.3;               // your original phone-portrait rule
  } else {
    return fullW > 640 ? fullW * 1 : fullW * 1.1;
  }
}
// double salesReturnCardHeight(BuildContext context) {
//   if (isTablet(context)) {
//     return fullScreenHeight(context) * 0.10; // Tablet → slightly bigger
//   } else if (isPhoneLandscape(context)) {
//     return fullScreenHeight(context) * 0.8; // Phone landscape
//   } else {
//     return fullScreenHeight(context) * 0.8; // Phone portrait (default)
//   }
// }

