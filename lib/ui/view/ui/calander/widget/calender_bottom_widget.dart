import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/select_customer_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderBottomWidget extends StatelessWidget {
  final CalenderMapController calenderController;

  const CalenderBottomWidget({super.key, required this.calenderController});

  @override
  Widget build(BuildContext context) {
    return MyCommnonContainer(
      color: white,
      child: calenderWidget(),
    );
  }

  Widget calenderWidget() {
    //return Container();
    return MonthView(
      cellAspectRatio:
          AppDimensions.instance.orientation == Orientation.landscape
              ? 2.0
              : 0.78,
      headerStyle: HeaderStyle(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          headerTextStyle: TextStyle(
              color: black, fontSize: 20, fontWeight: FontWeight.w700)),
      pageTransitionCurve: Curves.easeInOutCubicEmphasized,
      borderColor: white,
      cellBuilder: (date, event, isToday, isInMonth, hideDaysNotInMonth) {
        return MyCommnonContainer(
          borderRadiusGeometry: BorderRadius.circular(15),
          border: Border.all(color: black.withOpacity(0.1)),
          boxShadow: isInMonth
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: Offset(3, 3),
                    spreadRadius: 1,
                  )
                ]
              : [],
          color: isToday
              ? primaryColor
              : !isInMonth
                  ? secondaryTextColor.withOpacity(0.08)
                  : white,
          borderRadius: 0,
          onTap: () {
            var data = event.map((e) => e.event).toList();
            print("Events+++ 1234+++ ${date} ${data.length}");
            print("Events+++ 1235+++  ${event.length}");
            print(
                "Events>>> +++ ${date} ${data.toString()} ${data.first!.toJson()}");
            if (isInMonth) {
              print('in2++ #${data.length}');
              if (data.isNotEmpty) {
                print('in++');
                calenderController.customerList.value=[];
                for (var element in data.first?.salesman ?? []) {
                  print(
                      'Salesman ID from session: ${SessionHelper.loginSavedData?.salesmanId}');
                  print('Current salesman ID: ${element.salesmanId}');
                  print('Customers for this salesman: ${element.customer}');

                  if (element.salesmanId ==
                      SessionHelper.loginSavedData?.salesmanId) {
                    calenderController.customerList.value = element.customer ?? [];
                    print(
                        'Found matching salesman. Customer list length: ${calenderController.customerList.length}');
                  }
                }

                // After the loop, log the final customer list length
                print('Final customer list length: ${calenderController.customerList.length}');
                if (calenderController.customerList.isNotEmpty) {
                  Get.dialog(SelectCustomerDiloag(
                    dateTime: date,
                    customerlist: calenderController.customerList,
                    calenderMapController: calenderController,
                  ));
                  log('Customerlist.Length....${calenderController.customerList.length}');
                } else {
                  log('No customers available for this salesman.');
                }
              }
            }
          },
          padding: nkRegularPadding(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyRegularText(
                label: date.day.toString(),
                color: isToday
                    ? buttonTextColor
                    : !isInMonth
                        ? secondaryTextColor.withOpacity(0.5)
                        : null,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              isToday
                  ? CustomText(
                      content: 'Today',
                      color: white,
                      fontSize: 15,
                    )
                  : Container(),
              nkSmallSizeBox(),
              Flexible(
                child: NkWidgetExceptionHandel(
                  data: calenderController.eventControllerv1.events.isNotEmpty,
                  isShowRetrySection: false,
                  child: Wrap(
                    spacing: 5,
                    children: event
                        .map((e) => ClipOval(
                            child: nkChildWrappedSizeBox(
                                width: 20,
                                height: 20,
                                child: ColoredBox(
                                  color: calenderController
                                      /* .getColor(e.event!.type!)
                                      .$1*/
                                      .getColor(2)
                                      .$1
                                      .withOpacity(!isInMonth ? 0.2 : 1),
                                  child: MyRegularText(
                                    color: Colors.white,
                                    label: "${e.event?.totalEvent}",
                                  ),
                                  //  "${data.isEmpty ? "0" : data.first.totalEvent}"),
                                ))))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      headerStringBuilder: (date, {secondaryDate}) {
        return NKDateUtils.formatMonth(date);
      },
      startDay: WeekDays.monday,
      controller: calenderController.eventControllerv1,
      // borderSize: 1.5,
      initialMonth: DateTime.now(),
      maxMonth: DateTime(DateTime.now().year, 12, 31),
      minMonth: DateTime(DateTime.now().year, 1, 1),
    );
  }
}
