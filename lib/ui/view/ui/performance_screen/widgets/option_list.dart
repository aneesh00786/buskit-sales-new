  import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:flutter/material.dart';

List<OptionData> defaultOption(BuildContext context) => [
        OptionData(
          title: 'Timesheet',
          count: "3",
          svg: Assets.iconsIcDashboardShoppingCart,
          svgBgColor: const Color(0xFFFCDABD),
          onTap: () {},
        ),
        OptionData(
          title: 'Checkin/out',
          count: "2",
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color(0xFFC3DDFD),
          onTap: () {},
        ),
        OptionData(
          title: 'Visits',
          count: "4",
          svg: Assets.iconsIcDashboardPreOrder,
          svgBgColor: const Color(0xFFAFECEF),
          onTap: () {},
        ),
        OptionData(
          title: 'Customers',
          count: "0",
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color(0xFFBCF0DA),
          onTap: () {},
        ),
      ];
