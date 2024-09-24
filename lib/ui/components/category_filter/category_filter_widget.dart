import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_item.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../icons/slide_bar_icons.dart';

class CategoryFilterWidget extends StatefulWidget {
  final List<CategoryData>? categoryData;
  final Function(int? category, int? subCategory)? onSelected;
  final void Function()? onRetryPressed;
  const CategoryFilterWidget(
      {Key? key,
      required this.categoryData,
      this.onSelected,
      this.onRetryPressed})
      : super(key: key);

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  int _selectedSubCategoryIndex = 0;
  String _selectedSubCategoryName = "";
  int initialCategory = 0;

  @override
  void initState() {
    super.initState();
    initialDataLoad;
  }

  get initialDataLoad {
    widget.onSelected?.call(0, 0);
    setState(() {
      _selectedSubCategoryName =
          widget.categoryData?[0].subCategoryItem?[0].subCategory ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.instance.height*1,
      //color: secondaryColor,
            child: Expanded(
              child: CategoryList(
              categories: widget.categoryData ?? [],
              onDrawerToggle: () {
                
              },
              onOptionSelected: (p0) {},
                        ),
            ),
    );
    // Container(
    //   width: AppDimensions.instance.height*0.6,
    //   height: AppDimensions.instance.height*0.6,
    //   color: Colors.amber,
      // child: CategoryList(
      //       categories: widget.categoryData ?? [],
      //       onDrawerToggle: () {},
      //       onOptionSelected: (p0) {},
      //     ),
    // );
    
    //  MyCommnonContainer(
    //   isCommonBorder: true,
    //   padding: nkRegularPadding(),

    //   //decoration: decoration,
    //   child: Expanded(
    //     child: CategoryList(
    //           categories: widget.categoryData ?? [],
    //           onDrawerToggle: () {},
    //           onOptionSelected: (p0) {},
    //         ),
    //   ),
    // );
  }

  // Widget mainCategoryContent() => Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         heading("Categories"),
  //         nkMediumSizeBox(),
  //         CategoryList(
  //           categories: widget.categoryData ?? [],
  //           onDrawerToggle: () {
             
  //           },
  //           onOptionSelected: (p0) {},
  //         )
  //       ],
  //     );

  // Widget heading(String title) => MyRegularText(
  //       label: title,
  //       fontWeight: NkGeneralSize.nkBoldFontWeight(),
  //       fontSize: NkFontSize.largeFont(),
  //     );

  // Widget categoryLis() {
  //   return Flexible(
  //     child: Theme(
  //       data: Get.theme.copyWith(
  //         iconTheme: Get.theme.iconTheme
  //             .copyWith(size: NkGeneralSize.nkIconSize(iconSize: 24)),
  //       ),
  //       child: NkWidgetExceptionHandel(
  //         data: widget.categoryData,
  //         onRetryPressed: widget.onRetryPressed,
  //         child: ListView.builder(
  //           physics: NkGeneralSize.commonPysics(),
  //           primary: false,
  //           itemCount: widget.categoryData?.length ?? 0,
  //           shrinkWrap: true,
  //           itemBuilder: (context, index) {
  //             CategoryData data = widget.categoryData![index];
  //             return ExpansionTile(
  //               childrenPadding: EdgeInsets.zero,
  //               tilePadding: EdgeInsets.zero,
  //               leading: const Icon(SIdeBarIcon.ic_dashboard, size: 5),
  //               expandedAlignment: Alignment.centerLeft,
  //               initiallyExpanded: index == 0,

  //               maintainState: true,

  //               //collapsedBackgroundColor: data.isExpand ? primaryColor : null,
  //               //backgroundColor: primaryColor,
  //               onExpansionChanged: (value) {
  //                 if (value) {
  //                   setState(() {
  //                     initialCategory = index;
  //                   });
  //                 } else {
  //                   setState(() {
  //                     initialCategory = -1;
  //                   });
  //                 }
  //                 /* setState(() {
  //                   data.isExpand = value;
  //                 });*/
  //               },
  //               collapsedShape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(
  //                     NkGeneralSize.nkCommonBorderRadius()),
  //               ),
  //               title: MyRegularText(
  //                 align: TextAlign.start,
  //                 label: data.categoryName ?? '',
  //                 fontSize: NkFontSize.regularFont() + 2,
  //                 color: initialCategory == index ? primaryColor : null,
  //               ),
  //               children: _buildExpandableContent(data, index),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  _buildExpandableContent(CategoryData vehicle, int categoryIndex) {
    List<Widget> columnContent = List.generate(
        vehicle.subCategoryItem!.length,
        (index) => Padding(
              padding: nkSymmetricPadding(
                  horizontal: 0,
                  vertical: AppDimensions.instance.width * .009),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedSubCategoryIndex = index;
                    _selectedSubCategoryName =
                        vehicle.subCategoryItem![index].subCategory!;
                    widget.onSelected?.call(categoryIndex, index);
                    if (_selectedSubCategoryIndex == index) {}
                  }),

                  /* selectedTileColor: primaryColor,
                  selectedColor: primaryColor,
                  focusColor: primaryColor,
                  splashColor: primaryColor,
                  hoverColor: primaryColor,*/
                  //focusNode: Get.focusScope,
                  /*selected: _selectedSubCategoryIndex == index &&
                      _selectedSubCategoryName ==
                          vehicle.subCategoryItem![index].subCategory!,*/
                  child: MyRegularText(
                    align: TextAlign.start,
                    color: checkInitialCategory(categoryIndex, index)
                        ? primaryColor
                        : _selectedSubCategoryName ==
                                    vehicle
                                        .subCategoryItem![index].subCategory! &&
                                _selectedSubCategoryIndex == index
                            ? primaryColor
                            : null,
                    label: vehicle.subCategoryItem![index].subCategory!,
                  ),
                ),
              ),
            ));

    return columnContent;
  }

  bool checkInitialCategory(int categoryIndex, int subCategory) {
    return initialCategory == 0 &&
        _selectedSubCategoryName == "" &&
        widget.categoryData?[0].subCategoryItem?[0].subCategory ==
            widget.categoryData?[categoryIndex].subCategoryItem?[subCategory]
                .subCategory;
  }

/*  BoxDecoration get decoration => BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
        border: Border.all(color: Colors.grey),
      );*/
}
