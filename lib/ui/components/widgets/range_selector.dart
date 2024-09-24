import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/calander_date_range_picker.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_popup_menue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
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
/*  final List<String> _rangeList = [
    "Range",
    "This Month",
    "This Week",
    "Today",
    "This Year"
  ];*/
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        MyPopUpMenu<int>(
          onItemSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
            if (selectedIndex != FilterDateEnum.values.length - 1) {
              widget.onChanged?.call(
                  selectedIndex,
                  FilterDateEnum.values[selectedIndex]
                      .selectDateRange(context));
              // print(
              //     "date+++++${FilterDateEnum.values[selectedIndex].selectDateRange(context)}");
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
                vertical: AppDimensions.instance!.height * .010),
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
                ),
              ],
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

/*
  Widget rangeDropDown(
      {List<String>? rangeList,
      double? width,
      void Function(String)? onChanged}) {
    return Container(
      width: AppDimensions.instance!.width * 0.12,
      padding: nkSymmetricPadding(vertical: 0),
      decoration: decoration,
      child: MyDropdownField(
        dropdownItems: FilterDateEnum.values,
        hint: _rangeList[0],
        underLineIcon: const SizedBox(),
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
        onChanged: onChanged ??
            (value) {
              setState(() {
                selectedIndex = _rangeList.indexOf(value);
                widget.onChanged?.call(_rangeList.indexOf(value), value);
              });
            },
      ),
    );
  }
*/

  // Widget goButton() {
  //   return MyThemeButton(
  //     buttonText: go,
  //     onPressed: () {
  //       widget.onChanged?.call(
  //           selectedIndex,
  //           FilterDateEnum.values[selectedIndex].selectDateRange(context,
  //               endDate: selectedEndDate, startDate: selectedStartDate));
  //     },
  //   );
  // }


  Widget goButton() {
    return Padding(

        padding: EdgeInsets.all((MediaQuery.of(
            context)
            .orientation ==
            Orientation
                .portrait)
            ? (ResponsiveInfo
            .isMobileDimension(
            context)
            ? 2
            : 3)
            : (ResponsiveInfo
            .isMobileDimension(
            context)
            ? 4
            : 6)),

        child:  Container(

          width: (MediaQuery.of(
              context)
              .orientation ==
              Orientation
                  .portrait)
              ? (ResponsiveInfo
              .isMobileDimension(
              context)
              ? 40
              : 60)
              : (ResponsiveInfo
              .isMobileDimension(
              context)
              ? 60
              : 70),
          height:(MediaQuery.of(
              context)
              .orientation ==
              Orientation
                  .portrait)
              ? (ResponsiveInfo
              .isMobileDimension(
              context)
              ? 30
              : 45)
              : (ResponsiveInfo
              .isMobileDimension(
              context)
              ? 45
              : 50),

          decoration: BoxDecoration(
            color: Color(0xff747ced),
            borderRadius: BorderRadius.circular(ResponsiveInfo.isMobileDimension(context)?5:7),
          ),

          child:  TextButton(

            child:       Text(
              "Go",
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: (MediaQuery.of(
                      context)
                      .orientation ==
                      Orientation
                          .portrait)
                      ? (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 7
                      : 10)
                      : (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 10
                      : 13),
                  color: Colors.white,
                  fontFamily:
                  'Poppins_Regular'),
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
            ),
            onPressed: (){

              widget.onChanged?.call(
                  selectedIndex,
                  FilterDateEnum.values[selectedIndex].selectDateRange(context,
                      endDate: selectedEndDate, startDate: selectedStartDate));
            },
          ),







          // MyThemeButton(
          //   buttonText: go,
          //   onPressed: () {
          //     widget.onChanged?.call(
          //         selectedIndex,
          //         FilterDateEnum.values[selectedIndex].selectDateRange(context,
          //             endDate: selectedEndDate, startDate: selectedStartDate));
          //   },
          // ),
        ))

    ;
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
              /* widget.onChanged?.call(
                  selectedIndex,
                  FilterDateEnum.values[selectedIndex].selectDateRange(context,
                      endDate: value.end, startDate: value.start));*/
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
/*              widget.onChanged?.call(
                  selectedIndex,
                  FilterDateEnum.values[selectedIndex].selectDateRange(context,
                      endDate: value.end, startDate: value.start));*/
            }
          });
        }),
        /* selectedEndDate != null && selectedStartDate != null
            ? MyThemeButton(
                buttonText: go,
                onPressed: () {
                  widget.onChanged?.call(
                      selectedIndex,
                      FilterDateEnum.values[selectedIndex].selectDateRange(
                          context,
                          endDate: selectedEndDate,
                          startDate: selectedStartDate));
                },
              )
            : const SizedBox()*/
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
  //////////
//   Widget goButton() {
//     return MyThemeButton(
//       buttonText: go,
//       onPressed: () {
//         widget.onChanged?.call(
//             selectedIndex,
//             FilterDateEnum.values[selectedIndex].selectDateRange(context,
//                 endDate: selectedEndDate, startDate: selectedStartDate));
//       },
//     );
//   }
//
//   Widget selectDateRange() {
//     return Wrap(
//       direction: Axis.horizontal,
//       crossAxisAlignment: WrapCrossAlignment.center,
//       spacing: 10,
//       children: [
//         dateRangeComponent(startDate, onTap: () async {
//           await showDiloagData.then((value) {
//             if (value != null) {
//               setState(() {
//                 selectedStartDate = value.start;
//                 selectedEndDate = value.end;
//                 startDate = NKDateUtils.apiDayFormat(value.start);
//                 endDate = NKDateUtils.apiDayFormat(value.end);
//               });
//               /* widget.onChanged?.call(
//                   selectedIndex,
//                   FilterDateEnum.values[selectedIndex].selectDateRange(context,
//                       endDate: value.end, startDate: value.start));*/
//             }
//           });
//         }),
//         const MyRegularText(label: to),
//         dateRangeComponent(endDate, onTap: () async {
//           await showDiloagData.then((value) {
//             if (value != null) {
//               setState(() {
//                 selectedStartDate = value.start;
//                 selectedEndDate = value.end;
//                 startDate = NKDateUtils.apiDayFormat(value.start);
//                 endDate = NKDateUtils.apiDayFormat(value.end);
//               });
// /*              widget.onChanged?.call(
//                   selectedIndex,
//                   FilterDateEnum.values[selectedIndex].selectDateRange(context,
//                       endDate: value.end, startDate: value.start));*/
//             }
//           });
//         }),
//         /* selectedEndDate != null && selectedStartDate != null
//             ? MyThemeButton(
//                 buttonText: go,
//                 onPressed: () {
//                   widget.onChanged?.call(
//                       selectedIndex,
//                       FilterDateEnum.values[selectedIndex].selectDateRange(
//                           context,
//                           endDate: selectedEndDate,
//                           startDate: selectedStartDate));
//                 },
//               )
//             : const SizedBox()*/
//       ],
//     );
//   }
//
//   Future<DateTimeRange?> get showDiloagData async {
//     DateTimeRange data = await Get.dialog(Padding(
//       padding: nkLargePadding(),
//       child: ClipRRect(
//         borderRadius:
//             BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
//         child: CalenderDateRangePicker(
//           firstDate: DateTime(1996),
//           currentDate: DateTime.now(),
//           lastDate: DateTime.now(),
//         ),
//       ),
//     ));
//
//     return data;
//   }
//
//   Widget dateRangeComponent(String label, {void Function()? onTap}) {
//     return MyCommnonContainer(
//       padding: nkSymmetricPadding(),
//       onTap: onTap,
//       borderRadius: NkGeneralSize.nkCommonBorderRadius(),
//       color: const Color(0xFFEEF2F7),
//       child: MyRegularText(
//         label: label,
//       ),
//     );
//   }

  /*Widget _buildRangeSelector() {
    return ListView.separated(
        shrinkWrap: true,
        physics: NkGeneralSize.commonPysics(),
        itemBuilder: (context, index) {
          return selectorWidget(_rangeList[index], index);
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 6.0);
        },
        itemCount: _rangeList.length);
  }*/

  /* Widget selectorWidget(String label, int index) {
    return InkWell(
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
        onTap: () {
          setState(() {
            selectedIndex = index;
            widget.onChanged?.call(index, label);
          });
        },
        child: MyRegularText(
          label: label,
          color: selectedIndex == index ? primaryColor : null,
        ));
  }*/

  Decoration get decoration {
    return BoxDecoration(
        borderRadius: widget.borderRadius ??
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
        color: widget.color ?? primaryColor.withOpacity(0.4));
  }
}
