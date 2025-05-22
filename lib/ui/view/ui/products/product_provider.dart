
import 'package:busskit_salesexecutive/ui/view/ui/products/product_models.dart';
import 'package:flutter/material.dart';
class ProductProvider extends ChangeNotifier {
  final List<CategoryP> _categories = [];
  final List<StoreDataPo> _storeData = [];
  final bool _isLoading = false;
  final String _errorMessage = '';
  int? _selectedCategoryIndex;
  String? _selectedSubcategory;
  String? _selectedSubcategoryForHighlight;
  final Map<String, List<ProductPo>> _productsByCategory = {};
  List<CategoryP> get categories => _categories;
  List<StoreDataPo> get storeData => _storeData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int? get selectedCategoryIndex => _selectedCategoryIndex;
  String? get selectedSubcategory => _selectedSubcategory;
  String? get selectedSubcategoryForHighlight =>
      _selectedSubcategoryForHighlight;
  Map<String, List<ProductPo>> get productsByCategory => _productsByCategory;
  Map<String, List<ProductPo>> initializeProductsByCategory(
      List<StoreDataPo> storeData) {
    final Map<String, List<ProductPo>> productsByCategory = {};
    for (final store in storeData) {
      for (final product in store.product) {
        if (!productsByCategory.containsKey(store.scid)) {
          productsByCategory[store.scid] = [];
        }
        productsByCategory[store.scid]!.add(product);
      }
    }
    return productsByCategory;
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    _selectedSubcategory = null;
    _selectedSubcategoryForHighlight = null;
    if (_categories[index].categoryItem.isNotEmpty) {
      _selectedSubcategory = _categories[index].categoryItem[0].subCategory;
      _selectedSubcategoryForHighlight = _selectedSubcategory;
    }
    notifyListeners();
  }

  void selectSubcategory(String subcategory) {
    _selectedSubcategory = subcategory;
    _selectedSubcategoryForHighlight = subcategory;
    notifyListeners();
  }
}
