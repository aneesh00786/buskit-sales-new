// ignore_for_file: library_prefixes, empty_catches, non_constant_identifier_names
import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart'
    as orderResponseModel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'dash_models.dart';

class DashboardProvider with ChangeNotifier {
  Future<ResponseModell>? _futureResponseModel;
  Future<SalesmenResponse>? _salesmenResponse;
  Future<MessagesResponse>? _individualChatResponse;
  bool _isDraftFetched = false;
  List<String> _selectedFilterMonths = [];
  List<String> get selectedFilterMonths => _selectedFilterMonths;
  List<orderResponseModel.OrderData> _chartOrderData = [];
  List<orderResponseModel.OrderData> get chartOrderData => _chartOrderData;
  List<TargetDatum> _salesmanTargetByCategory = [];
  List<TargetDatum> get salesmanTargetByCategory => _salesmanTargetByCategory;
  void updateSelectedMonths(List<String> months) {
    _selectedFilterMonths = months;
    notifyListeners();
  }

  List<String> _selectedFilterWeeks = [];
  List<String> get selectedFilterWeeks => _selectedFilterWeeks;
  void updateSelectedWeeks(List<String> Weeks) {
    _selectedFilterWeeks = Weeks;
    notifyListeners();
  }

  int _selectedYear = DateTime.now().year;
  int get selectedYear => _selectedYear;
  void updateSelectedYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  String _selectedDate = '';
  String get selectedDate => _selectedDate;
  void updateSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  FilterDateEnum _selectedFilter = FilterDateEnum.thisMonth;
  FilterDateEnum _selectedFilterTemp = FilterDateEnum.thisMonth;
  String _selectedFilterName = "Month";
  String _selectedFilterNameTemp = "Month";
  String _selectedStartDate = '';
  String _selectedEndDate = '';

  final ApiService _apiService;
  final Logger _logger;
  final bool _dataFetched = false;
  bool get dataFetched => _dataFetched;

  DashboardProvider({required ApiService apiService, required Logger logger})
      : _apiService = apiService,
        _logger = logger {
    fetchData();
    fetchChatData(SessionHelper.loginSavedData?.salesmanId ?? '');
    fetchSalesmanData();
  }

  OrderStatus selectedOrderStatus = OrderStatus.preOrder;

  void selectedOrderStatusd(OrderStatus status) {
    selectedOrderStatus = status;
    notifyListeners(); // Notify listeners when the state changes
  }

  List<String> allCategories = []; // Master list of all categories

  Future<OrderResponse>? _orderResponse;

  Future<OrderResponse>? get orderResponse => _orderResponse;

  Future<SalesmanResponse>? _adminResponsee;

  Future<SalesmanResponse>? get adminResponse => _adminResponsee;

  Future<ResponseModelCp>? _responseModelCp;

  Future<ResponseModelCp>? get responseModelCp => _responseModelCp;

  Future<ResponseModelCp>? _responseModelNewCp;
  Future<ResponseModelCp>? get responseModelNewCp => _responseModelNewCp;

  void resetProvider() {
    _futureResponseModel = null;
    _salesmenResponse = null;
    _individualChatResponse = null;
    _selectedFilter = FilterDateEnum.thisMonth;
    _selectedFilterTemp = FilterDateEnum.thisMonth;
    _selectedFilterName = "Month";
    _selectedFilterNameTemp = "Month";
    _selectedStartDate = '';
    _selectedEndDate = '';
  }

  void resetFilter() {
    _selectedFilter = FilterDateEnum.thisMonth;
    _selectedFilterTemp = FilterDateEnum.thisMonth;
    _selectedFilterName = "Month";
    _selectedFilterNameTemp = "Month";
    _selectedStartDate = '';
    _selectedEndDate = '';
  }

  Future<void> fetchchartCategoryPerformmenc(dynamic catId) async {
    try {
      _responseModelCp = Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchDashboardCategoruPerformenceData(
          catId: catId,
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
        );
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchchartValuePerformance(
      String month, String timeRange) async {
    try {
      _responseModelNewCp =
          Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchDashboardValuePerformanceData(
          catId: month,
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
        );
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchChartOrderData(
      String salesmanId, dynamic categoryId) async {
    try {
      _chartOrderData =
          await Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchChartSalesmanOrderData(
          catId: categoryId,
          salesmanId: salesmanId,
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
        );
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> loadSalesmanTargetByCategory(
      String salesmanId, int categoryId) async {
    try {
      _salesmanTargetByCategory =
          await Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchSalesmanTargetByCategory(
          catId: categoryId,
          salesmanId: salesmanId,
          startDate: _selectedFilter == FilterDateEnum.range
              ? _selectedStartDate
              : null,
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : null,
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : null,
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : null,
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : null,
          year:
              _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : null,
        );
      });

      log("Response: $_salesmanTargetByCategory");
    } catch (e, stackTrace) {
      _logger.e('Error fetching salesman targets',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<SalesmenResponse>? get salesmenResponse => _salesmenResponse;
  Future<ResponseModell>? get futureResponseModel => _futureResponseModel;
  Future<MessagesResponse>? get individualChatResponse =>
      _individualChatResponse;
  FilterDateEnum get selectedFilter => _selectedFilter;
  FilterDateEnum get selectedFilterTemp => _selectedFilterTemp;
  String get selectedStartDate => _selectedStartDate;
  String get selectedEndDate => _selectedEndDate;
  SalesmanChat? selectedChat;
  final salesmanId = SessionHelper.loginSavedData!.salesmanId!;

  Future<void> fetchOrdersData(OrderStatus s,
      {bool isLogin = false, bool checkDate = false}) async {
    try {
      Object orderType;

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
        return _apiService.fetchAllOrders(
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          orderStatus: s,
          orderType: orderType,
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
          isLogin: isLogin,
          checkDate: checkDate,
        );
      });

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  void onFilterChanged(FilterDateEnum? selectedFilterTemp) async {
    switch (selectedFilterTemp) {
      case FilterDateEnum.today:
        _selectedFilterNameTemp = "Day";
        break;
      case FilterDateEnum.thisWeek:
        _selectedFilterNameTemp = "Week";
        break;
      case FilterDateEnum.thisYear:
        _selectedFilterNameTemp = "Year";
        break;
      case FilterDateEnum.thisMonth:
        _selectedFilterNameTemp = "Month";
        break;
      case FilterDateEnum.range:
        _selectedFilterNameTemp = "Range";
        break;
      default:
        _selectedFilterNameTemp = "Month";
        break;
    }

    log('on filter changed');
    if (selectedFilterTemp != null) {
      _selectedFilterTemp = selectedFilterTemp;
      notifyListeners();
    }
  }

  Future<void> setTempToFilter() async {
    _selectedFilter = _selectedFilterTemp;
    _selectedFilterName = _selectedFilterNameTemp;
  }

  void selectAllChats(List<SalesmanChat> chatData) {
    selectedChats = List.from(chatData);
    notifyListeners();
  }

  void clearAllSelections() {
    selectedChats.clear();
    notifyListeners();
  }

  Future<void> refreshChatData(String salesmanId) async {
    await fetchChatData(salesmanId);
    notifyListeners();
  }

  Future<void> fetchAllOrdersAtOnce() async {
    log("fetchAllOrdersAtOnce");
    await fetchOrdersData(OrderStatus.delivered, checkDate: true);
    await fetchOrdersData(OrderStatus.estimates, checkDate: true);
    await fetchOrdersData(OrderStatus.estimates, checkDate: false);
    await fetchOrdersData(OrderStatus.preOrder, checkDate: true);
    await fetchOrdersData(OrderStatus.preOrder, checkDate: false);
    await fetchOrdersData(OrderStatus.draft);
    await fetchOrdersData(OrderStatus.cancelled, checkDate: true);
  }

  Future<void> fetchData() async {
    NotificationController notificationController =
        Get.find<NotificationController>();
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;

    try {
      final now = DateTime.now();
      String startDate =
          DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
      String endDate = DateTime(now.year, now.month + 1, 0)
          .toIso8601String()
          .substring(0, 10);
      _futureResponseModel = Future.delayed(const Duration(seconds: 2), () {
        return _apiService.fetchDashboardData(
          fetchType: _selectedFilterName,
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
          salesmanId: salesmanId,
        );
      });

      notificationController.loadNotificationData(startDate, endDate);
      if (!_isDraftFetched) {
        await CartDatabaseManager().getDraftItems();
        _isDraftFetched = true;
      }
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching data', error: e, stackTrace: stackTrace);
      rethrow;
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
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
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

  Future<SalesmenResponse> fetchChatData(String salesmanId) async {
    try {
      Future<SalesmenResponse> chatData = _apiService.fetchChatData(salesmanId);
      _salesmenResponse = chatData as Future<SalesmenResponse>?;
      return chatData;
    } catch (e, stackTrace) {
      _logger.e('Error fetching chat data', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch chat data: $e');
    }
  }

  List<Messages>? _individualChatMessages = [];
  List<Messages>? get individualChatMessages => _individualChatMessages;
  bool _noMoreData = false;
  bool get noMoreData => _noMoreData;
  List<SalesmanChat> selectedChats = [];

  void resetNoMoreData() {
    _noMoreData = false;
    notifyListeners();
  }

  Future<MessagesResponse> fetch_individual_chat(
      String chatId, int page) async {
    try {
      if (_noMoreData && page > 1) return MessagesResponse(data: []);
      final chatData = await _apiService.fetchIndividualChatApi(chatId, page);

      if (chatData.data.isEmpty && page > 1) {
        _noMoreData = true;
      } else {
        _individualChatMessages ??= [];
        if (page == 1) {
          // ignore: prefer_collection_literals
          _individualChatMessages = [
            ...chatData.data,
            ..._individualChatMessages!,
          ].toSet().toList();
        } else {
          _individualChatMessages!.addAll(chatData.data);
          _individualChatMessages = _individualChatMessages!.toSet().toList();
        }
      }
      notifyListeners();
      return chatData;
    } catch (e, stackTrace) {
      _logger.e('Error fetching individual chat data',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch individual chat data: $e');
    }
  }

  void addMessages(List<Messages> newMessages) {
    _individualChatMessages ??= [];
    // ignore: prefer_collection_literals
    _individualChatMessages = [
      ...newMessages,
      ..._individualChatMessages!,
    ].toSet().toList();
    notifyListeners();
  }

  void clearSelectedChat() {
    selectedChat = null;
    notifyListeners();
  }

  void toggleChatSelection(SalesmanChat chat) {
    if (selectedChats.contains(chat)) {
      selectedChats.remove(chat);
    } else {
      selectedChats.add(chat);
    }
    notifyListeners();
  }

  Future<SalesmanResponse> fetchSalesmanData() async {
    try {
      final chatData = await _apiService.fetchSalesmanDetails(
          token: SessionHelper.loginSavedData?.createdToken ?? '');
      _adminResponsee = Future.value(chatData);
      notifyListeners();
      return chatData;
    } catch (e, stackTrace) {
      _logger.e('Error fetching individual chat data',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch individual chat data: $e');
    }
  }

  OrderStatus _selectedOrderStatuss = OrderStatus.pending;
  OrderStatus get selectedOrderStatuss => _selectedOrderStatuss;
  void setSelectedOrderStatus(OrderStatus status) {
    if (status != _selectedOrderStatuss) {
      _selectedOrderStatuss = status;
      notifyListeners();
    }
  }

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

  final ImagePicker _pickerC = ImagePicker();

  File? get imageFileC => _imageFile;

  Future<void> pickImageCommuni() async {
    final pickedFile = await _pickerC.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      notifyListeners();
    }
  }

  void clearImage() {
    _imageFile = null;
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
