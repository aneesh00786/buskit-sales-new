import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<dynamic> showDashTimesDialogue<T>(
  BuildContext context,
  T product,
  List<dynamic> Function(T product) getTimesData,
  String Function(dynamic timesData) getCustomer,
  String Function(dynamic timesData) getPrice,
  String Function(dynamic timesData) getTax,
  String Function(dynamic timesData) getQuantity,
  String Function(dynamic timesData) getTotalPrice,
  String Function(dynamic timesData) getPurchasedAt,
  String Function(dynamic timesData) getOrderId,
  bool isDash,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return DashTimesDialog<T>(
        product: product,
        getTimesData: getTimesData,
        getCustomer: getCustomer,
        getPrice: getPrice,
        getTax: getTax,
        getQuantity: getQuantity,
        getTotalPrice: getTotalPrice,
        getPurchasedAt: getPurchasedAt,
        getOrderId: getOrderId,
        isDash: isDash,
      );
    },
  );
}

class DashTimesDialog<T> extends StatefulWidget {
  final T product;
  final List<dynamic> Function(T product) getTimesData;
  final String Function(dynamic timesData) getCustomer;
  final String Function(dynamic timesData) getPrice;
  final String Function(dynamic timesData) getTax;
  final String Function(dynamic timesData) getQuantity;
  final String Function(dynamic timesData) getTotalPrice;
  final String Function(dynamic timesData) getPurchasedAt;
  final String Function(dynamic timesData) getOrderId;
  final bool isDash;

  const DashTimesDialog({
    super.key,
    required this.product,
    required this.getTimesData,
    required this.getCustomer,
    required this.getPrice,
    required this.getTax,
    required this.getQuantity,
    required this.getTotalPrice,
    required this.getPurchasedAt,
    required this.getOrderId,
    required this.isDash,
  });

  @override
  State<DashTimesDialog<T>> createState() => _DashTimesDialogState<T>();
}

class _DashTimesDialogState<T> extends State<DashTimesDialog<T>> {
  late List<dynamic> timesDataList;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    timesDataList = widget.getTimesData(widget.product);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  String get productTitle {
    if (widget.product is TopSellingProductA) {
      final p = widget.product as TopSellingProductA;
      return '${p.productName} - ${p.variationName}';
    } else if (widget.product is FrequantliyProductList) {
      final p = widget.product as FrequantliyProductList;
      return p.variationName.isNotEmpty ? '${p.productName} - ${p.variationName}' : p.productName;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    int totalQty = timesDataList.fold(0, (sum, item) {
      String str = widget.getQuantity(item).replaceAll(RegExp(r'[^0-9.]'), '');
      return sum + (int.tryParse(str) ?? 0);
    });

    double totalTax = timesDataList.fold(0.0, (sum, item) {
      String str = widget.getTax(item).replaceAll(RegExp(r'[^0-9.]'), '');
      return sum + (double.tryParse(str) ?? 0.0);
    });

    double totalSum = timesDataList.fold(0.0, (sum, item) {
      String str = widget.getTotalPrice(item).replaceAll(RegExp(r'[^0-9.]'), '');
      return sum + (double.tryParse(str) ?? 0.0);
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: screenHeight * 0.88,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Gradient Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF2D3748)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 17),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              productTitle,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.35)),
                            ),
                            child: Text(
                              '${timesDataList.length} ${'Records'.tr}',
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 17),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Table / Data Body
              if (timesDataList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Center(child: NodataWidget()),
                )
              else
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        radius: const Radius.circular(8),
                        thickness: 6,
                        notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                                  headingTextStyle: const TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: 0.3,
                                  ),
                                  dataRowMinHeight: 44,
                                  dataRowMaxHeight: 52,
                                  columnSpacing: 16,
                                  horizontalMargin: 16,
                                  columns: [
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Sl.No.'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    if (widget.isDash)
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Customer'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Order Id'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Date'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Price'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Quantity'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Tax'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Amount'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                  ],
                                  rows: timesDataList.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var item = entry.value;
                                    String orderId = widget.getOrderId(item);

                                    return DataRow(
                                      cells: [
                                        // Sl.No.
                                        DataCell(Center(child: Text('${index + 1}.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)))),
                                        // Customer (if isDash)
                                        if (widget.isDash)
                                          DataCell(Center(child: Text(widget.getCustomer(item), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)))),
                                        // Order Id
                                        DataCell(
                                          Center(
                                            child: InkWell(
                                              onTap: () async {
                                                bool isOnline = await ConnectivityService().isOnline();
                                                if (isOnline) {
                                                  showDetailedOrderInvoiceDialog(context, orderId, false);
                                                } else {
                                                  showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                                                ),
                                                child: Text(
                                                  orderId,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins_Regular',
                                                    color: primaryColor,
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Date
                                        DataCell(Center(child: Text(widget.getPurchasedAt(item), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)))),
                                        // Price
                                        DataCell(Center(child: Text(widget.getPrice(item), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)))),
                                        // Quantity
                                        DataCell(Center(child: Text(widget.getQuantity(item), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)))),
                                        // Tax
                                        DataCell(Center(child: Text(widget.getTax(item), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)))),
                                        // Amount
                                        DataCell(Center(child: Text(widget.getTotalPrice(item), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 🔹 Summary Footer
              if (timesDataList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${'Total'.tr}: ',
                            style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                          ),
                          Text(
                            '${timesDataList.length} ${'Orders'.tr} (Qty: $totalQty)',
                            style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${'Total Amount'.tr}: ',
                              style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                            ),
                            Text(
                              formatAmount(totalSum),
                              style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 14, fontWeight: FontWeight.w800, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
