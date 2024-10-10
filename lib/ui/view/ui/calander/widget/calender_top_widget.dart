import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:flutter/material.dart';

class CalenderTopWidget extends StatelessWidget {
  final CalenderController calenderController;
  const CalenderTopWidget({
    super.key,
    required this.calenderController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [staffDetailsWidget(SessionHelper.loginSavedData??LoginData())],
    );
  }

  Widget staffDetailsWidget(LoginData staffData) {
    log('Calender ImagePath :${staffData.imagePath}');
    return MyCommnonContainer(
      color: white,
      border: Border.all(color: black.withOpacity(0.3)),
      padding: nkRegularPadding(),
      child: Row(children: [
        ClipOval(
          child: MyNetworkImage(
            imageUrl: staffData.imagePath ?? ApiConstants.dummyImageUrl,
            height: AppDimensions.instance.height * 0.06,
            width: AppDimensions.instance.height * 0.06,
          ),
        ),
        nkSmallSizeBox(),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRegularText(
                label: staffData.fullname ?? 'No Name',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              MyRegularText(
                label: staffData.mobileno ?? 'No Mobile',
                fontSize: 15,
              ),
              MyRegularText(
                label: staffData.email ?? 'No Email',
                fontSize: 15,
              ),
            ])
      ]),
    );
  }
}
