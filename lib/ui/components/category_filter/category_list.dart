// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  const CategoryList({
    super.key,
    required this.productsController,
    required this.categories,
    required this.onOptionSelected,
    required this.onDrawerToggle,
    required this.selectedCategory,
  });

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late int _expandedIndex;
  Future<CategoryModel>? _categoryFuture;
  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.selectedCategory.isNotEmpty
        ? widget.categories
            .indexWhere((cat) => cat.title == widget.selectedCategory)
        : -1;
    log('The Hive Categoryy List : ${_categoryFuture.toString()}');
    _categoryFuture = widget.productsController.loadDataOfCategories();
  }

  @override
  void didUpdateWidget(covariant CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      setState(() {
        _expandedIndex = widget.selectedCategory.isNotEmpty
            ? widget.categories
                .indexWhere((cat) => cat.title == widget.selectedCategory)
            : -1;
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
          border: Border.all(color: Colors.grey.shade500),
          borderRadius: BorderRadius.circular(16),
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
                  'Categories',
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
                            // _expandedIndex = isExpanded ? -1 : index;
                            if (isExpanded) {
                              _expandedIndex = -1;
                            } else {
                              _expandedIndex = index;
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
                                // Optionally, do not close the drawer here. Remove the next line if you want the drawer to stay open.
                                // widget.onDrawerToggle();
                                log('Auto-selected subcategory: ${firstSubCategory.subCategory} (ID: ${firstSubCategory.id})');
                              }
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.categoryName ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              isExpanded
                                  ? const Icon(
                                      Icons.keyboard_arrow_up,
                                      size: 16,
                                    )
                                  : const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: category.subCategoryItem!.map((option) {
                              return GestureDetector(
                                onTap: () {
                                  if (option.id == null || option.id!.isEmpty) {
                                    log('ERROR: Subcategory ${option.subCategory} has no ID');
                                    return;
                                  }

                                  log('Selecting subcategory: ${option.subCategory} with ID: ${option.id}');
                                  widget.onOptionSelected(option.id!);
                                  widget
                                      .productsController
                                      .selectedSubCategoryName
                                      .value = option.subCategory.toString();
                                  widget.productsController
                                      .selectedSubCategoryId.value = option.id!;
                                  widget.onDrawerToggle();
                                  log('Selected subcategory: ${option.subCategory} with ID: ${option.id}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 7.0, left: 10, right: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      option.subCategory ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
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
