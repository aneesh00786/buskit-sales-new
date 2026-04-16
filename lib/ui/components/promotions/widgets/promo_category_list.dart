// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItemPromo {
  final String title;
  final List<SubCategoryItem> options;
  CategoryItemPromo({required this.title, required this.options});
}

class CategoryListPromo extends StatefulWidget {
  final CategoryModel categoryModel;
  final List<CategoryItemPromo> categories;
  final Function(String) onOptionSelected;
  final VoidCallback onDrawerToggle;
  final String selectedCategory;

  const CategoryListPromo({
    super.key,
    required this.categoryModel,
    required this.categories,
    required this.onOptionSelected,
    required this.onDrawerToggle,
    required this.selectedCategory,
  });

  @override
  _CategoryListPromoState createState() => _CategoryListPromoState();
}

class _CategoryListPromoState extends State<CategoryListPromo> {
  late int _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.selectedCategory.isNotEmpty
        ? widget.categories
            .indexWhere((cat) => cat.title == widget.selectedCategory)
        : -1;
  }

  @override
  void didUpdateWidget(covariant CategoryListPromo oldWidget) {
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
    final List<CategoryData> categories = widget.categoryModel.data ?? [];

    if (categories.isEmpty) {
      return const Center(
        child: Text("No categories available"),
      );
    }

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
                          if (isExpanded) {
                            _expandedIndex = -1;
                          } else {
                            _expandedIndex = index;

                            if (category.subCategoryItem != null &&
                                category.subCategoryItem!.isNotEmpty) {
                              final firstSubCategory =
                                  category.subCategoryItem!.first;
                              widget.onOptionSelected(firstSubCategory.id ?? '');
                              log('Promo auto-selected subcategory: '
                                  '${firstSubCategory.subCategory} '
                                  '(ID: ${firstSubCategory.id})');
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
                                ? const Icon(Icons.keyboard_arrow_up, size: 16)
                                : const Icon(Icons.keyboard_arrow_down, size: 16),
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
                                  return;
                                }
                                log('Promo selecting subcategory: '
                                    '${option.subCategory} with ID: ${option.id}');
                                widget.onOptionSelected(option.id!);
                                widget.onDrawerToggle();
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
  }
}
