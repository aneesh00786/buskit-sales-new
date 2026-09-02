import 'dart:async';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum CatalogSearchType {
  product,
  category,
  subcategory,
}

class CatalogSearchBar extends StatefulWidget {
  final ProductsController productsController;
  final Function(CategoryData category) onCategorySelected;
  final Function(SubCategoryItem subCategory, CategoryData parentCategory)
      onSubCategorySelected;
  final Function(ProductModel product) onProductSelected;

  const CatalogSearchBar({
    super.key,
    required this.productsController,
    required this.onCategorySelected,
    required this.onSubCategorySelected,
    required this.onProductSelected,
  });

  @override
  State<CatalogSearchBar> createState() => _CatalogSearchBarState();
}

class _CatalogSearchBarState extends State<CatalogSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  CatalogSearchType _selectedType = CatalogSearchType.product;
  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  List<CategoryData> _filteredCategories = [];
  List<Map<String, dynamic>> _filteredSubCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus &&
          _searchController.text.trim().isNotEmpty &&
          _selectedType != CatalogSearchType.product) {
        _showOverlay();
      } else if (!_focusNode.hasFocus) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _hideOverlay();
    widget.productsController.clearCatalogProductSearch();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      _hideOverlay();
      widget.productsController.clearCatalogProductSearch();
      setState(() {
        _filteredCategories.clear();
        _filteredSubCategories.clear();
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 200), () {
      _performSearch(trimmedQuery);
    });
  }

  Future<void> _performSearch(String query) async {
    if (_selectedType == CatalogSearchType.product) {
      // Direct in-grid search for product type
      _hideOverlay();
      await widget.productsController.searchProductsInCatalog(query);
      return;
    }

    // Autocomplete dropdown for Category and Subcategory
    setState(() {
      _isLoading = true;
    });

    final lowerQuery = query.toLowerCase();

    if (_selectedType == CatalogSearchType.category) {
      final List<CategoryData> allCategories =
          widget.productsController.categoryData.value.data ?? [];
      _filteredCategories = allCategories.where((cat) {
        final name = cat.categoryName?.toLowerCase() ?? '';
        return name.contains(lowerQuery);
      }).toList();
    } else if (_selectedType == CatalogSearchType.subcategory) {
      final List<CategoryData> allCategories =
          widget.productsController.categoryData.value.data ?? [];
      final List<Map<String, dynamic>> subCatList = [];

      for (final cat in allCategories) {
        if (cat.subCategoryItem != null) {
          for (final sub in cat.subCategoryItem!) {
            final subName = sub.subCategory?.toLowerCase() ?? '';
            if (subName.contains(lowerQuery)) {
              subCatList.add({
                'subCategory': sub,
                'parentCategory': cat,
              });
            }
          }
        }
      }
      _filteredSubCategories = subCatList;
    }

    setState(() {
      _isLoading = false;
    });

    _showOverlay();
  }

  void _showOverlay() {
    if (_selectedType == CatalogSearchType.product) return;
    _hideOverlay();
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _layerLink.leaderSize?.width ?? 350,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 52),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _buildResultsList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (_selectedType == CatalogSearchType.category) {
      if (_filteredCategories.isEmpty) {
        return _buildNoResults("No categories found".tr);
      }
      return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: _filteredCategories.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final cat = _filteredCategories[index];
          final subCount = cat.subCategoryItem?.length ?? 0;
          return ListTile(
            dense: true,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: lightPrimaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.category_outlined,
                  size: 20, color: primaryColor),
            ),
            title: Text(
              cat.categoryName ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              "$subCount ${'Subcategories'.tr}",
              style: TextStyle(fontSize: 12, color: const Color(0xFF0F172A)),
            ),
            trailing:
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            onTap: () {
              _hideOverlay();
              _searchController.clear();
              _focusNode.unfocus();
              widget.onCategorySelected(cat);
            },
          );
        },
      );
    } else if (_selectedType == CatalogSearchType.subcategory) {
      if (_filteredSubCategories.isEmpty) {
        return _buildNoResults("No subcategories found".tr);
      }
      return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: _filteredSubCategories.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final item = _filteredSubCategories[index];
          final SubCategoryItem sub = item['subCategory'];
          final CategoryData parent = item['parentCategory'];

          return ListTile(
            dense: true,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_tree_outlined,
                  size: 20, color: Color(0xFF2563EB)),
            ),
            title: Text(
              sub.subCategory ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              parent.categoryName ?? '',
              style: TextStyle(fontSize: 12, color: const Color(0xFF0F172A)),
            ),
            trailing:
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            onTap: () {
              _hideOverlay();
              _searchController.clear();
              _focusNode.unfocus();
              widget.onSubCategorySelected(sub, parent);
            },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNoResults(String message) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_outlined,
                size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13.5,
                color: const Color(0xFF0F172A),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case CatalogSearchType.category:
        return "Categories...".tr;
      case CatalogSearchType.subcategory:
        return "Subcategories...".tr;
      case CatalogSearchType.product:
        return "Products by name, code, brand...".tr;
    }
  }

  String _getTypeLabel(CatalogSearchType type) {
    switch (type) {
      case CatalogSearchType.category:
        return "Category".tr;
      case CatalogSearchType.subcategory:
        return "Subcategory".tr;
      case CatalogSearchType.product:
        return "Product".tr;
    }
  }

  IconData _getTypeIcon(CatalogSearchType type) {
    switch (type) {
      case CatalogSearchType.category:
        return Icons.category_outlined;
      case CatalogSearchType.subcategory:
        return Icons.account_tree_outlined;
      case CatalogSearchType.product:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Search Type Selector Dropdown ──────────────────────────────
            Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1.2),
                ),
              ),
              child: PopupMenuButton<CatalogSearchType>(
                initialValue: _selectedType,
                tooltip: "Select search type".tr,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (CatalogSearchType type) {
                  setState(() {
                    _selectedType = type;
                  });
                  _hideOverlay();
                  if (type != CatalogSearchType.product) {
                    widget.productsController.clearCatalogProductSearch();
                  }
                  if (_searchController.text.trim().isNotEmpty) {
                    _performSearch(_searchController.text.trim());
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: CatalogSearchType.product,
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 18, color: Color(0xFF059669)),
                        const SizedBox(width: 8),
                        Text("Product".tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: CatalogSearchType.category,
                    child: Row(
                      children: [
                        const Icon(Icons.category_outlined,
                            size: 18, color: primaryColor),
                        const SizedBox(width: 8),
                        Text("Category".tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: CatalogSearchType.subcategory,
                    child: Row(
                      children: [
                        const Icon(Icons.account_tree_outlined,
                            size: 18, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Text("Subcategory".tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(_selectedType),
                      size: 18,
                      color: _selectedType == CatalogSearchType.product
                          ? const Color(0xFF059669)
                          : _selectedType == CatalogSearchType.category
                              ? primaryColor
                              : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTypeLabel(_selectedType),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ),

            // ── Search Input Field ─────────────────────────────────────────
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: _getHintText(),
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
