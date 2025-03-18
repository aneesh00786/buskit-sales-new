// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/theme/font_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NkGetXTheme {
  static ThemeData get lightTheme => ThemeData(
      shadowColor: shadowColor,
      primaryColor: primaryColor,
      primaryColorLight: primaryColor,
      primaryColorDark: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: appBarTheme,
      textTheme: NkGetXFontStyle.textLightTheme,
      primaryTextTheme: NkGetXFontStyle.textLightTheme,
      dataTableTheme: dataTableTheme,
      dividerColor: dividerColor,
      listTileTheme:
          ListTileThemeData(contentPadding: nkSymmetricPadding(vertical: 0)),
      expansionTileTheme: ExpansionTileThemeData(
          iconColor: primaryColor,
          collapsedBackgroundColor: backgroundColor,
          backgroundColor: Colors.transparent,
          textColor: primaryTextColor,
          collapsedTextColor: primaryTextColor,
          tilePadding: nkSymmetricPadding(vertical: 0),
          childrenPadding: EdgeInsets.zero),
      colorScheme: ColorScheme.light(
          primary: primaryColor,
          error: errorColor,
          onError: errorColor,
          background: backgroundColor,
          onBackground: backgroundColor,
          primaryContainer: primaryContainerColor,
          onSecondary: secondaryColor,
          secondaryContainer: secondaryColor,
          surface: backgroundColor,
          secondary: secondaryColor,
          brightness: Get.theme.brightness),
      iconTheme: IconThemeData(
          color: primaryIconColor, size: NkGeneralSize.nkIconSize()),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: secondaryTextColor,
        selectionColor: cursorColor,
        selectionHandleColor: primaryButtonColor,
      ),
      useMaterial3: true,
      iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
              iconColor: MaterialStatePropertyAll(primaryIconColor))),
      primaryIconTheme: IconThemeData(
          color: primaryIconColor, size: NkGeneralSize.nkIconSize()),
      brightness: Brightness.light,
      buttonTheme: ButtonThemeData(
          buttonColor: primaryButtonColor,
          textTheme: ButtonTextTheme.normal,
          padding: nkRegularPadding(),
         //  height: Get.height * 0.06,
          disabledColor: primaryButtonColor,
          focusColor: primaryButtonColor,
          layoutBehavior: ButtonBarLayoutBehavior.padded,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          )));

  static AppBarTheme get appBarTheme => const AppBarTheme(
      color: backgroundColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      shadowColor: shadowColor,
      centerTitle: true,
      titleTextStyle: TextStyle());

  static void get systemChromeStyle =>
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

  static DataTableThemeData get dataTableTheme => DataTableThemeData(
        columnSpacing: AppDimensions.instance.width * .02,
        //dataRowMaxHeight: height * 0.1,
        headingTextStyle: Get.textTheme.displayLarge!.copyWith(
          inherit: false,
          fontWeight: NkGeneralSize.nkBoldFontWeight(),
          fontSize: NkFontSize.largeFont(),
          color: primaryTextColor,
        ),
      );
}

