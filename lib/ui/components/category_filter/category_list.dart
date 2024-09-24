// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
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

  CategoryList({
    super.key,
    required this.productsController,
    required this.categories,
    required this.onOptionSelected,
    required this.onDrawerToggle,
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
    _expandedIndex = 0;
    log('The HIve Categoryy List : ${_categoryFuture.toString()}');
    _categoryFuture = widget.productsController.loadDataOfCategories();
  }
  @override
  Widget build(BuildContext context) {
    log('The HIve Categoryy List : ${_categoryFuture.toString()}');
    return FutureBuilder<CategoryModel>(
      future: _categoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //return Center(child: CircularProgressIndicator());
          return Center(child: Text('no internet'));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
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
                Expanded(child: Obx(() {
                  if (widget.productsController.categoryData.value.data ==
                      null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
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
                                _expandedIndex = isExpanded ? -1 : index;
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category?.categoryName ?? '',
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
                                children:
                                    category!.subCategoryItem!.map((option) {
                                  return GestureDetector(
                                    onTap: () {
                                      widget.onOptionSelected(
                                          option.subCategory ?? '');
                                      widget.onDrawerToggle();
                                      log(option.subCategory ?? '');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 7.0, left: 10, right: 10),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                  );
                })),
              ],
            ),
          );
        } else {
          return Center(child: Text('No category data available'));
        }
      },
    );
  }
}
