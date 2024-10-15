import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SelectCustomerDiloag extends StatelessWidget {
  final DateTime dateTime;
  final CalenderMapController calenderMapController;
  final List<CalendarEventData<EventData>> eventData;

  SelectCustomerDiloag({
    super.key,
    required this.dateTime,
    required this.calenderMapController,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    calenderMapController.initializeCheckedList(eventData.length, eventData);
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    DateTime now = DateTime.now();
    bool isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    return OrientationBuilder(builder: (context, ore) {
      return MyCommnonContainer(
        color: white,
        margin: AppDimensions.instance.orientation == Orientation.landscape
            ? nkExtraLargePadding(
                right: AppDimensions.instance.width * .20,
                left: AppDimensions.instance.width * .20)
            : nkExtraLargePadding(),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Column(
            children: [
              isToday
                  ? DiloagAppBar(title: "Customer Visit For Today")
                  : DiloagAppBar(title: "Customer Visit For $formattedDate"),
              eventData.isNotEmpty
                  ? Flexible(
                      child: ListView.builder(
                        padding: nkRegularPadding(),
                        itemCount: eventData.length,
                        itemBuilder: (context, index) {
                          CalendarEventData<EventData> customerEvent =
                              eventData[index];
                          log('${customerEvent.event?.imageUrl}');
                          return Padding(
                            padding: nkSmallPadding(left: 0, right: 0),
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                              child: Card(
                                elevation: 10,
                                shadowColor: black.withOpacity(0.2),
                                color: white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        '${ApiConstants.imageBaseUrl}${customerEvent.event?.imageUrl ?? ''}'),
                                  ),
                                  title: CustomText(
                                    content:
                                        customerEvent.event?.businessName ?? '',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                          content:
                                              customerEvent.event?.address ??
                                                  ''),
                                      CustomText(
                                          content:
                                              customerEvent.event?.mobileNo ??
                                                  ''),
                                      CustomText(
                                          content:
                                              customerEvent.event?.email ?? ''),
                                    ],
                                  ),
                                  trailing: Obx(() {
                                    return Checkbox(
                                      value: calenderMapController
                                          .checkedList[index],
                                      onChanged: (value) {
                                        calenderMapController
                                            .toggleCustomerSelection(index,
                                                value ?? false, eventData);
                                      },
                                    );
                                  }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton.icon(
                  label: CustomText(content: 'Show Route', color: white),
                  onPressed: () {
                    calenderMapController.showSelectedCustomerRoute(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(primaryColor),
                  ),
                  icon: Icon(EneftyIcons.location_outline, color: white),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
