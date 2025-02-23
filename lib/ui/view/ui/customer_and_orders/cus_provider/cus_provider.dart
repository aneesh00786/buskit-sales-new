import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:win32/win32.dart';

import '../csord_model/customers_orders_model.dart';

class CustomersProvider with ChangeNotifier {
  final ApiService _apiService;
  final Logger _logger;

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
    fetchCustomerData();
    // fetchcustomersDash();
  }

  String _errorMessage = '';
  bool _isLoading = false;
  Future<CustomerResponseModelxx>? _customersFuture;

  FilterDateEnum _selectedFilter = FilterDateEnum.thisMonth;
  String _selectedStartDate = '';
  String _selectedEndDate = '';

  void setCurrentMonthDates() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateFormat = DateFormat('yyyy-MM-dd');
    _selectedStartDate = dateFormat.format(firstDayOfMonth);
    _selectedEndDate = dateFormat.format(lastDayOfMonth);
  }

  int _currentPage = 1;
  int _totalPages = 1;

  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Future<CustomerResponseModelxx>? get customersFuture => _customersFuture;
  FilterDateEnum get selectedFilter => _selectedFilter;

  String get selectedStartDate => _selectedStartDate;
  String get selectedEndDate => _selectedEndDate;
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

  List<CustomerModelxx> _customers = [];
  List<CustomerModelxx> _filteredCustomers = [];
  List<OrderTotalxx> _orderTotalList = [];
  List<YearsListOfAll> _yearsListOfAllList = [];

  List<OrderTotalxx> get orderTotalList => _orderTotalList;
  List<YearsListOfAll> get yearsListOfAllList => _yearsListOfAllList;

  List<CustomerModelxx> get filteredCustomers => _filteredCustomers;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  Future<ProductResponse>? _productResponse;
  Future<ProductResponse>? get productResponse => _productResponse;
  int cartItemCount = 0;
  List<BarChartGroupData> barGroups = [];
  void createBarGroups({
    required List<CategoryPerformance> categoryPerformance,
    required String targetType,
    required String staffProjection,
  }) {
    log('This function has called');
    barGroups = categoryPerformance.asMap().entries.map((entry) {
      int index = entry.key;
      CategoryPerformance perf = entry.value;
      num target = perf.actualTarget ?? 0.0;
      num projection = perf.actualProjection ?? 0.0;
      num actual = num.parse(perf.actualSales.toString());

      return BarChartGroupData(
        x: index,
        barRods: [
          if (targetType == "1")
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

    notifyListeners();
  }

  Future<int> getCartItemCounts(String customerId) async {
    try {
      final cartItems = await CartDatabaseManager().getCartItems(customerId);
      final count =  cartItems.length;
      cartItemCount = count;
      notifyListeners();
      log('Cart count calculated for customer $customerId: $cartItemCount');
      return cartItemCount;
    } catch (e) {
      log('Error calculating cart item counts for customer $customerId: $e');
      return 0;
    }
  }

Future<void> updateCartCount(String customerId) async {
  try {
    final cartItems = await CartDatabaseManager().getCartItems(customerId);
    cartItemCount = cartItems.length;
    log('The cart item Count $cartItemCount');
    notifyListeners();
    log('Cart count updated for customer $customerId: $cartItemCount');
  } catch (e) {
    log('Error updating cart count for customer $customerId: $e');
  }
}


  Future<void> fetchChartCategoryPerformance(
      dynamic customerId, dynamic catId, dynamic selectedYearCategory) async {
    try {
      _productResponse = _apiService.fetchCustomerDashboardCartData(
        customerId: customerId,
        catId: catId,
        selectedYearCategory: selectedYearCategory,
        startDate: selectedStartDate,
        endDate: selectedEndDate,
      );

      // notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  set currentPage(int newPage) {
    if (newPage != _currentPage) {
      _currentPage = newPage;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) async {
    log("updateSearchQuery query : $query");
    _searchCustomerName = query;

    try {
      if (query.isEmpty) {
        // _filteredCustomers = _customers;
        _filteredCustomers.clear();
        await fetchCustomerData();
      } else {
        _filteredCustomers.clear();
        notifyListeners();

        await fetchCustomerData(); // API call
      }
    } catch (e) {
      log("Error fetching customer data: $e");
    } finally {
      notifyListeners();
    }
  }

  // void setCustomers(List<CustomerModelxx> customers, int totalPages) {
  //   _customers = customers;
  //   _filteredCustomers = customers;
  //   _totalPages = totalPages;
  //   notifyListeners();
  // }
  void setCustomers(List<CustomerModelxx> customers, int totalPages) {
    _customers = customers;
    _filteredCustomers = customers;
    _totalPages = totalPages;
    notifyListeners();
  }

  void setOrderTotal(List<OrderTotalxx> orderTotals) {
    _orderTotalList = orderTotals;
    notifyListeners();
  }

  void setYearList(List<YearsListOfAll> yearsListOfAll) {
    _yearsListOfAllList = yearsListOfAll;
  }

  Future<void> fetchCustomerDashboardCountData(
    String customerId,
  ) async {
    try {
      _countFuture = _apiService.fetchOrderCount(
          customerId, _selectedStartDate, _selectedEndDate);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<OrderResponse>? _orderResponse;
  Future<OrderResponse>? get orderResponse => _orderResponse;
  Future<CustomerResponse>? _customerResponse;
  Future<CustomerResponse>? get customerResponse => _customerResponse;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  File? get imageFile => _imageFile;
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> updateCustomerDash({
    required CustomerDashMo admin,
    required String cusId,
  }) async {
    try {
      await _apiService
          .updateCustomerDashDetails(
              model: admin, adminProfilePicture: imageFile!, customerId: cusId)
          .then((value) => fetchCustomerDashboardCountData(cusId));

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update admin: $e');
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

  Future<void> addCustomer({
    required CustomerDashMo admin,
    required String salsmanId,
  }) async {
    try {
      await _apiService
          .addCustomer(
              model: admin,
              adminProfilePicture: imageFile!,
              salesmanId: salsmanId)
          .then((value) => fetchCustomerData());

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    }
  }

  Future<void> fetchCustomersDataDash(String customerId) async {
    try {
      _customerResponse = _apiService.fetchOneCustomer(customerId);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchOrdersForCustomDash(OrderStatus s, String custId) async {
    try {
      final now = DateTime.now();
      String startDate;
      String endDate;
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
      switch (_selectedFilter) {
        case FilterDateEnum.thisMonth:
          startDate = DateTime(now.year, now.month, 1)
              .toIso8601String()
              .substring(0, 10);
          endDate = DateTime(now.year, now.month + 1, 0)
              .toIso8601String()
              .substring(0, 10);
          break;
        case FilterDateEnum.today:
          startDate = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          endDate = startDate;
          break;
        case FilterDateEnum.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          startDate = startOfWeek.toIso8601String().substring(0, 10);
          endDate = now.toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.thisYear:
          startDate =
              DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
          endDate =
              DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.range:
          startDate = _selectedStartDate;
          endDate = _selectedEndDate;
          break;
      }
      if (_selectedFilter == FilterDateEnum.range &&
          (startDate.isEmpty || endDate.isEmpty)) {
        throw Exception('Select both start and end dates');
      }
      _orderResponse = Future.delayed(const Duration(milliseconds: 300), () {
        final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
        return _apiService.fetchCustomerDashOrders(
            cusId: custId,
            salesmanId: salesmanId,
            orderType: orderType,
            startDate: startDate,
            endDate: endDate,
            orderStatus: s);
      });
      print("sadfdfoijgdiof sabik kavungal ponmala pllippadi k ${s.type}");

      notifyListeners();

      print(
          "sabik kkavungal ponmala pllippadi kkdc.fc.v.v.v.v.v.v.v.v.v.v.v.v. .. .  . . . .${_orderResponse}");

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  List<YearList> _yearList = [];
  int? _selectedYear;
  Future<void> fetchCustomerDashboardDataSalseData(
      String customerId, int specifiedYear) async {
    try {
      _customerTotalSaleResponseFuture =
          _apiService.fetchCustomerTotalSale(customerId, specifiedYear);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchCustomerDashboardRevenueData(String customerId,
      int specifiedYear, String startDate, String endDate) async {
    try {
      _customerRevenueResponseFuture = _apiService.fetchCustomerRevenueData(
          customerId, specifiedYear, startDate, endDate);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchCustomerDashboardData(String customerId, int specifiedYear,
      String? startDate, String? endDate) async {
    log('Start Date End Date ${startDate}, ${endDate}');
    try {
      _customersDashFuture = _apiService
          .fetchCustomerDashboardDataa(
              customerId, specifiedYear, startDate ?? '', endDate ?? '')
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

  List<YearList> get yearList => _yearList;

  int? get selectedYear => _selectedYear;
  void setSelectedYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  List<RecentOrder> _selectedOrders = [];

  List<RecentOrder> get selectedOrders => _selectedOrders;

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
    if (page <= 0) {
      throw ArgumentError('Page must be greater than 0');
    }

    _errorMessage = '';
    NotificationController notificationController =
        Get.find<NotificationController>();

    if (_selectedFilter == FilterDateEnum.thisMonth ||
        _selectedFilter == FilterDateEnum.today ||
        _selectedFilter == FilterDateEnum.thisWeek ||
        _selectedFilter == FilterDateEnum.thisYear ||
        _selectedFilter == FilterDateEnum.range) {
      try {
        final now = DateTime.now();
        String startDate = '';
        String endDate = '';

        switch (_selectedFilter) {
          case FilterDateEnum.thisMonth:
            startDate = DateTime(now.year, now.month, 1)
                .toIso8601String()
                .substring(0, 10);
            endDate = DateTime(now.year, now.month + 1, 0)
                .toIso8601String()
                .substring(0, 10);
            break;
          case FilterDateEnum.today:
            startDate = DateTime(now.year, now.month, now.day)
                .toIso8601String()
                .substring(0, 10);
            endDate = startDate;
            break;
          case FilterDateEnum.thisWeek:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            startDate = startOfWeek.toIso8601String().substring(0, 10);
            endDate = now.toIso8601String().substring(0, 10);
            break;
          case FilterDateEnum.thisYear:
            startDate =
                DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
            endDate =
                DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
            break;
          case FilterDateEnum.range:
            startDate = _selectedStartDate;
            endDate = _selectedEndDate;
            if (startDate.isEmpty || endDate.isEmpty) {
              throw ArgumentError(
                  'Invalid date range: startDate or endDate is empty.');
            }
            break;
        }

        _isLoading = true;
        log('fetchCustomer query: $_searchCustomerName');
        log('Parameters: startDate=$startDate, endDate=$endDate, page=$page');
        _customersFuture = _apiService.fetchCustomer(
          salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
          // salesmanId: '',
         // SessionHelper.loginSavedData?.salesmanId??'',
          customerName: _searchCustomerName,
          startDate: '',
          endDate: '',
          limit: 10,
          page: page,
          valueFromDw: _selectedFilter.name == 'Range'
              ? [_selectedFilter.name, _selectedStartDate, _selectedEndDate]
              : _selectedFilter.name,
        );
        _customersFuture!.then((value) {
          setCustomers(value.data, value.pagination.totalPages);
          setOrderTotal(value.orderTotal);
          setYearList(value.yearsListOfAll);
          notificationController.loadNotificationData(startDate, endDate);
          _isLoading = false;
          notifyListeners();
        }).catchError((error) {
          _isLoading = false;
          _errorMessage = 'Failed to fetch customer data: $error';
          notifyListeners();
        });
      } catch (e, stackTrace) {
        _isLoading = false;
        log('Error fetching customers: $e', error: e, stackTrace: stackTrace);
        rethrow;
      }
    } else {
      await fetchCustomerData(page: page);
    }
  }

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
    NotificationController notificationController =
        Get.find<NotificationController>();
    print('dropdown changed $selectedFilter');
    if (selectedFilter != null) {
      _selectedFilter = selectedFilter;
      if (_selectedFilter != FilterDateEnum.range) {
        _selectedStartDate = '';
        _selectedEndDate = '';
      } else {
        if (_selectedStartDate.isEmpty) {
          _selectedStartDate =
              DateTime.now().toIso8601String().substring(0, 10);
        }
        if (_selectedEndDate.isEmpty) {
          _selectedEndDate = DateTime.now().toIso8601String().substring(0, 10);
        }
      }

      final now = DateTime.now();

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
          _selectedStartDate = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          _selectedEndDate = _selectedStartDate;
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
          break;
      }

      if (selectedFilter != FilterDateEnum.range) {
        fetchCustomerData();
        notificationController.loadNotificationData(
            _selectedStartDate, _selectedEndDate);
      }
      notifyListeners();
    }
  }

  void goToNextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      fetchCustomerData(page: _currentPage);
    }
  }

  void goToPreviousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      fetchCustomerData(page: _currentPage);
    }
  }

  void refreshCurrentPage() {
    fetchCustomerData(page: _currentPage);
  }

  Future<void> addEvent(
      String customerId, int eventStatus, List<String> daysList) async {
    final success =
        await _apiService.addEvent(customerId, eventStatus, daysList);
    if (success) {
      print(success);
      print(daysList);
      print('Event added successfully');
    } else {
      print('Failed to add event');
    }
    notifyListeners();
  }

  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  void scrollLeft() {
    if (_scrollController.position.pixels > 0) {
      _scrollController.jumpTo((_scrollController.position.pixels - 100)
          .clamp(0.0, _scrollController.position.maxScrollExtent));
      notifyListeners();
    }
  }

  void scrollRight() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent) {
      _scrollController.jumpTo((_scrollController.position.pixels + 100)
          .clamp(0.0, _scrollController.position.maxScrollExtent));
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
