// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// /// [NkGetXFontStyle] USE CUSTOM FONT

// class NkGetXFontStyle {
//   static TextTheme get textLightTheme => ThemeData().textTheme.apply(
//         fontFamily: GoogleFonts.dmSans(
//                 color: primaryTextColor, fontSize: NkFontSize.regularFont())
//             .fontFamily,
//       );
// }

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:flutter/material.dart';

/// [NkGetXFontStyle] USE CUSTOM FONT

class NkGetXFontStyle {
  static TextTheme get textLightTheme => ThemeData().textTheme.copyWith(
        labelMedium: TextStyle(
          color: primaryTextColor,
          fontSize: NkFontSize.regularFont(),
          fontWeight: NkGeneralSize.nkGeneralFontWeight(),
         // fontFamily: "Poppins_Regular"
        ),
      );
}

