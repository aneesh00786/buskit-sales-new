import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:flutter/material.dart';

import '../ui/utills/const_string.dart';

class NkConnectivityErrorHandler extends StatelessWidget {
  final String? errorLable;
  final VoidCallback? onRetryPressed;
  const NkConnectivityErrorHandler(
      {super.key, this.errorLable, this.onRetryPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const FittedBox(
            child: MyNetworkImage(
              height: 480,
              imageUrl:
                  'https://i.pinimg.com/originals/0e/c0/db/0ec0dbf1e9a008acb9955d3246970e15.gif',
            ),
          ),
          nkSmallSizeBox(),
          MyRegularText(
            label: errorLable ?? someThingWentWrong,
            fontSize: NkFontSize.largeFont(),
          ),
          nkMediumSizeBox(),
          retryButton
        ],
      ),
    );
  }

  Widget get retryButton => MyThemeButton(
        buttonText: retry,
        onPressed: onRetryPressed,
        width: AppDimensions.instance.width * 0.1,
        height: AppDimensions.instance.height * 0.035,
        isRoundedCorner: true,
      );

  BoxDecoration get boxDecoration => const BoxDecoration(
        color: Colors.white,
      );
}
