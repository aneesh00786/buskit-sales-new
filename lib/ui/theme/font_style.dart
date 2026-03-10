import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NkGetXFontStyle {
  static TextTheme get textLightTheme =>
      GoogleFonts.barlowCondensedTextTheme().copyWith(
          labelMedium: GoogleFonts.barlow().copyWith(
        color: primaryTextColor,
        fontSize: NkFontSize.regularFont(),
        fontWeight: NkGeneralSize.nkGeneralFontWeight(),
      ));

}
