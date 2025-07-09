// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  final List<CategoryData> categories;
  final Function(String) onOptionSelected;
  final VoidCallback onDrawerToggle;
    final ProductsController productsController;

  const CategoryList(
      {super.key,
      required this.categories,
      required this.onOptionSelected,
      required this.productsController,
      required this.onDrawerToggle});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late int _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = 0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Heading with menu button
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, size: 20),
                onPressed: () {
                  widget.onDrawerToggle();
                },
              ),
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final isExpanded = _expandedIndex == index;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedIndex = -1;
                          } else {
                            _expandedIndex = index;
                          }
                        });
                      },
                      child: Container(
                        width: double.maxFinite,
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
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _expandedIndex == index
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
                                widget.onDrawerToggle();
                                
                                   widget.productsController
                                    .selectedSubCategoryName
                                    .value = option.subCategory.toString();
                                   widget.productsController
                                    .selectedSubCategoryId
                                    .value = option.id!;
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 7.0, left: 10, right: 10),
                                child: Container(
                                  width: double.maxFinite,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    option.subCategory ?? '',
                                    style: const TextStyle(
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
  }
}
