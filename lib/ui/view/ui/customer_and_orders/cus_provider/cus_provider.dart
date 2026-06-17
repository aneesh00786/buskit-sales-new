import 'dart:convert';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../csord_model/customers_orders_model.dart';

class CustomersProvider with ChangeNotifier {
  final ApiService _apiService;
  final Logger _logger;
  List<YearList> get yearList => _yearList;
  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  CustomersProvider({
    required ApiService apiService,
    required Logger logger,
  })  : _apiService = apiService,
        _logger = logger {
    // fetchCustomerData();
  }
  String _errorMessage = '';
  bool _isLoading = false;
  Future<CustomerResponseModelxx>? _customersFuture;
  FilterDateEnum _selectedFilter = FilterDateEnum.thisMonth;
  String _selectedStartDate = '';
  String _selectedEndDate = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  File? get imageFile => _imageFile;
  int _currentPage = 1;
  int _totalPages = 1;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Future<CustomerResponseModelxx>? get customersFuture => _customersFuture;
  FilterDateEnum get selectedFilter => _selectedFilter;

  String get selectedStartDate => _selectedStartDate;
  String get selectedEndDate => _selectedEndDate;
  String get searchCustomerName => _searchCustomerName;

  final TextEditingController searchController = TextEditingController();
  var _searchCustomerName = '';
  String get selectedCustomerName => _searchCustomerName;

  Future<ApiResponseModel>? _customersDashFuture;

  Future<ApiResponseModel>? get customersDashFuture => _customersDashFuture;

  Future<CustomerTotalSaleResponse>? _customerTotalSaleResponseFuture;

  Future<CustomerRevenueResponse>? _customerRevenueResponseFuture;

  Future<CustomerTotalSaleResponse>? get customerTotalSaleResponseFuture =>
      _customerTotalSaleResponseFuture;

  Future<CustomerRevenueResponse>? get customerRevenueResponseFuture =>
      _customerRevenueResponseFuture;

  Future<ApiResponsees>? _countFuture;

  Future<ApiResponsees>? get countFuture => _countFuture;
  int? get selectedYear => _selectedYear;
  final List<RecentOrder> _selectedOrders = [];
  List<RecentOrder> get selectedOrders => _selectedOrders;
  // ignore: unused_field
  List<CustomerModelxx> get customers => _customers;
  List<CustomerModelxx> _customers = [];
  List<CustomerModelxx> _filteredCustomers = [];
  List<OrderTotalxx> _orderTotalList = [];
  List<YearsListOfAll> _yearsListOfAllList = [];

  List<OrderTotalxx> get orderTotalList => _orderTotalList;
  List<YearsListOfAll> get yearsListOfAllList => _yearsListOfAllList;

  List<CustomerModelxx> get filteredCustomers => _filteredCustomers;

  /// Gets the current page of customers for display
  List<CustomerModelxx> get currentPageCustomers => getCurrentPageCustomers();
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  Future<ProductResponse>? _productResponse;
  Future<ProductResponse>? get productResponse => _productResponse;
  int cartItemCount = 0;
  List<BarChartGroupData> barGroups = [];
  Future<OrderResponse>? _orderResponse;
  Future<OrderResponse>? get orderResponse => _orderResponse;
  Future<CustomerResponse>? _customerResponse;
  Future<CustomerResponse>? get customerResponse => _customerResponse;


  int _selectedDashboardYear = DateTime.now().year;
  int get selectedDashboardYear => _selectedDashboardYear;

  void resetFilters() {
    _selectedFilter = FilterDateEnum.thisMonth;
  }

  void resetProvider() {
    _selectedFilter = FilterDateEnum.thisMonth;
    _selectedStartDate = '';
    _selectedEndDate = '';
    _searchCustomerName = '';
    _customers = [];
    searchController.clear();
  }
  void updateFilterSelection(FilterDateEnum newFilter) {
  _selectedFilter = newFilter;
  notifyListeners(); 
}

  void setCurrentMonthDates() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateFormat = DateFormat('yyyy-MM-dd');
    _selectedStartDate = dateFormat.format(firstDayOfMonth);
    _selectedEndDate = dateFormat.format(lastDayOfMonth);
  }

  void createBarGroups({
    required List<CategoryPerformance> categoryPerformance,
    required List<ValueTargetDatum> valuePerformance,
    required String targetType,
    required String staffProjection,
  }) {
    barGroups = targetType == '0'
        ? valuePerformance.asMap().entries.map((entry) {
            int index = entry.key;
            ValueTargetDatum perf = entry.value;
            num target = perf.actualTarget ?? 0.0;
            num projection = perf.actualProjection ?? 0.0;
            num actual = perf.actualSales ?? 0.0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: target.toDouble(),
                  color: const Color(0xff3b6491),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
                if (staffProjection == "1")
                  BarChartRodData(
                    toY: projection.toDouble(),
                    color: const Color(0xff15396a),
                    width: 8,
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide.none,
                  ),
                BarChartRodData(
                  toY: actual.toDouble(),
                  color: const Color(0xff7a8f3d),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
              ],
            );
          }).toList()
        : categoryPerformance.asMap().entries.map((entry) {
            int index = entry.key;
            CategoryPerformance perf = entry.value;
            num target = perf.actualTarget ?? 0.0;
            num projection = perf.actualProjection ?? 0.0;
            num actual = num.parse(perf.actualSales.toString());

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: target.toDouble(),
                  color: const Color(0xff3b6491),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
                if (staffProjection == "1")
                  BarChartRodData(
                    toY: projection.toDouble(),
                    color: const Color(0xff15396a),
                    width: 8,
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide.none,
                  ),
                BarChartRodData(
                  toY: actual.toDouble(),
                  color: const Color(0xff7a8f3d),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
              ],
            );
          }).toList();
  }

  Future<int> getCartItemCounts(String customerId) async {
    try {
      final cartItems = await CartDatabaseManager().getCartItems(customerId);
      final count = cartItems.length;
      cartItemCount = count;
      notifyListeners();
      updateCartCount(customerId);
      return cartItemCount;
    } catch (e) {
      return 0;
    }
  }
  void updateDashboardYear(int year) {
    if (_selectedDashboardYear != year) {
      _selectedDashboardYear = year;
      // Delay the UI update until the current build frame is fully completed
      Future.microtask(() {
        notifyListeners();
      });
    }
  }
  // void updateDashboardYear(int year) {
  //   _selectedDashboardYear = year;
  //   notifyListeners();
  // }

  Future<void> updateCartCount(String customerId) async {
    try {
      final cartItems = await CartDatabaseManager().getCartItems(customerId);
      cartItemCount = cartItems.length;
      notifyListeners();
    } catch (e) {
      //
    }
  }

Future<void> fetchChartCategoryPerformance(
      dynamic customerId, dynamic catId, dynamic selectedYearCategory) async {
    try {
      // Debouncing network requests

      // OLD CODE (Problem):
      // final now = DateTime.now();
      // final firstDayOfYear = DateTime(now.year, 1, 1);

      // NEW CODE (Fix):
      // Use the class-level variable 'selectedDashboardYear'
      int year = selectedDashboardYear; 
      
      final dateFormat = DateFormat('yyyy-MM-dd');

      final firstDayOfYear = DateTime(year, 1, 1);
      final lastDayOfYear = DateTime(year, 12, 31);

      _productResponse = _apiService.fetchCustomerDashboardCartData(
        customerId: customerId,
        catId: catId,
        selectedYearCategory: selectedYearCategory,
        // startDate: selectedStartDate,
        // endDate: selectedEndDate,
        startDate: dateFormat.format(firstDayOfYear),
        endDate: dateFormat.format(lastDayOfYear),
      );

      // notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }


  // Future<void> fetchChartCategoryPerformance(
  //     dynamic customerId, dynamic catId, dynamic selectedYearCategory) async {
  //   //comeback
  //   final now = DateTime.now();
  //   final dateFormat = DateFormat('yyyy-MM-dd');

  //   final firstDayOfYear = DateTime(now.year, 1, 1);
  //   final lastDayOfYear = DateTime(now.year, 12, 31);

  //   try {
  //     _productResponse = _apiService.fetchCustomerDashboardCartData(
  //       customerId: customerId,
  //       catId: catId,
  //       selectedYearCategory: selectedYearCategory,
  //       startDate: dateFormat.format(firstDayOfYear),
  //       endDate: dateFormat.format(lastDayOfYear),
  //     );
  //   } catch (e, stackTrace) {
  //     _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

  set currentPage(int newPage) {
    if (newPage != _currentPage) {
      _currentPage = newPage;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) async {
    _searchCustomerName = query;
    _currentPage = 1;
    _errorMessage = ''; // Clear previous error messages

    try {
      if (query.isEmpty) {
        _filteredCustomers.clear();
        // When clearing search, reload cached data if offline
        bool isOnline = await ConnectivityService().isOnline();
        if (!isOnline) {
          await loadCachedDataForCurrentPage();
        } else {
          await fetchCustomerData();
        }
      } else {
        _filteredCustomers.clear();
        notifyListeners();

        // Check if offline and perform local search
        bool isOnline = await ConnectivityService().isOnline();
        if (!isOnline) {
          await performOfflineSearch(query);
        } else {
          await fetchCustomerData();
        }
      }
    } catch (e) {
      //
    } finally {
      notifyListeners();
    }
  }

  /// Performs offline search by searching through all cached customer data
  Future<void> performOfflineSearch(String searchQuery) async {
    try {
      _isLoading = true;
      notifyListeners();

      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      final customerBox = Hive.box('customerBox');
      final List<CustomerModelxx> allCachedCustomers = [];

      // Search through all cached pages
      int page = 1;
      bool hasMoreData = true;

      while (hasMoreData) {
        final cacheKey = '${companyId}_customer_list_$page';
        final cachedData = customerBox.get(cacheKey);

        if (cachedData != null) {
          try {
            final safeMap =
                jsonDecode(jsonEncode(cachedData)) as Map<String, dynamic>;
            final response = CustomerResponseModelxx.fromJson(safeMap);
            allCachedCustomers.addAll(response.data);

            // Check if there are more pages
            if (page >= response.pagination.totalPages) {
              hasMoreData = false;
            } else {
              page++;
            }
          } catch (e) {
            hasMoreData = false;
          }
        } else {
          hasMoreData = false;
        }
      }

      // Perform local search on all cached customers
      final List<CustomerModelxx> searchResults =
          allCachedCustomers.where((customer) {
        final query = searchQuery.toLowerCase();
        return customer.businessName.toLowerCase().startsWith(query);
      }).toList();

      if (searchResults.isNotEmpty) {
        // Store all search results and calculate pagination
        _customers = searchResults;
        _filteredCustomers = searchResults;

        // Calculate total pages based on search results (assuming 10 items per page)
        const int itemsPerPage = 10;
        _totalPages = (searchResults.length / itemsPerPage).ceil();
        _currentPage = 1; // Reset to first page for search results

        // Set order totals and year list from the first cached page if available
        if (allCachedCustomers.isNotEmpty) {
          final firstCacheKey = '${companyId}_customer_list_1';
          final firstCachedData = customerBox.get(firstCacheKey);
          if (firstCachedData != null) {
            try {
              final safeMap = jsonDecode(jsonEncode(firstCachedData))
                  as Map<String, dynamic>;
              final response = CustomerResponseModelxx.fromJson(safeMap);
              setOrderTotal(response.orderTotal);
              setYearList(response.yearsListOfAll);
            } catch (e) {
              //
            }
          }
        }

        _errorMessage = '';
      } else {
        _filteredCustomers = [];
        _errorMessage =
            'No customers found matching "$searchQuery" in offline data.';
      }
    } catch (e) {
      _errorMessage = 'Error performing offline search: $e';
      _filteredCustomers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads cached data for the current page when offline
  Future<void> loadCachedDataForCurrentPage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      final customerBox = Hive.box('customerBox');
      final cacheKey = '${companyId}_customer_list_$_currentPage';

      final cachedData = customerBox.get(cacheKey);
      if (cachedData != null) {
        try {
          final safeMap =
              jsonDecode(jsonEncode(cachedData)) as Map<String, dynamic>;
          final response = CustomerResponseModelxx.fromJson(safeMap);

          setCustomers(response.data, response.pagination.totalPages);
          setOrderTotal(response.orderTotal);
          setYearList(response.yearsListOfAll);
          _errorMessage = '';
        } catch (e) {
          _filteredCustomers = [];
          _errorMessage = 'Corrupted offline data for this page.';
        }
      } else {
        _filteredCustomers = [];
        _errorMessage = 'No offline data for this page.';
      }
    } catch (e) {
      _errorMessage = 'Error loading offline data: $e';
      _filteredCustomers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCustomers(List<CustomerModelxx> customers, int totalPages) {
    _customers = customers;
    _filteredCustomers = customers;
    _totalPages = totalPages;
    notifyListeners();
  }

  /// Gets the current page of customers for display (handles pagination for search results)
  List<CustomerModelxx> getCurrentPageCustomers() {
    if (_searchCustomerName.isNotEmpty) {
      // For search results, implement pagination
      const int itemsPerPage = 10;
      final startIndex = (_currentPage - 1) * itemsPerPage;
      final endIndex = startIndex + itemsPerPage;

      if (startIndex < _customers.length) {
        final result = _customers.sublist(startIndex,
            endIndex > _customers.length ? _customers.length : endIndex);
        return result;
      } else {
        return [];
      }
    } else {
      // For normal browsing, return all filtered customers
      return _filteredCustomers;
    }
  }

  void setOrderTotal(List<OrderTotalxx> orderTotals) {
    _orderTotalList = orderTotals;
    notifyListeners();
  }

  void setYearList(List<YearsListOfAll> yearsListOfAll) {
    _yearsListOfAllList = yearsListOfAll;
  }


 Future<void> fetchCustomerDashboardCountData(String customerId) async {
  // ERROR WAS HERE: 
  // final now = DateTime.now(); <-- This was forcing it to be the current real-world year
  
  // FIX: Use the variable you updated in step 2 of your dropdown logic
  if (customerId.isEmpty) return;
  final int yearToUse = _selectedDashboardYear; // or selectedDashboardYear (depending on your variable name)

  final dateFormat = DateFormat('yyyy-MM-dd');
  
  // Create dates based on the SELECTED year
  final firstDayOfYear = DateTime(yearToUse, 1, 1);
  final lastDayOfYear = DateTime(yearToUse, 12, 31);

  try {
    _countFuture = _apiService.fetchOrderCount(
      customerId,
      dateFormat.format(firstDayOfYear),
      dateFormat.format(lastDayOfYear),
    );
    notifyListeners();
  } catch (e, stackTrace) {
    _logger.e('Error fetching customer dashboard data',
        error: e, stackTrace: stackTrace);
    rethrow;
  }
}

  // Future<void> fetchCustomerDashboardCountData(
  //   String customerId,
  // ) async {
  //   final now = DateTime.now();
  //   final dateFormat = DateFormat('yyyy-MM-dd');
  //   final firstDayOfYear = DateTime(now.year, 1, 1);
  //   final lastDayOfYear = DateTime(now.year, 12, 31);
  //   try {
  //     _countFuture = _apiService.fetchOrderCount(
  //       customerId,
  //       dateFormat.format(firstDayOfYear),
  //       dateFormat.format(lastDayOfYear),
  //     );
  //     notifyListeners();
  //   } catch (e, stackTrace) {
  //     _logger.e('Error fetching customer dashboard data',
  //         error: e, stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

  Future<void> pickImage(gallery) async {
    final pickedFile = await _picker.pickImage(source: gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> addLead({
    required CustomerDashMo admin,
    required String salsmanId,
  }) async {
    try {
      await _apiService
          .addLead(
              model: admin,
              adminProfilePicture: imageFile!,
              salesmanId: salsmanId)
          .then((value) => fetchCustomerData());

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    }
  }
    Future<dynamic> addCustomer({
    required Map<String, dynamic> admin,
    required String salsmanId,
  }) async {
    try {
      var response = await _apiService
          .addCustomer(
              model: admin,
              adminProfilePicture: imageFile,
              salesmanId: salsmanId);

      await fetchCustomerData();
      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    }
  }

  // Future<void> addCustomer({
  //   required Map<String, dynamic> admin,
  //   required String salsmanId,
  // }) async {
  //   try {
  //     await _apiService
  //         .addCustomer(
  //             model: admin,
  //             adminProfilePicture: imageFile!,
  //             salesmanId: salsmanId)
  //         .then((value) => fetchCustomerData());

  //     notifyListeners();
  //   } catch (e) {
  //     throw Exception('Failed to update admin: $e');
  //   } finally {
  //     _imageFile = null;
  //   }
  // }

  Future<void> fetchCustomersDataDash(String customerId) async {
    if (customerId.isEmpty) return;
    try {
      _customerResponse = _apiService.fetchOneCustomer(customerId);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

   Future<void> fetchOrdersForCustomDash(OrderStatus s, String custId,
      {bool checkDate = false}) async {
    // this is for customer dashboard
    try {
      // OLD CODE (Problem):
      // final now = DateTime.now();
      // final startDate = DateTime(now.year, 1, 1);
      // final endDate = DateTime(now.year, 12 + 1, 0);

      // NEW CODE (Fix):
      // Use the class-level variable 'selectedDashboardYear'
      int year = selectedDashboardYear;

      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31);

      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
      
      dynamic orderType;

      switch (s) {
        case OrderStatus.delivered:
          orderType = '';
        case OrderStatus.estimates:
          orderType = 7;
        case OrderStatus.preOrder:
          orderType = 0;
        case OrderStatus.draft:
          orderType = 4;
        case OrderStatus.cancelled:
          orderType = 3;
        default:
          orderType = '';
      }

      _orderResponse = Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchCustomerDashOrders(
          cusId: custId,
          salesmanId: "",
          orderType: orderType,
          startDate: formattedStartDate,
          endDate: formattedEndDate,
          orderStatus: s,
          checkDate: checkDate,
        );
      });
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }


  // Future<void> fetchOrdersForCustomDash(OrderStatus s, String custId,
  //     {bool checkDate = false}) async {
  //   try {
  //     final now = DateTime.now();
  //     final startDate = DateTime(now.year, 1, 1);
  //     final endDate = DateTime(now.year, 12 + 1, 0);

  //     final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
  //     final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

  //     dynamic orderType;

  //     switch (s) {
  //       case OrderStatus.delivered:
  //         orderType = '';
  //       case OrderStatus.estimates:
  //         orderType = 7;
  //       case OrderStatus.preOrder:
  //         orderType = 0;
  //       case OrderStatus.draft:
  //         orderType = 4;
  //       case OrderStatus.cancelled:
  //         orderType = 3;
  //       default:
  //         orderType = '';
  //     }
  //     _orderResponse = Future.delayed(const Duration(milliseconds: 300), () {
  //       final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  //       return _apiService.fetchCustomerDashOrders(
  //         cusId: custId,
  //         salesmanId: salesmanId,
  //         orderType: orderType,
  //         startDate: formattedStartDate,
  //         endDate: formattedEndDate,
  //         orderStatus: s,
  //         checkDate: checkDate,
  //       );
  //     });
  //     notifyListeners();
  //   } catch (e, stackTrace) {
  //     _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

  List<YearList> _yearList = [];
  int? _selectedYear;

  Future<void> fetchCustomerDashboardDataSalseData(String customerId) async {
    if (customerId.isEmpty) return;
    final now = DateTime.now();
    int currentYear = now.year;
    try {
      _customerTotalSaleResponseFuture =
          _apiService.fetchCustomerTotalSale(customerId, currentYear);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  // Future<void> fetchCustomerDashboardDataSalseData(String customerId) async {
  //   final now = DateTime.now();
  //   int currentYear = now.year;
  //   try {
  //     _customerTotalSaleResponseFuture =
  //         _apiService.fetchCustomerTotalSale(customerId, currentYear);
  //     notifyListeners();
  //   } catch (e, stackTrace) {
  //     _logger.e('Error fetching customer dashboard data',
  //         error: e, stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

  Future<void> fetchCustomerDashboardRevenueData(String customerId) async {
    if (customerId.isEmpty) return;
    // OLD (Problematic):
    // final now = DateTime.now();
    // final startDate = DateTime(now.year, 1, 1);
    
    // NEW (Fix): 
    // Use the variable 'selectedDashboardYear' from your provider state
    int year = selectedDashboardYear; 

    // Construct dates based on the selected year
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      _customerRevenueResponseFuture = _apiService.fetchCustomerRevenueData(
          customerId, 
          year, 
          formattedStartDate, 
          formattedEndDate
      );
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer revenue dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }


  // Future<void> fetchCustomerDashboardRevenueData(String customerId) async {
  //   final now = DateTime.now();
  //   final startDate1 = DateTime(now.year, 1, 1);
  //   final endDate1 = DateTime(now.year, 12, 31);

  //   final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate1);
  //   final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate1);
  //   int currentYear = now.year;

  //   try {
  //     _customerRevenueResponseFuture = _apiService.fetchCustomerRevenueData(
  //         customerId, currentYear, formattedStartDate, formattedEndDate);
  //     notifyListeners();
  //   } catch (e, stackTrace) {
  //     _logger.e('Error fetching customer dashboard data',
  //         error: e, stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

 Future<void> fetchCustomerDashboardData(String customerId) async {
    // USE THE SELECTED YEAR HERE
    if (customerId.isEmpty) return;
    int currentYear = _selectedDashboardYear; 
    
    final startDate = DateTime(currentYear, 1, 1);
    // Note: DateTime(year, 13, 0) gives Dec 31st of that year
    final endDate = DateTime(currentYear, 13, 0); 

    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      // Pass the selected year and calculated dates to API
      _customersDashFuture = _apiService
          .fetchCustomerDashboardDataa(
              customerId, currentYear, formattedStartDate, formattedEndDate)
          .then((response) {
        _yearList = response.data.yearList;
        notifyListeners();
        return response;
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  void toggleOrderSelection(RecentOrder order) {
    if (_selectedOrders.contains(order)) {
      _selectedOrders.remove(order);
    } else {
      _selectedOrders.add(order);
    }
    notifyListeners();
  }

  bool isOrderSelected(RecentOrder order) {
    return _selectedOrders.contains(order);
  }
  Future<void> fetchCustomerData({int page = 1}) async {
    _errorMessage = '';
    NotificationController notificationController =
        Get.find<NotificationController>();
    final dashboardProvider = Provider.of<DashboardProvider>(Get.context!, listen: false);

    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final customerBox = Hive.box('customerBox');
    final cacheKey = '${companyId}_customer_list_$page';
    
    bool isOnline = await ConnectivityService().isOnline();
    
    if (!isOnline) {
      final cachedData = customerBox.get(cacheKey);
      if (cachedData != null) {
        try {
          // Ensure all keys are strings before passing to fromJson
          final safeMap = ensureStringKeyedMap(cachedData);

          final response = CustomerResponseModelxx.fromJson(safeMap);
          setCustomers(response.data, response.pagination.totalPages);
          setOrderTotal(response.orderTotal);
          setYearList(response.yearsListOfAll);
          _isLoading = false;
          notifyListeners();
          return;
        } catch (e) {
          _filteredCustomers = [];
          _errorMessage = 'Corrupted offline data for this page.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      } else {
        _filteredCustomers = [];
        _errorMessage = 'No offline data for this page.';
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    if (_selectedFilter == FilterDateEnum.thisMonth ||
        _selectedFilter == FilterDateEnum.today ||
        _selectedFilter == FilterDateEnum.thisWeek ||
        _selectedFilter == FilterDateEnum.thisYear ||
        _selectedFilter == FilterDateEnum.range) {
      try {
        _isLoading = true;
        notifyListeners(); // Tell the UI loading has started

        String apiValueFromDw = "";
        List<String> apiSelectedRange = [];
        String apiStartDate = "";
        String apiEndDate = "";

        // Logic to determine payload based on Filter Enum
        switch (_selectedFilter) {
          case FilterDateEnum.thisMonth:
            apiValueFromDw = "Month";
            apiSelectedRange = dashboardProvider.selectedFilterMonths;
            if (apiSelectedRange.isEmpty) {
              final List<String> monthNames = [
                "January", "February", "March", "April", "May", "June",
                "July", "August", "September", "October", "November", "December"
              ];
              apiSelectedRange = [monthNames[DateTime.now().month - 1]];
            }
            break;

          case FilterDateEnum.thisWeek:
            apiValueFromDw = "Week";
            apiSelectedRange = dashboardProvider.selectedFilterWeeks;
            break;

          case FilterDateEnum.thisYear:
            apiValueFromDw = "Year";
            apiSelectedRange = [dashboardProvider.selectedYear.toString()];
            break;

          case FilterDateEnum.range:
            apiValueFromDw = "Range";
            apiSelectedRange = [_selectedStartDate, _selectedEndDate];
            apiStartDate = _selectedStartDate;
            apiEndDate = _selectedEndDate;
            break;

          case FilterDateEnum.today:
            apiValueFromDw = "Day";
            apiSelectedRange = [dashboardProvider.selectedDate];
            break;

          default:
            apiValueFromDw = "All";
        }

        // 1. AWAIT THE API CALL: This pauses the function until data is received
        _customersFuture = _apiService.fetchCustomer(
          salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
          customerName: _searchCustomerName,
          limit: 10,
          page: page,
          valueFromDw: apiValueFromDw,
          selectedRange: apiSelectedRange,
          startDate: apiStartDate,
          endDate: apiEndDate,
        );

        final value = await _customersFuture!;

        // 2. ONLY RUNS AFTER DATA IS RECEIVED
        setCustomers(value.data, value.pagination.totalPages);
        setOrderTotal(value.orderTotal);
        setYearList(value.yearsListOfAll);

        notificationController.loadNotificationData();
        _isLoading = false;
        notifyListeners();

      } catch (e, stackTrace) {
        _isLoading = false;
        _errorMessage = 'Failed to fetch customer data: $e';
        notifyListeners();
        _logger.e('Error fetching customers', error: e, stackTrace: stackTrace);
        
        // Rethrow the error so your UI "Go" button catches it and closes the dialog!
        rethrow; 
      }
    } else {
      await fetchCustomerData();
    }
  }

  // Future<void> fetchCustomerData({int page = 1}) async {
  //   _errorMessage = '';
  //   NotificationController notificationController =
  //       Get.find<NotificationController>();
  //       final dashboardProvider = Provider.of<DashboardProvider>(Get.context!, listen: false);

  //   final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  //   final customerBox = Hive.box('customerBox');
  //   final cacheKey = '${companyId}_customer_list_$page';
  //   bool isOnline = await ConnectivityService().isOnline();
  //   if (!isOnline) {
  //     final cachedData = customerBox.get(cacheKey);
  //     if (cachedData != null) {
  //       try {
  //         // Ensure all keys are strings before passing to fromJson
  //         final safeMap = ensureStringKeyedMap(cachedData);

  //         final response = CustomerResponseModelxx.fromJson(safeMap);
  //         setCustomers(response.data, response.pagination.totalPages);
  //         setOrderTotal(response.orderTotal);
  //         setYearList(response.yearsListOfAll);
  //         _isLoading = false;
  //         notifyListeners();
  //         return;
  //       } catch (e) {
  //         _filteredCustomers = [];
  //         _errorMessage = 'Corrupted offline data for this page.';
  //         _isLoading = false;
  //         notifyListeners();
  //         return;
  //       }
  //     } else {
  //       _filteredCustomers = [];
  //       _errorMessage = 'No offline data for this page.';
  //       _isLoading = false;
  //       notifyListeners();
  //       return;
  //     }
  //   }

  //   if (_selectedFilter == FilterDateEnum.thisMonth ||
  //       _selectedFilter == FilterDateEnum.today ||
  //       _selectedFilter == FilterDateEnum.thisWeek ||
  //       _selectedFilter == FilterDateEnum.thisYear ||
  //       _selectedFilter == FilterDateEnum.range) {

  //         try {
  //     _isLoading = true;
      
  //     String apiValueFromDw = "";
  //     List<String> apiSelectedRange = [];
  //     String apiStartDate = "";
  //     String apiEndDate = "";

  //     // Logic to determine payload based on Filter Enum
  //     switch (_selectedFilter) {
  //       case FilterDateEnum.thisMonth:
  //         apiValueFromDw = "Month";
  //         // TODO: Replace '_selectedMonthsList' with the variable connected to your MonthDropdown()
  //         // Example: apiSelectedRange = ["January", "March"]; 
  //         apiSelectedRange = dashboardProvider.selectedFilterMonths; 
  //         break;

  //       case FilterDateEnum.thisWeek:
  //         apiValueFromDw = "Week";
  //         // TODO: Replace '_selectedWeeksList' with the variable connected to your WeekDropdown()
  //         // Example: apiSelectedRange = ["week1", "week2"];
  //         apiSelectedRange = dashboardProvider.selectedFilterWeeks; 
  //         break;

  //       case FilterDateEnum.thisYear:
  //         apiValueFromDw = "Year";
  //         // TODO: Replace '_selectedYearsList' with the variable connected to your YearDropdown()
  //         // Example: apiSelectedRange = ["2025", "2026"];
  //         apiSelectedRange = [dashboardProvider.selectedYear.toString()]; 
  //         break;

  //       case FilterDateEnum.range:
  //         apiValueFromDw = "Range";
  //         // For Range, usually we send start/end date, but if backend wants it in selected_range:
  //         apiSelectedRange = [_selectedStartDate, _selectedEndDate];
  //         // Or if backend still wants specific start/end keys:
  //         apiStartDate = _selectedStartDate;
  //         apiEndDate = _selectedEndDate;
  //         break;

  //       case FilterDateEnum.today:
  //          apiValueFromDw = "Day"; // Or "Today" depending on backend expectation
  //          apiSelectedRange = [dashboardProvider.selectedDate]; // Assuming selectedStartDate holds today's date
  //          break;
           
  //       default:
  //         apiValueFromDw = "All"; // Default fallback
  //     }

  //     _customersFuture = _apiService.fetchCustomer(
  //       salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
  //       customerName: _searchCustomerName,
  //       limit: 10,
  //       page: page,
  //       valueFromDw: apiValueFromDw,
  //       selectedRange: apiSelectedRange,
  //       startDate: apiStartDate,
  //       endDate: apiEndDate,
  //     );

  //     _customersFuture!.then((value) {
  //       setCustomers(value.data, value.pagination.totalPages);
  //       setOrderTotal(value.orderTotal);
  //       setYearList(value.yearsListOfAll);
        
  //       // If the API returns the arrays for dropdowns (as seen in your json), 
  //       // you might want to update your dropdown lists here:
  //       // setMonthArray(value.monthArray); // if you add this to model
        
  //       notificationController.loadNotificationData();
  //       _isLoading = false;
  //       notifyListeners();
  //     }).catchError((error) {
  //       _isLoading = false;
  //       _errorMessage = 'Failed to fetch customer data: $error';
  //       notifyListeners();
  //     });

  //   }
   
  //      catch (e, stackTrace) {
  //       _isLoading = false;
  //       _logger.e('Error fetching customers', error: e, stackTrace: stackTrace);
  //       rethrow;
  //     }
  //   } else {
  //     await fetchCustomerData();
  //   }
  // }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_selectedStartDate.isNotEmpty
              ? DateTime.parse(_selectedStartDate)
              : DateTime.now())
          : (_selectedEndDate.isNotEmpty
              ? DateTime.parse(_selectedEndDate)
              : DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = pickedDate.toIso8601String().substring(0, 10);

      if (isStartDate) {
        _selectedStartDate = formattedDate;
      } else {
        _selectedEndDate = formattedDate;
      }
      if (_selectedFilter == FilterDateEnum.range &&
          _selectedStartDate.isNotEmpty &&
          _selectedEndDate.isNotEmpty) {}

      notifyListeners();
    }
  }


  void onFilterChanged(FilterDateEnum? selectedFilter) {
    if (selectedFilter != null) {
      _selectedFilter = selectedFilter;

      // Reset custom range dates if not selecting "Range"
      if (_selectedFilter != FilterDateEnum.range) {
        _selectedStartDate = '';
        _selectedEndDate = '';
      } else {
        // Optional: Set default range to today if empty
        final today = DateTime.now().toIso8601String().substring(0, 10);

        _selectedStartDate = today;
        _selectedEndDate = today;
        // if (_selectedStartDate.isEmpty) {
        //   _selectedStartDate = today;
        // }
        // if (_selectedEndDate.isEmpty) {
        //   _selectedEndDate = today;
        // }
      }

      final now = DateTime.now();

      // Automatically calculate start/end dates based on selected filter
      switch (_selectedFilter) {
        case FilterDateEnum.thisMonth:
          _selectedStartDate = DateTime(now.year, now.month, 1)
              .toIso8601String()
              .substring(0, 10);
          _selectedEndDate = DateTime(now.year, now.month + 1, 0)
              .toIso8601String()
              .substring(0, 10);
          break;

        case FilterDateEnum.today:
          final today = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          _selectedStartDate = today;
          _selectedEndDate = today;
          break;

        case FilterDateEnum.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          _selectedStartDate = startOfWeek.toIso8601String().substring(0, 10);
          _selectedEndDate = now.toIso8601String().substring(0, 10);
          break;

        case FilterDateEnum.thisYear:
          _selectedStartDate =
              DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
          _selectedEndDate =
              DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
          break;

        case FilterDateEnum.range:
          // Keep existing or default dates – user will pick via date picker
          break;
      }

      // Only update UI – do NOT fetch data here
      notifyListeners();
    }
  }

  // void onFilterChanged(FilterDateEnum? selectedFilter) {
  //   NotificationController notificationController =
  //       Get.find<NotificationController>();
  //   if (selectedFilter != null) {
  //     _selectedFilter = selectedFilter;
  //     _errorMessage = ''; // Clear previous error messages
  //     if (_selectedFilter != FilterDateEnum.range) {
  //       _selectedStartDate = '';
  //       _selectedEndDate = '';
  //     } else {
  //       if (_selectedStartDate.isEmpty) {
  //         _selectedStartDate =
  //             DateTime.now().toIso8601String().substring(0, 10);
  //       }
  //       if (_selectedEndDate.isEmpty) {
  //         _selectedEndDate = DateTime.now().toIso8601String().substring(0, 10);
  //       }
  //     }

  //     final now = DateTime.now();

  //     switch (_selectedFilter) {
  //       case FilterDateEnum.thisMonth:
  //         _selectedStartDate = DateTime(now.year, now.month, 1)
  //             .toIso8601String()
  //             .substring(0, 10);
  //         _selectedEndDate = DateTime(now.year, now.month + 1, 0)
  //             .toIso8601String()
  //             .substring(0, 10);
  //         break;
  //       case FilterDateEnum.today:
  //         _selectedStartDate = DateTime(now.year, now.month, now.day)
  //             .toIso8601String()
  //             .substring(0, 10);
  //         _selectedEndDate = _selectedStartDate;
  //         break;
  //       case FilterDateEnum.thisWeek:
  //         final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  //         _selectedStartDate = startOfWeek.toIso8601String().substring(0, 10);
  //         _selectedEndDate = now.toIso8601String().substring(0, 10);
  //         break;
  //       case FilterDateEnum.thisYear:
  //         _selectedStartDate =
  //             DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
  //         _selectedEndDate =
  //             DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
  //         break;
  //       case FilterDateEnum.range:
  //         break;
  //     }

  //     if (selectedFilter != FilterDateEnum.range) {
  //       fetchCustomerData();
  //       notificationController.loadNotificationData();
  //     }
  //     notifyListeners();
  //   }
  // }

  void goToNextPage() async {
    if (_currentPage < _totalPages) {
      _currentPage++;

      // Check if we're offline and have an active search
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline && _searchCustomerName.isNotEmpty) {
        // For offline search, all results are already loaded, just update the UI
        notifyListeners();
      } else {
        fetchCustomerData(page: _currentPage);
      }
    }
  }

  void goToPreviousPage() async {
    if (_currentPage > 1) {
      _currentPage--;

      // Check if we're offline and have an active search
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline && _searchCustomerName.isNotEmpty) {
        // For offline search, all results are already loaded, just update the UI
        notifyListeners();
      } else {
        fetchCustomerData(page: _currentPage);
      }
    }
  }

  void refreshCurrentPage() async {
    _errorMessage = ''; // Clear error message on refresh

    // Check if we're offline and have an active search
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline && _searchCustomerName.isNotEmpty) {
      // For offline search, just update the UI since all results are already loaded
      notifyListeners();
    } else {
      fetchCustomerData(page: _currentPage);
    }
  }

  /// Handles pagination for offline search results
  void goToNextPageOffline() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      // For offline search, we don't need to fetch new data since all results are already loaded
      notifyListeners();
    }
  }

  void goToPreviousPageOffline() {
    if (_currentPage > 1) {
      _currentPage--;
      // For offline search, we don't need to fetch new data since all results are already loaded
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Clears the search query and resets to normal browsing mode
  void clearSearch() async {
    _searchCustomerName = '';
    _currentPage = 1;
    _errorMessage = '';

    // Clear search controller if it exists
    if (searchController.text.isNotEmpty) {
      searchController.clear();
    }

    // Reload data based on connectivity
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      await loadCachedDataForCurrentPage();
    } else {
      await fetchCustomerData();
    }
  }

  /// Handles pagination clicks for both online and offline modes


void handlePaginationClick(int page) async {
    if (page == _currentPage) return; // No change needed

    // 1. Instantly tell the UI to hide the table and show the spinner
    _isLoading = true; 
    notifyListeners();

    _currentPage = page;

    // 2. Now perform the async internet check
    bool isOnline = await ConnectivityService().isOnline();
    
    if (!isOnline && _searchCustomerName.isNotEmpty) {
      // 3. Add a tiny artificial delay so the user actually sees the transition
      // Otherwise, the local swap happens so fast the UI might just flash
      await Future.delayed(const Duration(milliseconds: 300));
      
      logCurrentState();
      
      // 4. Turn off loading to bring the table back
      _isLoading = false; 
      notifyListeners();
    } else {
      // For normal browsing or online search, fetch data for the new page
      // (Just double-check that your fetchCustomerData() method sets isLoading = false when it finishes!)
      fetchCustomerData(page: page);
    }
  }
  
  // void handlePaginationClick(int page) async {
  //   if (page == _currentPage) return; // No change needed

  //   _currentPage = page;

  //   // Check if we're offline and have an active search
  //   bool isOnline = await ConnectivityService().isOnline();
  //   if (!isOnline && _searchCustomerName.isNotEmpty) {
  //     // For offline search, just update the UI since all results are already loaded
  //     logCurrentState();
  //     notifyListeners();
  //   } else {
  //     // For normal browsing or online search, fetch data for the new page
  //     fetchCustomerData(page: page);
  //   }
  // }

  // Future<void> addEvent(
  //     String customerId, int eventStatus, List<String> daysList) async {
  //   final success =
  //       await _apiService.addEvent(customerId, eventStatus, daysList);
  //   if (success) {
  //   } else {}
  //   notifyListeners();
  // }

  Future<AddEvent> addEvent(
    String customerId,
    int eventStatus,
    List<String> daysList,
    String period,
    BuildContext context,
  ) async {
    final response = await _apiService.addEvent(
        customerId, eventStatus, daysList, period, context);
    // notifyListeners(); // Keep this if needed
    return response;
  }

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  /// Debug method to log current state
  void logCurrentState() {}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
