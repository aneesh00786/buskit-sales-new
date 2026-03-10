import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/sibscription_model.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();

  RxBool isSubscriptionLoading = false.obs;
  RxBool isSubscriptionPlanDetailsLoading = false.obs;

  List<SubscribtionPlanDetailsData> plansData = [];

  RxString communication = 'false'.obs;
  RxString collectionGraph = 'false'.obs;
  RxString orderStatusGraph = 'false'.obs;
  RxString frequentlyBroughtProduct1 = 'false'.obs;
  RxString bookingView = 'false'.obs;
  RxString customerAllocation = 'false'.obs;
  RxString visitSetting = 'false'.obs;
  RxString customerDashboardView = 'false'.obs;
  RxString creditPeriodSetting = 'false'.obs;
  RxString customerDiscountSettings = 'false'.obs;
  RxString productAvailabilityStatus = 'false'.obs;
  RxString productBuyingPatternIndicator = 'false'.obs;
  RxString quickSale = 'false'.obs;
  RxString advanceBooking = 'false'.obs;
  RxString listPendingPayments = 'false'.obs;
  RxString paymentCollection = 'false'.obs;
  RxString leadAcceptanceRejection = 'false'.obs;
  RxString assignLeadsToStaff = 'false'.obs;
  RxString leadConversion = 'false'.obs;
  RxString visitList = 'false'.obs;
  RxString visitNavigation = 'false'.obs;
  RxString showRoute = 'false'.obs;
  RxString timesheet = 'false'.obs;
  RxString customerCheckInOut = 'false'.obs;
  RxString routes = 'false'.obs;
  RxString categoryTargetSetting = 'false'.obs;
  RxString staffProjection = 'false'.obs;
  RxString visitReport = 'false'.obs;
  RxString receivedOrder = 'false'.obs;
  RxString receivedOrderEditing = 'false'.obs;
  RxString customerApprovalOption = 'false'.obs;
  RxString processing = 'false'.obs;
  RxString packedReady = 'false'.obs;
  RxString delivered = 'false'.obs;
  RxString orderQuickSale = 'false'.obs;
  RxString rejected = 'false'.obs;
  RxString workingDaysSettings = 'false'.obs;
  RxString countersWithMMYY = 'false'.obs;
  RxString workingHours = 'false'.obs;
  RxString customerPaymentCollection = 'false'.obs;
  RxString customerFrequentlyBoughtProducts = 'false'.obs;
  RxString staffCheckInOut = 'false'.obs;
  RxString reports = 'false'.obs;
  RxString adminApp = 'false'.obs;
  RxString viewCustomerDashboard = 'false'.obs;
  RxString orderTakingFromDashboard = 'false'.obs;
  RxString salesPaymentCollection = 'false'.obs;
  RxString appQuickSale = 'false'.obs;
  RxString appAdvanceBooking = 'false'.obs;
  RxString appPendingPaymentList = 'false'.obs;
  RxString appPaymentCollection = 'false'.obs;
  RxString appViewDaySchedulesVisits = 'false'.obs;
  RxString appShowRoute = 'false'.obs;
    RxString customerYearComparison = 'false'.obs;


  Future<void> loadSubscriptionFeatures(int companyId) async {
    isSubscriptionLoading(true);

    try {
      var subscriptionResponse =
          await _apiWorker.fetchSubscribtionPlan(companyId);
      if (subscriptionResponse != null) {
        final features = subscriptionResponse.data.first.planFeatures.features;

        features.forEach((key, value) {
          final status = value.status.toString();
          switch (key) {
            case 'communication':
              communication.value = status;
              break;
            case 'collection_graph':
              collectionGraph.value = status;
              break;
            case 'order_status_graph':
              orderStatusGraph.value = status;
              break;
            case 'frequently_brought_product1':
              frequentlyBroughtProduct1.value = status;
              break;
            case 'booking_view':
              bookingView.value = status;
              break;
            case 'customer_allocation':
              customerAllocation.value = status;
              break;
            case 'visit_setting':
              visitSetting.value = status;
              break;
            case 'customer_dashboard_view':
              customerDashboardView.value = status;
              break;
            case 'credit_period_setting':
              creditPeriodSetting.value = status;
              break;
            case 'customer_discount_settings':
              customerDiscountSettings.value = status;
              break;
            case 'product_availability_status':
              productAvailabilityStatus.value = status;
              break;
            case 'product_buying_pattern_indicator':
              productBuyingPatternIndicator.value = status;
              break;
            case 'quick_sale':
              quickSale.value = status;
              break;
            case 'advance_booking':
              advanceBooking.value = status;
              break;
            case 'list_pending_payments':
              listPendingPayments.value = status;
              break;
            case 'payment_collection':
              paymentCollection.value = status;
              break;
            case 'lead_acceptance_rejection':
              leadAcceptanceRejection.value = status;
              break;
            case 'assign_leads_to_staff':
              assignLeadsToStaff.value = status;
              break;
            case 'lead_conversion':
              leadConversion.value = status;
              break;
            case 'visit_list':
              visitList.value = status;
              break;
            case 'visit_navigation':
              visitNavigation.value = status;
              break;
            case 'show_route':
              showRoute.value = status;
              break;
            case 'timesheet':
              timesheet.value = status;
              break;
            case 'customer_check_in_out':
              customerCheckInOut.value = status;
              break;
            case 'routes':
              routes.value = status;
              break;
            case 'category_target_setting':
              categoryTargetSetting.value = status;
              break;
            case 'staff_projection':
              staffProjection.value = status;
              break;
            case 'visit_report':
              visitReport.value = status;
              break;
            case 'received_order':
              receivedOrder.value = status;
              break;
            case 'received_order_editing':
              receivedOrderEditing.value = status;
              break;
            case 'customer_approval_option':
              customerApprovalOption.value = status;
              break;
            case 'processing':
              processing.value = status;
              break;
            case 'packed_ready':
              packedReady.value = status;
              break;
            case 'delivered':
              delivered.value = status;
              break;
            case 'order_quick_sale':
              orderQuickSale.value = status;
              break;
            case 'rejected':
              rejected.value = status;
              break;
            case 'working_days_settings':
              workingDaysSettings.value = status;
              break;
            case 'counters_with_MM_YY':
              countersWithMMYY.value = status;
              break;
            case 'working_hours':
              workingHours.value = status;
              break;
            case 'customer_payment_collection':
              customerPaymentCollection.value = status;
              break;
            case 'customer_frequently_bought_products':
              customerFrequentlyBoughtProducts.value = status;
              break;
            case 'staff_check_in_out':
              staffCheckInOut.value = status;
              break;
            case 'reports':
              reports.value = status;
              break;
            case 'admin_app':
              adminApp.value = status;
              break;
            case 'view_customer_dashboard':
              viewCustomerDashboard.value = status;
              break;
            case 'order_taking_from_dashboard':
              orderTakingFromDashboard.value = status;
              break;
            case 'sales_payment_collection':
              salesPaymentCollection.value = status;
              break;
            case 'app_quick_sale':
              appQuickSale.value = status;
              break;
            case 'app_advance_booking':
              appAdvanceBooking.value = status;
              break;
            case 'app_pending_payment_list':
              appPendingPaymentList.value = status;
              break;
            case 'app_payment_collection':
              appPaymentCollection.value = status;
              break;
            case 'app_view_day_schedules_visits':
              appViewDaySchedulesVisits.value = status;
              break;
            case 'app_show_route':
              appShowRoute.value = status;
              break;
            case 'customer_year_comparison':
              customerYearComparison.value = status;
              break;
          }
        });
      }
      await Future.delayed(const Duration(seconds: 1));
      isSubscriptionLoading(false);
      update();
    } catch (e) {
      isSubscriptionLoading(false);
      rethrow;
    }
  }

  Future<void> loadSubscriptionPlanDetails() async {
    isSubscriptionPlanDetailsLoading(true);

    try {
      final subscriptionPlanDetailsResponse =
          await _apiWorker.fetchPlanDetails();

      plansData.assignAll(subscriptionPlanDetailsResponse?.data ?? []);

      await Future.delayed(const Duration(seconds: 1));
      isSubscriptionPlanDetailsLoading(false);


      update();
    } catch (e) {
      isSubscriptionPlanDetailsLoading(false);
      rethrow;
    }
  }
}
