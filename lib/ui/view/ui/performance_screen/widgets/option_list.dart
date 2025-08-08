
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:flutter/material.dart';

List<OptionData> defaultOption(BuildContext context) => [
        OptionData(
          title: 'Timesheet',
          unfilteredCount: "0",
          count: "3",
          svg: "assets/icons/event.png",
          svgBgColor: const Color.fromARGB(255, 206, 252, 224),
          onTap: () {},
        ),
        OptionData(
          title: 'Checkin/out',
          unfilteredCount: "0",
          count: "2",
          svg: "assets/icons/check-in.png",
          svgBgColor: const Color.fromARGB(255, 215, 236, 246),
          onTap: () {},
        ),
        OptionData(
          title: 'Visits',
          unfilteredCount: "0",
          count: "4",
          svg: "assets/icons/location.png",
          svgBgColor: const Color.fromARGB(255, 249, 219, 193),
          onTap: () {},
        ),
        OptionData(
          title: 'Customers',
          unfilteredCount: "0",
          count: "0",
          svg: "assets/icons/customer.png",
          svgBgColor: const Color.fromARGB(255, 211, 240, 249),
          onTap: () {},
        ),
      ];
