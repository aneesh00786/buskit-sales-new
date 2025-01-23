import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_models.dart';
import 'package:flutter/material.dart';

// class ProductProvider extends ChangeNotifier {
//   final ApiService _apiService = ApiService();
//   List<CategoryP> _categories = [];
//   bool _isLoading = false;
//   String _errorMessage = '';

//   int? _selectedCategoryIndex;
//   String? _selectedSubcategory;
//   String? _selectedSubcategoryForHighlight;
//    Map<String, List<Item>> _itemsBySubcategory = {};

//   List<CategoryP> get categories => _categories;
//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//   int? get selectedCategoryIndex => _selectedCategoryIndex;
//   String? get selectedSubcategory => _selectedSubcategory;
//   String? get selectedSubcategoryForHighlight =>
//       _selectedSubcategoryForHighlight;

//         Map<String, List<Item>> get itemsBySubcategory => _itemsBySubcategory;

//   Future<void> fetchCategories() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final categoryResponse = await _apiService
//           .fetchCategories(); // This should return a CategoryResponse
//       if (categoryResponse.status) {
//         _categories = categoryResponse.data;
//         _errorMessage = '';
//       } else {
//         _errorMessage = categoryResponse.message;
//       }
//     } catch (error) {
//       _errorMessage = 'Failed to load categories';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void selectCategory(int index) {
//     _selectedCategoryIndex = index;
//     _selectedSubcategory = null;
//     _selectedSubcategoryForHighlight = null;
//     notifyListeners();
//   }

//   void selectSubcategory(String subcategory) {
//     _selectedSubcategory = subcategory;
//     _selectedSubcategoryForHighlight = subcategory;
//     notifyListeners();
//   }

//   Map<String, List<Item>> _initializeItemsBySubcategory(List<CategoryP> categories) {
//     // Initialize itemsBySubcategory based on your categories and items data
//     final Map<String, List<Item>> itemsBySubcategory = {};
//     for (final category in categories) {
//       for (final item in category.categoryItem) {
//         // Assume Item is a class that holds item details
//         itemsBySubcategory[item.subCategory] = []; // Initialize with empty list
//       }
//     }
//     return itemsBySubcategory;
//   }

// }
class ProductProvider extends ChangeNotifier {
  ProductProvider() {
    fetchCategories();
    fetchDatass();
  }
  final ApiService _apiService = ApiService();
  List<CategoryP> _categories = [];
  List<StoreDataPo> _storeData = [];
  bool _isLoading = false;
  String _errorMessage = '';

  int? _selectedCategoryIndex;
  String? _selectedSubcategory;
  String? _selectedSubcategoryForHighlight;
  Map<String, List<ProductPo>> _productsByCategory = {};

  List<CategoryP> get categories => _categories;
  List<StoreDataPo> get storeData => _storeData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int? get selectedCategoryIndex => _selectedCategoryIndex;
  String? get selectedSubcategory => _selectedSubcategory;
  String? get selectedSubcategoryForHighlight => _selectedSubcategoryForHighlight;
  Map<String, List<ProductPo>> get productsByCategory => _productsByCategory;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    print('old fetch categpries');
    try {
      final categoryResponse = await _apiService.fetchCategories();
      if (categoryResponse.status) {
        _categories = categoryResponse.data;
        _errorMessage = '';
      } else {
        _errorMessage = categoryResponse.message;
      }
    } catch (error) {
      _errorMessage = 'Failed to load categories';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDatass() async {
    _isLoading = true;
    notifyListeners();
    try {
      final dataResponse = await _apiService.fetchProductData();
      if (dataResponse.status) {
        _storeData = dataResponse.data as List<StoreDataPo> ;
        _productsByCategory = initializeProductsByCategory(_storeData);
        _errorMessage = '';
      } else {
        _errorMessage = dataResponse.message;
      }
    } catch (error) {
      _errorMessage = 'Failed to load data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Map<String, List<ProductPo>> initializeProductsByCategory(List<StoreDataPo> storeData) {
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

  // Automatically select the first subcategory if available
  if (_categories[index].categoryItem.isNotEmpty) {
    _selectedSubcategory = _categories[index].categoryItem[0].subCategory;
    _selectedSubcategoryForHighlight = _selectedSubcategory;
  }

  // fetchData(); // Call fetchData when category is selected (if needed)
  notifyListeners();
}

  void selectSubcategory(String subcategory) {
    _selectedSubcategory = subcategory;
    _selectedSubcategoryForHighlight = subcategory;
    notifyListeners();
  }
}
