import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OrderProcessInvoiceDialog extends StatefulWidget {
  OrderProcessInvoiceData? invoiceData;
  FetchSpecificOrderData? specificData;
  final int selectedTabIndex;
  final OrderController orderController;
  OrderProcessInvoiceDialog({
    this.invoiceData,
    this.specificData,
    required this.selectedTabIndex,   required this.orderController,
  });

  @override
  State<OrderProcessInvoiceDialog> createState() =>
      _OrderProcessInvoiceDialogState();
}

class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
  bool isRejecting = false;
  TextEditingController rejectionController = TextEditingController();

  List<TextEditingController> _priceControllers = [];
  List<TextEditingController> _quantityControllers = [];
  List<double> _totalPrices = [];
  bool isChanged = false;
  List<FetchSpecificOrderData> _updatedOrder = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.specificData != null && widget.specificData!.cart != null) {
      _priceControllers = List.generate(
          widget.specificData!.cart!.length,
          (index) => TextEditingController(
              text:
                  widget.specificData!.cart![index].price?.toString() ?? '0'));
      _quantityControllers = List.generate(
          widget.specificData!.cart!.length,
          (index) => TextEditingController(
              text: widget.specificData!.cart![index].quantity?.toString() ??
                  '1'));

      _totalPrices = List.generate(
        widget.specificData!.cart!.length,
        (index) {
          double price = double.tryParse(
                  widget.specificData!.cart![index].price?.toString() ?? '0') ??
              0;
          int quantity = widget.specificData!.cart![index].quantity ?? 1;
          return price * quantity;
        },
      );

      for (int i = 0; i < widget.specificData!.cart!.length; i++) {
        _priceControllers[i].addListener(() => _updateTotalPrice(i));
        _quantityControllers[i].addListener(() => _updateTotalPrice(i));
      }
    }
  }

  void _updateTotalPrice(int index) {
    double price = double.tryParse(_priceControllers[index].text) ?? 0;
    int quantity = int.tryParse(_quantityControllers[index].text) ?? 1;

    setState(() {
      _totalPrices[index] = price * quantity;
    });
  }

  @override
  void dispose() {
    rejectionController.dispose();
    _priceControllers.forEach((controller) => controller.dispose());
    _quantityControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpecificData = widget.selectedTabIndex == 0;
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    // double tax = double.tryParse(isSpecificData
    //         ? widget.specificData?.cart?.first.tax ?? '0'
    //         : widget.invoiceData?.cart?.first.tax ?? '0') ??
    //     0.0;

    // num orderTotal = isSpecificData
    //     ? widget.specificData?.orderTotal ?? 0.0
    //     : widget.invoiceData?.orderTotal ?? 0.0;

    // double calculatedAmount = (tax * orderTotal) / 100;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  dialogCloseButton1(context, red),
                ],
              ),
              const SizedBox(height: 16),
              MyCommnonContainer(
                isCommonBorder: true,
                // color: white,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Invoice Details',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Created At : ${isSpecificData ? (NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(widget.specificData!.orderCreatAt.toString()))) : (NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(widget.invoiceData!.orderCreatAt!.toIso8601String())))}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSpecificData
                                  ? ("Name :   ${widget.specificData?.fullname}")
                                  : ("Name :   ${widget.invoiceData?.fullname}"),
                            ),
                            Text(
                              isSpecificData
                                  ? ("Email :   ${widget.specificData?.email}")
                                  : ("Email :   ${widget.invoiceData?.email}"),
                            ),
                            Text(
                              isSpecificData
                                  ? ("Phone :   ${widget.specificData?.mobileno}")
                                  : ("Phone :   ${widget.invoiceData?.mobileNo}"),
                            ),
                            Text(
                              isSpecificData
                                  ? ("Salesman :   ${widget.specificData?.salesmanName}")
                                  : ("Salesman :   ${widget.invoiceData?.salesmanName}"),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ClipOval(
                          child: Container(
                            height: 50,
                            width: 50,
                            color: Colors.lightBlue[100],
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DataTable(
                      dataRowHeight: 40,
                      headingRowHeight: 40,
                      horizontalMargin: 20,
                      headingTextStyle: const TextStyle(
                        color: black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: totalWidth * 0.2,
                            child: const Text('ITEM NAME'),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'PRICE',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // const DataColumn(
                        //   label: Expanded(
                        //     flex: 2,
                        //     child: Text(
                        //       'QTY',
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                        const DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'CREATED AT',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'TOTAL',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                      rows: (isSpecificData
                              ? widget.specificData?.cart != null &&
                                  widget.specificData!.cart!.isNotEmpty
                              : widget.invoiceData?.cart != null &&
                                  widget.invoiceData!.cart!.isNotEmpty)
                          ? List.generate(
                              isSpecificData
                                  ? widget.specificData!.cart!.length
                                  : widget.invoiceData!.cart!.length,
                              (index) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: totalWidth * 0.2,
                                        child: Text(
                                          isSpecificData
                                              ? ('${widget.specificData!.cart![index].productName} - ${widget.specificData!.cart![index].variationName}' ??
                                                  'No description')
                                              : ('${widget.invoiceData!.cart![index].productName} - ${widget.invoiceData!.cart![index].variationName}' ??
                                                  'No description'),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: isSpecificData
                                            ? TextField(
                                                controller:
                                                    _priceControllers[index],
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: white,
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.all(8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  final originalPrice = widget
                                                      .specificData!
                                                      .cart![index]
                                                      .price;
                                                  if (value !=
                                                      originalPrice
                                                          ?.toString()) {
                                                    setState(() {
                                                      isChanged = true;
                                                    });
                                                  }
                                                  _updateTotalPrice(index);
                                                },
                                                onSubmitted: (value) {
                                                  _updateTotalPrice(index);
                                                },
                                              )
                                            : Text(formatAmount(widget
                                                    .invoiceData
                                                    ?.cart?[index]
                                                    .price
                                                    ?.toString() ??
                                                '0')),
                                      ),
                                    ),
                                    // Quantity
                                    DataCell(
                                      Center(
                                        child: isSpecificData
                                            ? TextField(
                                                controller:
                                                    _quantityControllers[index],
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: white,
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.all(8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  final originalQuantity =
                                                      widget
                                                          .specificData!
                                                          .cart![index]
                                                          .quantity;
                                                  if (value !=
                                                      originalQuantity
                                                          ?.toString()) {
                                                    setState(() {
                                                      isChanged = true;
                                                    });
                                                  }
                                                  _updateTotalPrice(index);
                                                },
                                                onSubmitted: (value) {
                                                  _updateTotalPrice(index);
                                                },
                                              )
                                            : Text(
                                              (widget.invoiceData!.cart![index]
                                                          .packType ==
                                                      'Pack')
                                                  ? '${(widget.invoiceData?.cart?[index].pieces ?? 0) * (widget.invoiceData?.cart?[index].quantity?.toInt() ?? 0)}'
                                                      ' (${widget.invoiceData?.cart?[index].quantity ?? 0} ${widget.invoiceData?.cart?[index].packType})'
                                                  : '${widget.invoiceData?.cart?[index].quantity ?? 0}',
                                            ),
                                      ),
                                    ),
                                    // Created At
                                    // DataCell(
                                    //   Center(
                                    //     child: Text(
                                    //       isSpecificData
                                    //           ? (NKDateUtils.commonDayFormat2(
                                    //               NKDateUtils
                                    //                   .formatStringUTCDateTime(
                                    //                       widget
                                    //                           .specificData!
                                    //                           .cart![index]
                                    //                           .createdAt
                                    //                           .toString())))
                                    //           : (NKDateUtils.commonDayFormat2(
                                    //               NKDateUtils
                                    //                   .formatStringUTCDateTime(
                                    //                       widget
                                    //                           .invoiceData!
                                    //                           .cart![index]
                                    //                           .createdAt
                                    //                           .toString()))),
                                    //     ),
                                    //   ),
                                    // ),
                                    // DataCell(
                                    //   Align(
                                    //     alignment: Alignment.centerRight,
                                    //     child: Text(
                                    //       isSpecificData
                                    //           ? formatAmount(
                                    //               _totalPrices[index])
                                    //           : formatAmount((widget
                                    //                   .invoiceData!
                                    //                   .cart![index]
                                    //                   .price) ??
                                    //               0 *
                                    //                   (widget
                                    //                       .invoiceData!
                                    //                       .cart![index]
                                    //                       .quantity)!),
                                    //     ),
                                    //   ),
                                    // ),
                                    DataCell(
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        isSpecificData
                                            ? formatAmount(_totalPrices[index])
                                            : formatAmount((widget.invoiceData!
                                                    .cart![index].total)
                                                
                                                ),
                                      ),
                                    ),
                                  ),
                                  ],
                                );
                              },
                            )
                          : [
                              const DataRow(
                                cells: [
                                  DataCell(Text('No items available.')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                ],
                              ),
                            ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          color: black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatAmount(isSpecificData
                            ? widget.specificData!.orderTotal ?? 0
                            : widget.invoiceData!.orderTotal ?? 0),
                      ),
                    ],
                  ),
                  if (((isSpecificData
                          ? widget.specificData!.tax
                          : widget.invoiceData!.tax) !=
                      null)) ...[
                    ...(isSpecificData
                            ? widget.specificData!.tax
                            : widget.invoiceData!.tax)!
                        .map((taxItem) {
                      return Row(
                        children: [
                          Text(
                            '${isSpecificData ? taxItem.tax_name : taxItem.tax_name} - ${isSpecificData ? taxItem.tax : taxItem.tax} %',
                            style: const TextStyle(
                              color: black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatAmount(
                              (_getTaxValue(isSpecificData
                                      ? taxItem.tax
                                      : taxItem.tax)) *
                                  (isSpecificData
                                      ? widget.specificData!.orderTotal ?? 0
                                      : widget.invoiceData!.orderTotal ?? 0) /
                                  100,
                            ),
                          ),
                        ],
                      );
                    })
                  ],
                  Divider(color: Colors.grey.shade400),
                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatAmount(
                          (isSpecificData
                                  ? widget.specificData!.orderTotal ?? 0
                                  : widget.invoiceData!.orderTotal ?? 0) +
                              ((_getTaxValue(isSpecificData
                                      ? widget.specificData!.tax!.fold(0.0,
                                          (sum, taxItem) {
                                          return sum + taxItem.tax!.toDouble();
                                        })
                                      : widget.invoiceData!.tax!.fold(0.0,
                                          (sum, taxItem) {
                                          return sum + taxItem.tax!.toDouble();
                                        }))) *
                                  (isSpecificData
                                      ? widget.specificData!.orderTotal ?? 0
                                      : widget.invoiceData!.orderTotal ?? 0) /
                                  100),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              widget.selectedTabIndex == 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.selectedTabIndex == 0 && !isRejecting) ...[
                          CustomButton(
                            text: 'Accept',
                            onPressed: () {
                              if (isChanged) {
                                if (widget.specificData != null) {
                                  for (int i = 0;
                                      i < widget.specificData!.cart!.length;
                                      i++) {
                                    widget.specificData!.cart![i].price =
                                        _priceControllers[i].text ??
                                            widget.specificData!.cart![i].price;
                                    widget.specificData!.cart![i]
                                        .quantity = int.tryParse(
                                            _quantityControllers[i].text) ??
                                        widget.specificData!.cart![i].quantity;
                                  }
                                  setState(() {
                                    _updatedOrder.add(widget.specificData!);
                                    isChanged = false;
                                  });
                                }
                              }

                              String jsonOrder = jsonEncode(_updatedOrder
                                  .map((order) => order.toJson())
                                  .toList());
                              log("JSON Order: $jsonOrder");

                              // log(jsonOrder);

                              // Call the existing action for accepting the order
                              widget.orderController.acceptButtonAction(
                                context: context,
                                orderId:
                                    widget.specificData!.orderId.toString(),
                                updatedOrders:
                                    _updatedOrder, // Pass the list directly
                              );

                              // Pop the screen after the action is completed
                              Navigator.pop(context);
                            },
                          ),
                          nkMediumSizeBox(),
                          CustomButton(
                            text: 'Reject',
                            onPressed: () {
                              setState(() {
                                isRejecting = true;
                              });
                            },
                          ),
                          if (isChanged) ...[
                            nkMediumSizeBox(),
                            CustomButton(
                              text: 'Send for Customer Approval',
                              onPressed: () {
                                if (isChanged) {
                                  // Update specificData with the modified values
                                  if (widget.specificData != null) {
                                    for (int i = 0;
                                        i < widget.specificData!.cart!.length;
                                        i++) {
                                      // Update price and quantity in specificData's cart
                                      widget.specificData!.cart![i].price =
                                          _priceControllers[i].text ??
                                              widget
                                                  .specificData!.cart![i].price;
                                      widget.specificData!.cart![i]
                                          .quantity = int.tryParse(
                                              _quantityControllers[i].text) ??
                                          widget
                                              .specificData!.cart![i].quantity;
                                    }

                                    // Add the updated specificData to _updatedOrder
                                    setState(() {
                                      _updatedOrder.add(widget.specificData!);
                                      isChanged = false;
                                    });
                                  }
                                }

                                String jsonOrder = jsonEncode(_updatedOrder
                                    .map((order) => order.toJson())
                                    .toList());
                                log("JSON Order: $jsonOrder");

                                // log(jsonOrder);

                                // Call the existing action for accepting the order
                                widget.orderController
                                    .sendForCustomerApprovalButtonAction(
                                  context: context,
                                  orderId:
                                      widget.specificData!.orderId.toString(),
                                  updatedOrders:
                                      _updatedOrder, // Pass the list directly
                                );

                                // Pop the screen after the action is completed
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ],
                        if (widget.selectedTabIndex == 0 && isRejecting) ...[
                          Expanded(
                            child: TextField(
                              controller: rejectionController,
                              decoration: const InputDecoration(
                                labelText: 'Rejection Reason',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          nkMediumSizeBox(),
                          CustomButton(
                            text: 'Confirm Reject',
                            onPressed: () {
                              widget.orderController.rejectButtonAction(
                                context: context,
                                orderId:
                                    widget.specificData!.orderId.toString(),
                                reason: rejectionController.text,
                              );
                              String rejectionReason =
                                  rejectionController.text.trim();
                              if (rejectionReason.isNotEmpty) {
                                setState(() {
                                  isRejecting = false;
                                });
                              }
                              // Pop the screen after the action is completed
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        if (widget.selectedTabIndex == 1 && !isRejecting) ...[
                          CustomButton(
                            text: 'Accept',
                            onPressed: () {
                              widget.orderController.acceptButtonAction(
                                context: context,
                                orderId: widget.invoiceData!.orderId.toString(),
                              );
                            },
                          ),
                          nkMediumSizeBox(),
                          CustomButton(
                            text: 'Reject',
                            onPressed: () {
                              setState(() {
                                isRejecting = true;
                              });
                            },
                          ),
                        ],
                        if (widget.selectedTabIndex == 1 && isRejecting) ...[
                          Expanded(
                            child: TextField(
                              controller: rejectionController,
                              decoration: const InputDecoration(
                                labelText: 'Rejection Reason',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          nkMediumSizeBox(),
                          CustomButton(
                            text: 'Confirm Reject',
                            onPressed: () {
                              widget.orderController.rejectButtonAction(
                                context: context,
                                orderId: widget.invoiceData!.orderId.toString(),
                                reason: rejectionController.text,
                              );
                              String rejectionReason =
                                  rejectionController.text.trim();
                              if (rejectionReason.isNotEmpty) {
                                setState(() {
                                  isRejecting = false;
                                });
                              }
                              // Pop the screen after the action is completed
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        if (widget.selectedTabIndex == 2 && !isRejecting) ...[
                          CustomButton(
                            text: 'Accept',
                            onPressed: () {
                              widget.orderController.acceptButtonAction(
                                context: context,
                                orderId: widget.invoiceData!.orderId.toString(),
                              );
                              // Pop the screen after the action is completed
                              Navigator.pop(context);
                            },
                          ),
                          nkMediumSizeBox(),
                          CustomButton(
                            text: 'Reject',
                            onPressed: () {
                              setState(() {
                                isRejecting = true;
                              });
                            },
                          ),
                        ],
                        if (widget.selectedTabIndex == 2 && isRejecting) ...[
                          Expanded(
                            child: TextField(
                              controller: rejectionController,
                              decoration: const InputDecoration(
                                labelText: 'Rejection Reason',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          nkMediumSizeBox(),
                          CustomButton(
                            text: 'Confirm Reject',
                            onPressed: () {
                              widget.orderController.rejectButtonAction(
                                context: context,
                                orderId: widget.invoiceData!.orderId.toString(),
                                reason: rejectionController.text,
                              );
                              String rejectionReason =
                                  rejectionController.text.trim();
                              if (rejectionReason.isNotEmpty) {
                                setState(() {
                                  isRejecting = false;
                                });
                              }
                              // Pop the screen after the action is completed
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        if (widget.selectedTabIndex == 3) ...[
                          CustomButton(
                            text: 'Packed and Ready',
                            onPressed: () {
                              widget.orderController.addToPackedAndReady(
                                context: context,
                                orderId: widget.invoiceData!.orderId.toString(),
                                cartid: widget.invoiceData!.cartId.toString(),
                              );
                              // Pop the screen after the action is completed
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        if (widget.selectedTabIndex == 4) ...[
                          CustomButton(
                            text: 'Deliver',
                            onPressed: () {
                              widget.orderController.deliverButtonAction(
                                context: context,
                                orderId: widget.invoiceData!.orderId.toString(),
                              );
                              // Pop the screen after the action is completed
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        if (widget.selectedTabIndex == 6) ...[
                          const Text('Rejection Reason : '),
                          nkMediumSizeBox(),
                          Text(widget.invoiceData!.rejectionReason.toString()),
                          nkMediumSizeBox(),
                          Text(NKDateUtils.commonDayFormat2(
                              NKDateUtils.formatStringUTCDateTime(widget
                                  .invoiceData!.rejectedDate
                                  .toString()))),
                        ],
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  double _getTaxValue(dynamic tax) {
    if (tax is int) {
      return tax.toDouble(); // If tax is an int, convert it to double
    } else if (tax is String) {
      return double.tryParse(tax) ?? 0; // If tax is a String, parse it safely
    }
    return 0; // Default to 0 if tax is neither int nor String
  }
}
