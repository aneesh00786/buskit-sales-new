import 'dart:developer';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_filter.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_popup_menue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/range_selector.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:flutter/material.dart';

import '../../../../utills/const_string.dart';

class CustomerAndOrdersTopWidgets extends StatelessWidget {
  final CustomerAndOrderController customerAndOrderController;
  final List<StaffData> staffDataList;

  const CustomerAndOrdersTopWidgets(
      {super.key,
      required this.customerAndOrderController,
      required this.staffDataList});

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //
    //     SingleChildScrollView(
    //
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //
    //
    //
    //         ],
    //       ),
    //       scrollDirection: Axis.horizontal,
    //     ),
    //
    //
    //   ],
    // );

    return Padding(padding: EdgeInsets.all(ResponsiveInfo.isMobile()?5:8),

      child:  SizedBox(
                 height: ResponsiveInfo.isMobile()?45:55,
          child: SearchFilter(
            context,
            searchTextController: TextEditingController(),
            onChanged: (p0) {
              if (p0.length > 2 || p0.isEmpty) {
                customerAndOrderController.searchData.searchText = p0;
                customerAndOrderController.loadCustomer;
              }
            },
          ).simpleSearch()),

    );
  }

  Widget calender(String calender) {
    return RangeSelector(
      onChanged:
          (selectedIndex, (DateTime? startDate, DateTime? endDate) label) {
        log("label++++${label.$1}:${label.$1}");
        customerAndOrderController.updateCustomerVisitScheduleSet(
            label.$1, label.$2);
        //customerAndOrderController.updateCustomerVisitScheduleSet(label);
      },
    );
  }

  // Widget selectSalesman() {
  //   return MyPopUpMenu(
  //     items: staffMenuOption(),
  //     buttonChild: customerAndOrderController.selectedStaff.value.salesmanId !=
  //             null
  //         ? staffDetailsWidget(customerAndOrderController.selectedStaff.value)
  //         : buttonChild,
  //     onItemSelected: (value) {
  //       customerAndOrderController.updateSelectedStaff(value);
  //     },
  //   );
  // }

  List<PopupMenuItem<StaffData>> staffMenuOption() {
    return List.generate(
        staffDataList.length,
        (index) => PopupMenuItem<StaffData>(
              padding: nkRegularPadding(),
              value: staffDataList[index],
              child: staffDetailsWidget(staffDataList[index]),
            ));
  }

  Widget staffDetailsWidget(StaffData staffData) {
    return MyCommnonContainer(
      padding: nkRegularPadding(),
      child: Row(children: [
        ClipOval(
          child: MyNetworkImage(
            imageUrl: staffData.imagePath ?? '',
            height: AppDimensions.instance!.height * 0.06,
            width: AppDimensions.instance!.height * 0.06,
          ),
        ),
        nkSmallSizeBox(),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRegularText(
                label: staffData.fullname ?? '',
              ),
              MyRegularText(
                label: staffData.mobileno ?? '',
              ),
              MyRegularText(
                label: staffData.email ?? '',
              ),
            ])
      ]),
    );
  }

  Widget get buttonChild {
    return MyCommnonContainer(
      padding: nkRegularPadding(),
      isCommonBorder: true,
      child: MyRegularText(
        fontSize: NkFontSize.largeFont(),
        label:'Selected SalesMan',
        // selectSalesMan,
      ),
    );
  }
}
