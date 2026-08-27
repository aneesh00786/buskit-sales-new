// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem {
  final String title;
  final List<SubCategoryItem> options;
  CategoryItem({required this.title, required this.options});
}

class CategoryList extends StatefulWidget {
  final ProductsController productsController;
  final List<CategoryItem> categories;
  final Function(String) onOptionSelected;
  final VoidCallback onDrawerToggle;
  final String selectedCategory;
  final Function(String)? onCategoryExpanded;

  const CategoryList({
    super.key,
    required this.productsController,
    required this.categories,
    required this.onOptionSelected,
    required this.onDrawerToggle,
    required this.selectedCategory,
    this.onCategoryExpanded,
  });

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late int _expandedIndex;
  @override
  void initState() {
    super.initState();
    final index = widget.selectedCategory.isNotEmpty
        ? widget.categories
            .indexWhere((cat) => cat.title == widget.selectedCategory)
        : -1;
    _expandedIndex =
        index >= 0 ? index : (widget.categories.isNotEmpty ? 0 : -1);
  }

  @override
  void didUpdateWidget(covariant CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory ||
        oldWidget.categories != widget.categories) {
      setState(() {
        final index = widget.selectedCategory.isNotEmpty
            ? widget.categories
                .indexWhere((cat) => cat.title == widget.selectedCategory)
            : -1;
        _expandedIndex = index >= 0
            ? index
            : (_expandedIndex >= 0
                ? _expandedIndex
                : (widget.categories.isNotEmpty ? 0 : -1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.productsController.categoryData.value.data == null) {
        return const Center(
          child: SpinKitFadingCube(
            color: primaryColor,
            size: 20.0,
          ),
        );
      }

      List<CategoryData> categories =
          widget.productsController.categoryData.value.data!;

      return Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, size: 20),
                  onPressed: () {
                    widget.onDrawerToggle();
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  'Categories'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isExpanded = _expandedIndex == index;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!isExpanded) {
                              _expandedIndex = index;
                              if (widget.onCategoryExpanded != null) widget.onCategoryExpanded!(category.categoryName ?? '');
                              // Auto-select the first subcategory when expanding
                              if (category.subCategoryItem != null &&
                                  category.subCategoryItem!.isNotEmpty) {
                                final firstSubCategory =
                                    category.subCategoryItem!.first;
                                widget.onOptionSelected(
                                    firstSubCategory.id ?? '');
                                widget.productsController
                                        .selectedSubCategoryName.value =
                                    firstSubCategory.subCategory.toString();
                                widget.productsController.selectSubCategory(
                                  firstSubCategory.id.toString(),
                                  firstSubCategory.subCategory ?? '',
                                );
                              }
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isExpanded ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isExpanded ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.categoryName ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: isExpanded ? Colors.white : Colors.black87,
                                ),
                              ),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 18,
                                color: isExpanded ? Colors.white : Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: category.subCategoryItem!.map((option) {
                              return GestureDetector(
                                onTap: () {
                                 
                                  if (option.id == null || option.id!.isEmpty) {
                                    return;
                                  }

                                  widget.onOptionSelected(option.id!);
                                  widget
                                      .productsController
                                      .selectedSubCategoryName
                                      .value = option.subCategory.toString();
                                  widget.productsController
                                      .selectedSubCategoryId.value = option.id!;
                                  widget.onDrawerToggle();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Obx(() {
                                    final isSelected = widget.productsController.selectedSubCategoryId.value == option.id;
                                    return Container(
                                    padding: const EdgeInsets.only(left: 32, right: 14, top: 12, bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? primaryColor.withOpacity(0.3) : Colors.transparent,
                                        width: 1,
                                      )
                                    ),
                                    child: Text(
                                      option.subCategory ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.0,
                                        color: isSelected ? primaryColor : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  );
                                  }),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
