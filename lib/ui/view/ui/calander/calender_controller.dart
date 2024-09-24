import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calendar_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderController extends GetxController {
  final ApiWorker _apiWorker = Get.find();

  Rx<StaffData> selectedStaff = StaffData().obs;

  EventController<SalesManVisitEvents> eventController =
      EventController<SalesManVisitEvents>();

  EventController<SalesmanEvents> eventControllerv1 =
      EventController<SalesmanEvents>();
  List<CustomerDetails> customerDetails = [];

  ///KRUSHANT add calender for DATEWISE DATA
  loadCalenderEvent_v1(List<SalesmanEvents> events) {
    if (eventControllerv1.events.isNotEmpty) {
      for (var element in eventControllerv1.events) {
        eventControllerv1.remove(element);
      }
    }
    print("eventlength ${events.length}");

    var eventData = List<CalendarEventData<SalesmanEvents>>.generate(
        events.length,
        (index) => CalendarEventData<SalesmanEvents>(
              title: events![index].totalEvent.toString(),
              date: NKDateUtils.formatStringUTCDateTime(
                  events![index].start ?? DateTime.now().toString()),
              endDate: NKDateUtils.formatStringUTCDateTime(events![index].end!),
              event: events[index],
              description: events![index].totalEvent!.toString(),
              // color: getColor(events[index].type!).$1,
              color: Colors.grey,
              descriptionStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                // color: getColor(events[index].type!).$2,
                color: getColor(3).$2,
              ),
              startTime: DateTime.now().copyWith(hour: 10, minute: 0),
              endTime: DateTime.now().copyWith(hour: 24, minute: 0),
            ));
    log("Events+++${events.length}");
    //log("EVENT DATEEEEEE ${eventData.map((e) => e.event?.toJson()).toList()}");
    eventControllerv1.addAll(eventData);
    log("Events+++ 123+++  ${eventControllerv1.events.length}");
    refresh();
  }

  (Color componetColor, Color textColor) getColor(int type) {
    switch (type) {
      case 2:
        return (revenueProgressBarColor, buttonTextColor);
      case 3:
        return (revenueProgressBarColor, buttonTextColor);
      case 4:
        return (primaryColor, buttonTextColor);
      case 5:
        return (primaryTextColor, buttonTextColor);
      default:
        return (revenueProgressBarFilledColor, primaryTextColor);
    }
  }

  List<SalesmanEvents> DataList = [];

  Future<void> calenderAllEvents() async {
    var salesmanId = await SessionHelper.loginSavedData?.salesmanId;
    var sendData = {
      "salesman_id": salesmanId,
      "start_date": "",
      "end_date": ""
    };
    _apiWorker.getCalendarEvents(sendData).then((value) {
      DataList = value.data!.first.events!;
      log("calenderAllEvents ${DataList.length}");
      loadCalenderEvent_v1(DataList);
      // loadCalenderEvent_v1(value);
    });
    log("salesManId ${salesmanId.toString()}");
  }

  List<CustomerDetails> splitEventToCustomerData(
      List<SalesManVisitEvents> events) {
    List<CustomerDetails> customerDataList = [];
    for (var element in events) {
      if (element.customer != null) {
        customerDataList.add(CustomerDetails.fromJson(
            element.customer!.toJson()..addAll({"event_id": element.eventId})));
      }
    }
    return customerDataList;
  }
}
