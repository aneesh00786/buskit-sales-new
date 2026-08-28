import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductListDialog<T> extends StatefulWidget {
  final List<T> productList;
  final double Function(T) getQuantity;
  final String Function(T) getProductName;
  final String Function(T) getVariationName;
  final String Function(T) getFormattedDate;
  final String Function(T) getPrice;
  final String Function(T) getInNo;
  final int Function(T) getBuyQuantity;
  final void Function(BuildContext, T) onQuantityTap;

  const ProductListDialog({
    super.key,
    required this.productList,
    required this.getQuantity,
    required this.getProductName,
    required this.getVariationName,
    required this.getFormattedDate,
    required this.getPrice,
    required this.getInNo,
    required this.getBuyQuantity,
    required this.onQuantityTap,
  });

  @override
  State<ProductListDialog<T>> createState() => _ProductListDialogState<T>();
}

class _ProductListDialogState<T> extends State<ProductListDialog<T>> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    int totalQty = widget.productList.fold(0, (sum, item) => sum + widget.getBuyQuantity(item));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 900,
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
              // 🔹 Header
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_mall_outlined, color: Colors.white, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Frequently Bought Products'.tr,
                          style: const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.35)),
                          ),
                          child: Text(
                            '${widget.productList.length} ${'Products'.tr}',
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

              // 🔹 Body / DataTable
              if (widget.productList.isEmpty)
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
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        radius: const Radius.circular(8),
                        thickness: 6,
                        notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                        child: Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
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
                                  dataRowMinHeight: 46,
                                  dataRowMaxHeight: 56,
                                  columnSpacing: 16,
                                  horizontalMargin: 16,
                                  columns: [
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Sl.No.'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Product'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('I/N'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Last Purchase'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Times'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Amount'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Qty'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                  ],
                                  rows: widget.productList.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    T product = entry.value;
                                    String variation = widget.getVariationName(product);
                                    String prodName = variation.isNotEmpty
                                        ? '${widget.getProductName(product)} - $variation'
                                        : widget.getProductName(product);

                                    int timesCount = widget.getQuantity(product).toInt();

                                    return DataRow(
                                      cells: [
                                        // Sl.No.
                                        DataCell(Center(child: Text('${index + 1}.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)))),
                                        // Product
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(maxWidth: 220),
                                            child: Text(
                                              prodName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                            ),
                                          ),
                                        ),
                                        // I/N
                                        DataCell(Center(child: Text(widget.getInNo(product), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)))),
                                        // Last Purchase
                                        DataCell(Center(child: Text(widget.getFormattedDate(product), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)))),
                                        // Times
                                        DataCell(
                                          Center(
                                            child: InkWell(
                                              onTap: () {
                                                widget.onQuantityTap(context, product);
                                                setState(() {});
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0284C7),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '$timesCount',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins_Regular',
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Amount
                                        DataCell(Center(child: Text(widget.getPrice(product), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)))),
                                        // Qty
                                        DataCell(Center(child: Text('${widget.getBuyQuantity(product)}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)))),
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
              if (widget.productList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'Showing'.tr} ${widget.productList.length} ${'Products'.tr}',
                        style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
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
                              '${'Total Qty'.tr}: ',
                              style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                            ),
                            Text(
                              '$totalQty',
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

void showProductListDialog<T>({
  required BuildContext context,
  required List<T> productList,
  required double Function(T) getQuantity,
  required String Function(T) getProductName,
  required String Function(T) getVariationName,
  required String Function(T) getFormattedDate,
  required String Function(T) getPrice,
  required String Function(T) getInNo,
  required int Function(T) getBuyQuantity,
  required void Function(BuildContext, T) onQuantityTap,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return ProductListDialog<T>(
        productList: productList,
        getQuantity: getQuantity,
        getProductName: getProductName,
        getVariationName: getVariationName,
        getFormattedDate: getFormattedDate,
        getPrice: getPrice,
        getInNo: getInNo,
        getBuyQuantity: getBuyQuantity,
        onQuantityTap: onQuantityTap,
      );
    },
  );
}
