import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_filter.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LeadTopScreen extends StatelessWidget {
  final LeadsController leadsController;
  const LeadTopScreen({super.key, required this.leadsController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*leadTopCustomerWidget,
            nkMediumSizeBox(),*/
            leadTopLeadsWidget
          ],
        ),
        nkMediumSizeBox(),
        nkLargeSizeBox(
            width: AppDimensions.instance!.width / 3,
            // child: SearchFilter(
            //   searchTextController: TextEditingController(),
            // )
            )
      ],
    );
  }

  /*Widget get leadTopCustomerWidget {
    return MyThemeButton(
      color: secondaryColor,
      buttonText: "",
      child: Row(
        children: [
          const MyRegularText(
            label: customer,
          ),
          nkSmallSizeBox(),
          SvgPicture.asset(Assets.iconsIcAddRound),
        ],
      ),
    );
  }*/

  Widget get leadTopLeadsWidget {
    return MyThemeButton(
      onPressed: () => Get.dialog(AddLeadsDiloag(
        leadsController: leadsController,
      )),
      buttonText: "",
      child: Row(
        children: [
          const MyRegularText(
            label: leads,
            color: buttonTextColor,
          ),
          nkSmallSizeBox(),
          SvgPicture.asset(
            Assets.iconsIcAddRound,
            colorFilter:
                const ColorFilter.mode(secondaryColor, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
