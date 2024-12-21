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
  static const String dashboard_list = "dashboard_list";
  static const String search_customer = "search_customer";
  static const String delete_customer = "delete_customer";
  static const String fetch_on_salesman = "fetch_on_salesman";
  static const String fetchcustomer = "fetchAllCustomer";
  static const String customer_dashboard_list = "customer_dashboard_list";
  static const String customer_total_sale = "customer_total_sale";
  static const String place_order = "place_order";
  static const String add_order_draft = "add_order_draft";
  static const String fetch_cart = "fetch_cart";
  static const String customer_order_history = "customer_order_history";
  static const String add_to_cart = "add_to_cart";
  static const String cart_delete = "cart_delete";
  static const String fetch_one_customer = "fetch_one_customer";
  static const String add_events = "add_events";
  static const String update_product_price = "update_product_price";
  static const String payment_add_detail = "payment_add_detail";
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
  static const String fetch_salesman_of_customer = "fetch_salesman_of_customer";
  static const String get_event = "get_event";
  static const String handle_lead = "handle_lead";
  static const String fetch_leads_reject = "fetch_leads_reject";
  static const String fetch_specific_order = "fetch_specific_order";
  static const String update_CategorytargetValue = "update_CategorytargetValue";
  static const String salesman_dashview = "salesman_dashview";
  static const String salesman_dash_navcontents = "salesman_dash_navcontents";
  static const String fetchAllSetting = "fetchAllSetting";
  

  /// Category Api END Point
  static const String fetchcategories = "fetch_categories";
  
  /// Product Api
  static const String fetchproduct = "fetch_product";
  static const String fetch_allproduct = "fetch_allproduct";

  /// Leads Api
  static const String add_customer = "add_customer";
  static const String fetch_leads = "fetch_leads";
  static const String update_customer = "update_customer";
  static const String fetch_salesmanTarget = "fetch_salesmanTarget";

  /// CALENDAR API
  static const String search_salesman = "search_salesman";
  static const String schedule_customer = "schedule_customer";
  static const String fetch_schedule_customer = "fetch_schedule_customer";
  static const String update_events = "update_events";

  /// ORDER API
  static const String fetch_order = "fetch_order";
  static const String fetch_all_order = "fetch_all_order";

  /// PENDING  PAYMENT API
  static const String fetch_pending_payments = "fetch_pending_payments";
  static const String get_all_pending_payment_individual = "get_all_pending_payment_individual";

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
  static const String recent_order_count = "recent_order_count";
  static const String orders_count_get = "orders_count_get";
  static const String get_recent_order = "get_recent_orders";
  static const String order_process_invoice = "order_process_invoice";
  static const String waiting_for_approval = "waiting_for_approvel";
  static const String localHost = 'http://16.50.232.153:3000/';
  
}
