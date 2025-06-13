// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/calander_date_range_picker.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_popup_menue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RangeSelector extends StatefulWidget {
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Function(
          int selectedIndex, (DateTime? startDate, DateTime? endDate) date)?
      onChanged;
  final void Function()? onGoPressed;
  const RangeSelector(
      {super.key,
      this.borderRadius,
      this.color,
      this.onChanged,
      this.onGoPressed});

  @override
  State<RangeSelector> createState() => RangeSelectorState();
}

class RangeSelectorState extends State<RangeSelector> {
  DateTime? selectedStartDate, selectedEndDate;
  int selectedIndex = 0;
  String startDate = "Start Date";
  String endDate = "End Date";

  @override
  void initState() {
    widget.onChanged?.call(selectedIndex,
        FilterDateEnum.values[selectedIndex].selectDateRange(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: isSmallScreen ? 30 : 45,
          width: isSmallScreen ? 96 : 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: MyPopUpMenu<int>(
            onItemSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
              if (selectedIndex != FilterDateEnum.values.length - 1) {
                widget.onChanged?.call(
                    selectedIndex,
                    FilterDateEnum.values[selectedIndex]
                        .selectDateRange(context));
              }
            },
            items: FilterDateEnum.values
                .map((e) => PopupMenuItem<int>(
                      value: FilterDateEnum.values.indexOf(e),
                      child: MyRegularText(
                        label: e.name,
                        fontSize: NkFontSize.smallFont(),
                      ),
                    ))
                .toList(),
            buttonChild: Container(
              padding: nkSymmetricPadding(
                  vertical: AppDimensions.instance.height * .002),
              decoration: decoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyRegularText(
                    label: FilterDateEnum.values[selectedIndex].name,
                    fontSize: NkFontSize.smallFont(),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selectedIndex == 4) ...[
          nkSmallSizeBox(),
          selectDateRange(),
          nkSmallSizeBox(),
          goButton()
        ],
      ],
    );
  }

  Widget goButton() {
    return Padding(
        padding: EdgeInsets.all(
            (MediaQuery.of(context).orientation == Orientation.portrait)
                ? (ResponsiveInfo.isMobileDimension(context) ? 2 : 3)
                : (ResponsiveInfo.isMobileDimension(context) ? 4 : 6)),
        child: Container(
          width: (MediaQuery.of(context).orientation == Orientation.portrait)
              ? (ResponsiveInfo.isMobileDimension(context) ? 40 : 60)
              : (ResponsiveInfo.isMobileDimension(context) ? 60 : 70),
          height: (MediaQuery.of(context).orientation == Orientation.portrait)
              ? (ResponsiveInfo.isMobileDimension(context) ? 30 : 45)
              : (ResponsiveInfo.isMobileDimension(context) ? 45 : 50),
          decoration: BoxDecoration(
            color: const Color(0xff747ced),
            borderRadius: BorderRadius.circular(
                ResponsiveInfo.isMobileDimension(context) ? 5 : 7),
          ),
          child: TextButton(
            child: Text(
              "Go",
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: (MediaQuery.of(context).orientation ==
                          Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 7 : 10)
                      : (ResponsiveInfo.isMobileDimension(context) ? 10 : 13),
                  color: Colors.white,
                  fontFamily: 'Poppins_Regular'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onPressed: () async{
              bool isOnline = await ConnectivityService().isOnline();
              if(isOnline){
                widget.onChanged?.call(
                  selectedIndex,
                  FilterDateEnum.values[selectedIndex].selectDateRange(context,
                      endDate: selectedEndDate, startDate: selectedStartDate));
              }else{
                errorSnackbar("No internet connection. Please check you'r network");
              }
              
            },
          ),
        ));
  }

  Widget selectDateRange() {
    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      children: [
        dateRangeComponent(startDate, onTap: () async {
          await showDiloagData.then((value) {
            if (value != null) {
              setState(() {
                selectedStartDate = value.start;
                selectedEndDate = value.end;
                startDate = NKDateUtils.apiDayFormat(value.start);
                endDate = NKDateUtils.apiDayFormat(value.end);
              });
            }
          });
        }),
        const MyRegularText(label: to),
        dateRangeComponent(endDate, onTap: () async {
          await showDiloagData.then((value) {
            if (value != null) {
              setState(() {
                selectedStartDate = value.start;
                selectedEndDate = value.end;
                startDate = NKDateUtils.apiDayFormat(value.start);
                endDate = NKDateUtils.apiDayFormat(value.end);
              });
            }
          });
        }),
      ],
    );
  }

  Future<DateTimeRange?> get showDiloagData async {
    DateTimeRange data = await Get.dialog(Padding(
      padding: nkLargePadding(),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
        child: CalenderDateRangePicker(
          firstDate: DateTime(1996),
          currentDate: DateTime.now(),
          lastDate: DateTime.now(),
        ),
      ),
    ));

    return data;
  }

  Widget dateRangeComponent(String label, {void Function()? onTap}) {
    return MyCommnonContainer(
      padding: nkSymmetricPadding(),
      onTap: onTap,
      borderRadius: NkGeneralSize.nkCommonBorderRadius(),
      color: const Color(0xFFEEF2F7),
      child: MyRegularText(
        label: label,
      ),
    );
  }

  Decoration get decoration {
    return BoxDecoration(
      borderRadius: widget.borderRadius ??
          BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      color: white,
      border: Border.all(
        color: Colors.grey,
        width: 0.3,
      ),
    );
  }
}
