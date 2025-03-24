mixin class ApiConstants {

  static const String baseUrl = "http://16.50.232.153:3000/";
  static const String baseUrl1 = "http://16.50.232.153:3000";
  static const String imageBaseUrl = "${baseUrl}uploads/";
  static const String imageBaseUrlss = "${baseUrl}uploads";
  /// Login APi END Point
  static const String login = "salesman_login";
  /// Image API end
  static const String prooduct = "product";
  static const String customer = "customer";
  /// Dashboard API
  static const String dashboardList = "dashboard_list";
  static const String searchCustomer = "search_customer";
  static const String deletCustomer = "delete_customer";
  static const String fetchcustomer = "fetchAllCustomer";
  static const String customerDashbordList = "customer_dashboard_list";
  static const String customerTotalSale = "customer_total_sale";
  static const String placeOrder = "place_order";
  static const String addOrderDraft = "add_order_draft";
  static const String fetchCart = "fetch_cart";
  static const String customerOrderHistory = "customer_order_history";
  static const String addToCart = "add_to_cart";
  static const String addToDraft = "add_to_draft";
  static const String cartDelete = "cart_delete";
  static const String fetchOneCustomer = "fetch_one_customer";
  static const String addEvents = "add_events";
  static const String updateProductPrice = "update_product_price";
  static const String fetchCategoryPerformance = "fetchCategoryPerformance";
  static const String customerSaleByCategory = "CustomerSaleByCategory";
  static const String fetchChat = "fetch_chat";
  static const String fetchIndividualChat = "fetch_individual_chat";
  static const String postAdminMessage = "post_admin_message";
  static const String fetchAllOrders = "fetch_all_order";
  static const String changeOrderStatus = "change_order_status";
  static const String adminOnPopUp = "admin_on_popup";
  static const String fetchCustomer = "fetch_customer";
  static const String addEvent = "add_events";
  static const String customeTotalSale = "customer_total_sale";
  static const String fetchOrderCount = "fetch_order_count";
  static const String getEvent = "get_event";
  static const String handleLeads = "handle_lead";
  static const String fetchRejectedLeads = "fetch_leads_reject";
  static const String fetchSpecificOrder = "fetch_specific_order";
  static const String updateCategoryTargetValue = "Update_CategorytargetValue";
  static const String salesmanDashView = "salesman_dashview";
  static const String salesmanDashNavContent = "salesman_dash_navcontents";
  static const String fetchAllSetting = "fetchAllSetting";
  static const String fetchLeadsCount = "fetchLeadsCount";
  static const String updateCheckinOut = "UpdateCheckInOut";
  /// Category Api END Point
  static const String fetchcategories = "fetch_categories";
  
  /// Product Api
  static const String fetchproduct = "fetch_product";

  /// Leads Api
  static const String addCustomer = "add_customer";
  static const String fetchLeads = "fetch_leads";
  static const String updateCustomer = "update_customer";
  static const String fetchSalesmanTarget = "fetch_salesmanTarget";
  static const String fetchLeadsCustomer = "fetch_leads_customer";

  /// CALENDAR API
  static const String scheduleCustomer = "schedule_customer";
  static const String fetchScheduleCustomer = "fetch_schedule_customer";
  static const String updateEvenets = "update_events";

  /// ORDER API
  static const String fetchOrder = "fetch_order";
  static const String fetchAllOrder = "fetch_all_order";

  /// PENDING  PAYMENT API
  static const String fetchPendingPayments = "fetch_pending_payments";
  static const String getAllPendingPaymentIndividuals = "get_all_pending_payment_individual";

  // DUMMY IMAGE URL
  static const String dummyImageUrl = "https://img.freepik.com/premium-vector/people-profile-graphic_24911-21373.jpg";

  // GOOGLE MAP API KEY
  static const String kGoogleApiKey = "AIzaSyC8E9zV-5yGKWKqeBuIicx2Ma40cnXJsoc";
  static const String gGoogleApiKey = "AlzaSynLUFjx_AH5TJxhbt6SLjsak2qKBUTWqdl";
  
  // GOOGLE MAP API'S
  static const String mapBaseUrl = "https://maps.gomaps.pro/maps/api/";
  static const String gmapBaseUrl = "https://maps.googleapis.com/maps/api/";
  static const String navmapBaseUrl = "https://www.google.com/maps/";
  static const String mapSearchUrl = "place/queryautocomplete/json?input=";
  static const String mapPlaceDetailsUrl = "place/details/json?place_id=";
  static const String mapDestinationUrl = "directions/json?destination=";
  static const String distanceMatrix = "distancematrix/json";
  static const String recentOrderCount = "recent_order_count";
  static const String ordersCountGet = "orders_count_get";
  static const String getRecentOrder = "get_recent_orders";
  static const String orderProcessInvoice = "order_process_invoice";
  static const String waitingForApproval = "waiting_for_approvel";
  static const String localHost = 'http://16.50.232.153:3000/';
  
  //PERFORMANCE
  static const String fetchSchedule = "fetch_schedule";
  static const String getWeekelyType = "get_weekly_type";
  static const String fetchSalesmanValueTarget = "fetch_SalesmanValueTarget";
  static const String getStaffTimeSheet = "get_StaffTimesheet";
  static const String updateValueBasedTargetValue =
      "Update_ValueBasedtargetValue";
}
