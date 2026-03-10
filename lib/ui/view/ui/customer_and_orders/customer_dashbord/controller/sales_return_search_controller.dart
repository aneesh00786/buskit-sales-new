
import 'dart:async';
import 'dart:developer' as dev;


import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/sales_return_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/sales_return_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


class SearchResponse {
  final bool status;
  final List<SearchItem> data;

  SearchResponse({required this.status, required this.data});

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
        status: json['status'] ?? false,
        data: (json['data'] as List<dynamic>?)
                ?.map((e) => SearchItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class OrderIdSnackBar {
  
  
  static void show(BuildContext context, String customerId,String salesmanId ) {
    final controller = TextEditingController();
    final searchCtrl = SalesReturnSearchController(customeId: customerId,salesmanId: salesmanId);
    
    showGeneralDialog(
      context: context,
      barrierLabel: "Order ID",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => DialogContent(
        outerContext: context,
        controller: controller,
        searchCtrl: searchCtrl,
        customerId: customerId,
        //  salesmanId: salesmanId,
        
      ),
      transitionBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }
}


class SalesReturnSearchController extends GetxController {
  // final TextEditingController textCtrl;
  final _debounce = const Duration(milliseconds: 400);
  Timer? _timer;
  final RxList<SearchItem> suggestions = <SearchItem>[].obs;
  final Rx<SearchItem?> selectedItem = Rx<SearchItem?>(null); // Track selection
  final String customeId;
  final String salesmanId;
  SalesReturnSearchController({required this.customeId,
  required this.salesmanId,
  });

  void onTextChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => _performSearch(value));
    selectedItem.value = null; // Reset selection when typing
  }

  Future<void> _performSearch(String query) async {
  if (query.trim().isEmpty) {
    clearSuggestions();
    return;
  }
  dev.log('Searching with salesmanId: $salesmanId');

  final resp = await ApiWorker(). searchInvoice(query: query,customerId: customeId,salesmanId: salesmanId);
  if (resp.status && resp.data.isNotEmpty) {
    suggestions.assignAll(resp.data);
    // selectedItem.value = resp.data.first;
  } else {
    suggestions.clear();
  }
}


  void selectItem(SearchItem item) {
    selectedItem.value = item;
    // textCtrl.text = item.orderId; // Optional: show orderId in field
    clearSuggestions(); // Hide dropdown after selection
  }

  void clearSuggestions() => suggestions.clear();
  void clearSelection() => selectedItem.value = null;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}