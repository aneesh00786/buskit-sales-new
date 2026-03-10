import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/common_size/common_hight_width.dart';
import 'const_string.dart';

abstract class NkCommonFunction {
  static Duration shortDuration({Duration? shortDuration}) =>
      shortDuration ?? const Duration(milliseconds: 100);

  static Duration longDuration({Duration? longDuration}) =>
      longDuration ?? const Duration(milliseconds: 500);

  static showErrorSnakBar(String message) async {
    await snakBarCloser;
    Get.showSnackbar(GetSnackBar(
      maxWidth: AppDimensions.instance.width / 2,
      barBlur: 10,
      reverseAnimationCurve: Curves.easeInOutCubicEmphasized,
      duration: longDuration(longDuration: const Duration(seconds: 2)),
      messageText: Center(
        child: MyRegularText(
          color: buttonTextColor,
          label: message,
          fontWeight: FontWeight.bold,
        ),
      ),
      message: message,
      backgroundColor: errorColor.withOpacity(0.8),
      snackPosition: SnackPosition.TOP,
      borderRadius: NkGeneralSize.nkCommonBorderRadius(),
      margin: nkRegularPadding(),
      isDismissible: true,
      padding: nkSmallPadding(),
      animationDuration: longDuration(longDuration: const Duration(seconds:1 )),
      icon: const Icon(
        Icons.error,
        color: primaryColor,
      ),
    ));
  }

  static get snakBarCloser async =>
      Get.isSnackbarOpen ? await Get.closeCurrentSnackbar() : null;

  static showDeleteSnakBar(
      {String? message,
      void Function()? onYesPressed,
      void Function()? onNoPressed}) {
    Get.showSnackbar(GetSnackBar(
      maxWidth: AppDimensions.instance.width / 2,
      overlayBlur: 10,
      reverseAnimationCurve: Curves.easeInOutCubicEmphasized,
      duration: longDuration(longDuration: const Duration(seconds: 30)),
      message: message,
      backgroundColor: primaryColor,
      snackPosition: SnackPosition.TOP,
      messageText: Center(
        child: MyRegularText(
          color: buttonTextColor,
          label: message ?? areYouSureToDelete,
        ),
      ),
      mainButton: Wrap(
        children: [
          TextButton(
              onPressed: onYesPressed,
              child: MyRegularText(
                label: yes,
                color: errorColor,
                fontWeight: NkGeneralSize.nkBoldFontWeight(),
                fontSize: NkFontSize.largeFont(),
              )),
          TextButton(
              onPressed: onNoPressed ??
                  () {
                    Get.back();
                  },
              child: MyRegularText(
                label: no,
                color: buttonTextColor,
                fontWeight: NkGeneralSize.nkBoldFontWeight(),
                fontSize: NkFontSize.largeFont(),
              )),
        ],
      ),
      borderRadius: NkGeneralSize.nkCommonBorderRadius(),
      margin: nkRegularPadding(),
      isDismissible: true,
      padding: nkSmallPadding(),
      animationDuration:
          longDuration(longDuration: const Duration(milliseconds: 700)),
      icon: SvgPicture.asset(Assets.iconsIcDelete),
    ));
  }

  static showErrorToast(String msg) {
    Fluttertoast.showToast(
        msg: msg, backgroundColor: errorColor, gravity: ToastGravity.TOP);
  }

  static showSimpleToast(
    String msg, {
    Color? color,
    Color? textColor,
  }) {
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: color ?? primaryColor,
        textColor: textColor,
        gravity: ToastGravity.TOP);
  }

  static Future<dio.MultipartFile> getFormData(String imagePath,
      {required String mapKeyName}) async {

    String fileNameMedia = '';
    if (imagePath.isNotEmpty) {
      File fileMedia = File(imagePath);
      fileNameMedia = basename(fileMedia.path);
      // String extensionMedia = fileNameMedia.split('.').last;
    }

    return await dio.MultipartFile.fromFile(
      imagePath,
      filename: fileNameMedia,
    );
  }

  static showSuccessSnakBar(String message) async {
    await snakBarCloser;
    Get.showSnackbar(GetSnackBar(
      maxWidth: AppDimensions.instance.width / 2,
      barBlur: 0,
      reverseAnimationCurve: Curves.easeInOutCubicEmphasized,
      duration: longDuration(longDuration: const Duration(seconds: 2)),
      messageText: Center(
        child: MyRegularText(
          color: buttonTextColor,
          label: message,
        ),
      ),
      message: message,
      backgroundColor: switchColor.withOpacity(0.6),
      snackPosition: SnackPosition.TOP,
      borderRadius: NkGeneralSize.nkCommonBorderRadius(),
      margin: nkRegularPadding(),
      isDismissible: true,
      padding: nkSmallPadding(),
      animationDuration: longDuration(longDuration: const Duration(seconds: 2)),
      icon: const Icon(
        Icons.error,
        color: primaryColor,
      ),
    ));
  }

  static bool chckEmailValidation(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static Widget errorWidget() {
    return Container(
        color: Colors.transparent,
        child: Image.network(
          'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/bc70c43b-aeca-448a-a158-0f8e7c281a0d/dceqwb1-a75b8ac9-8340-45bb-8049-4883b81baa3c.gif?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2JjNzBjNDNiLWFlY2EtNDQ4YS1hMTU4LTBmOGU3YzI4MWEwZFwvZGNlcXdiMS1hNzViOGFjOS04MzQwLTQ1YmItODA0OS00ODgzYjgxYmFhM2MuZ2lmIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.Xmt2peugw4IY64xOXTkc3Q1IFo5T861ncwbHc1E4rhM',
        ));
  }

  static (DateTime startDate, DateTime endDate) get todayDate {
    return (DateTime.now().toUtc(), DateTime.now().toUtc());
  }

  static (DateTime startDate, DateTime endDate) get yesterdayDate {
    return (
      DateTime.now().subtract(const Duration(days: 1)),
      DateTime.now().subtract(const Duration(days: 1))
    );
  }

  static (DateTime startDate, DateTime endDate) get thisYear {
    return (
      NKDateUtils.yearStartDate(DateTime.now()),
      NKDateUtils.yearEndDate(DateTime.now())
    );
  }

  static (DateTime startDate, DateTime endDate) get thisMonthDate {
    return (
      NKDateUtils.firstDayOfMonth(DateTime.now()),
      NKDateUtils.lastDayOfMonth(DateTime.now())
    );
  }

  static (DateTime startDate, DateTime endDate) get thisWeekDate {
    return (
      NKDateUtils.firstDayOfWeek(DateTime.now()),
      NKDateUtils.lastDayOfWeek(DateTime.now()),
    );
  }

  static (DateTime startDate, DateTime endDate) dateRange(
      BuildContext context, DateTime startDate, DateTime endDate) {
    /*  (DateTime startDate, DateTime endDate)? dateRange;
    showDateRangePicker(
            context: context, firstDate: startDate, lastDate: endDate)
        .then((value) {
      if (value != null) {
        dateRange = (value.start, value.end);
      }
    });
    return dateRange ?? todayDate;*/
    return (startDate, endDate);
  }

  static const String gMapKey = "AIzaSyDl1vs47Jk9mIybi-9W5b9vv08r6Lir_F4";

  static (Widget widget, bool isStockAvlableWidget) isPaymentComplete(
      num stock) {
    if (stock == 0) {
      var widget = Container(
        decoration:
            const ShapeDecoration(shape: OvalBorder(), color: errorColor),
        child: Icon(
          Icons.close,
          color: secondaryIconColor,
          size: NkGeneralSize.nkIconSize() - 20,
        ),
      );
      return (widget, false);
    } else {
      var widgets = Container(
        decoration:
            const ShapeDecoration(shape: OvalBorder(), color: switchColor),
        child: Icon(
          Icons.check,
          color: secondaryIconColor,
          size: NkGeneralSize.nkIconSize() - 20,
        ),
      );
      return (widgets, true);
    }
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await launchUrl(Uri.parse(googleUrl)) == false) {
      throw 'Could not launch $googleUrl';
    } else {}
  }

    static String getFullSalesmanImageUrl(String? imgPath) {
    if (imgPath == null || imgPath.isEmpty) return '';
    String path = imgPath;

    if (path.startsWith('/')) path = path.substring(1);

    if (!path.startsWith('uploads/salesman/')) {
      if (path.startsWith('salesman/')) {
        path = 'uploads/$path';
      } else if (!path.startsWith('uploads/')) {
        path = 'uploads/salesman/$path';
      }
    }
        return '${ApiConstants.baseUrl}$path';
  }
}
