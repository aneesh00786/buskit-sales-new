import 'package:busskit_salesexecutive/ui/components/category_filter/category_item.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  ProductsController productsController = Get.find<ProductsController>();
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
            child: Expanded(
              child: CategoryList(
              categories: widget.categoryData ?? [],
              productsController: productsController,
              onDrawerToggle: () {},
              onOptionSelected: (p0) {},
                        ),
            ),
    );
  }
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
}
