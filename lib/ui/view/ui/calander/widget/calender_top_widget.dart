import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
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
      children: [staffDetailsWidget(SessionHelper.loginSavedData??LoginData())],
    );
  }

  Widget staffDetailsWidget(LoginData staffData) {
    return MyCommnonContainer(
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
              ),
              MyRegularText(
                label: staffData.mobileno ?? 'No Mobile',
              ),
              MyRegularText(
                label: staffData.email ?? 'No Email',
              ),
            ])
      ]),
    );
  }
}
