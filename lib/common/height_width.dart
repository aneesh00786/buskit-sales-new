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
double getResponsiveColumnSpacing(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final shortestSide = MediaQuery.of(context).size.shortestSide;

  // 1. Small Tablets: iPad Mini, 8–9 inch tablets (width typically 768–850 in portrait)
  if (isTablet(context) && screenWidth <= 850) {
    return 38.0; // Perfect balance for iPad Mini & small tablets
  }

  // 2. Regular / Large Tablets (10" + like iPad Air/Pro, Galaxy Tab S)
  if (isTablet(context)) {
    return 55.0; // You already wanted 50 for normal tablets
  }

  // 3. Phone in Landscape → very tight space
  if (isPhoneLandscape(context)) {
    return screenWidth < 600 ? 20.0 : 25.0;
  }

  // 4. Phone in Portrait
  if (isPhonePortrait(context)) {
    if (screenWidth < 360) {
      return 24.0;      // Very small phones
    } else if (screenWidth < 400) {
      return 32.0;      // Standard phones
    } else {
      return 42.0;      // Large phones (iPhone 14 Pro Max, etc.)
    }
  }

  // Fallback
  return 40.0;
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

