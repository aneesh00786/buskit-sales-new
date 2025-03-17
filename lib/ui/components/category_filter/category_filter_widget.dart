import 'package:busskit_salesexecutive/ui/components/category_filter/category_item.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryFilterWidget extends StatefulWidget {
  final List<CategoryData>? categoryData;
  final Function(int? category, int? subCategory)? onSelected;
  final void Function()? onRetryPressed;
  const CategoryFilterWidget(
      {super.key,
      required this.categoryData,
      this.onSelected,
      this.onRetryPressed});

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
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
    return SizedBox(
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

  bool checkInitialCategory(int categoryIndex, int subCategory) {
    return initialCategory == 0 &&
        _selectedSubCategoryName == "" &&
        widget.categoryData?[0].subCategoryItem?[0].subCategory ==
            widget.categoryData?[categoryIndex].subCategoryItem?[subCategory]
                .subCategory;
  }
}
