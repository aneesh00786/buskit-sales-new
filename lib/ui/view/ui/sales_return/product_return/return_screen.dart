import 'dart:io';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/product_return_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/product_return_row_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

class ProductReturnDialogContent extends StatefulWidget {
  final String orderId;
  const ProductReturnDialogContent({
    super.key,
    required this.orderId,
  });

  static const double _fixedRowHeight = 70;

  @override
  State<ProductReturnDialogContent> createState() =>
      _ProductReturnDialogContentState();
}

class _ProductReturnDialogContentState
    extends State<ProductReturnDialogContent> {
  File? leadsImage;

  Future<void> pickImages(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        leadsImage = imageFile;
      });
    }
  }

// late final ProductReturnController _ctrl;
  late final ProductReturnController _ctrl;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProductReturnController>();

    // Only clear and fetch if the orderId is different from current
    if (_ctrl.orderId.value != widget.orderId) {
      // Set loading state
      _ctrl.orderData.value = null; // This will show loading indicator
      _ctrl.cartItems.clear();

      // Set new orderId
      _ctrl.orderId.value = widget.orderId;

      // Fetch fresh data
      _ctrl.fetchProductReturnDetails().then((_) {
        for (var item in _ctrl.cartItems) {
          item.damageQty = 0;
          item.returnQty = 0;
          item.image = null;
          item.itemReason = '';
        }
      });
    } else {
      // Same orderId - just reset the form fields
      for (var item in _ctrl.cartItems) {
        item.damageQty = 0;
        item.returnQty = 0;
        item.image = null;
        item.itemReason = '';
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clear text every time screen is displayed
    _ctrl.globalRemarkCtrl.clear();
  }

  bool _isRowInvalid(Cart cart) {
    return (cart.damageQty + cart.returnQty) > (cart.quantity ?? 0);
  }

  InputDecoration _numberFieldDecoration() => InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(6),
      );

  InputDecoration _reasonFieldDecoration() => InputDecoration(
        hintText: 'Reason',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(6),
      );

  // final TextEditingController _globalRemarkCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ---- SCROLLABLE BODY ----
          Expanded(child: Obx(() {
            if (_ctrl.orderData.value == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- TITLE ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Product Return - Invoice #${_ctrl.orderData.value!.invoice!.first.invoiceId}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          // height: 50,
                          // width: 50,
                          child: const FaIcon(
                            FontAwesomeIcons.circleXmark,
                            color: Colors.red,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey[400]),
                  const SizedBox(height: 16),

                  // ---------- COMPANY / CUSTOMER ----------
                  _buildCompanyCustomerRow(),
                  const SizedBox(height: 16),

                  // ---------- TABLE (your pattern) ----------
                  _buildReturnTable(context),

                  const SizedBox(height: 16),

                  // ---------- TOTALS ----------
                  _buildTotals(),
                  const SizedBox(height: 16),

                  // ---------- PAYMENT INFO ----------
                  _buildPaymentInfo(),
                  const SizedBox(height: 16),

                  // ---------- REMARK ----------
                  const Text('Remark *', style: TextStyle(color: Colors.red)),
                  TextField(
                    controller: _ctrl.globalRemarkCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Additional remarks or notes...',
                      // Always show the border (even when not focused)
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey, // You can change the color
                          width: 1.0,
                        ),
                      ),
                      // Optional: Customize focused border (default is blue)
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue, // or any color you prefer
                          width: 2.0,
                        ),
                      ),
                      // You can also set border for other states if needed
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Radius of 8
                          ),
                        ),
                        onPressed: () {},
                        child: CustomText(
                          content: 'Cancel',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Radius of 8
                          ),
                        ),
                        onPressed: () async {
                          await _ctrl.submitReturn();
                        },
                        child: CustomText(
                          content: 'Submit Return',
                          color: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     COMPANY + CUSTOMER ROW
     -------------------------------------------------------------- */
  Widget _buildCompanyCustomerRow() {
    final order = _ctrl.orderData.value;
    if (order == null) {
      return const Center(child: SizedBox()); // Handled by parent Obx
    }
    // final companyLogoUrl = getCompanyLogo(allCompanySettings);
// print('image urlll:${order.imageUrl!}');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50, // radius * 2
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // makes it round
                      image: DecorationImage(
                        image:
                            NetworkImage("https://test.thrivewoo.com/uploads/setting/1739620175980.jpg"), // your network image
                        fit: BoxFit.cover, // same as CircleAvatar
                      ),
                    ),

                    child: order.imageUrl == null
                        ? const Icon(Icons.person,
                            size: 24, color: Color.fromARGB(255, 244, 8, 8))
                        : null,
                  ),

                  // CircleAvatar(
                  //     radius: 20,
                  //     backgroundImage:
                  //         NetworkImage(order.imageUrl!)),
                  const SizedBox(width: 8),
                  const Text('JRBS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('470 St Kilda Rd'),
              const Text('VIC, Australia'),
              const SizedBox(height: 4),
              const Text('Email: buskit@google.com'),
              const Text('Phone: 1800865022'),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(order.businessName ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(order.address ?? ''),
              Text('Email: ${order.email}'),
              Text('Phone: ${order.mobileno}'),
              const SizedBox(height: 8),
              Text(
                'Order: ${order.orderId} | Invoice: ${order.invoice?.isNotEmpty == true ? order.invoice!.first.invoiceId : 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /* --------------------------------------------------------------
     TABLE – built with your exact header/row pattern
     -------------------------------------------------------------- */
  Widget _buildReturnTable(BuildContext context) {
    _ctrl.rowControllers.clear();
    if (_ctrl.cartItems.isEmpty) {
      return const Text("No items in this order");
    }

    const double colItem = 360;
    const double colUnit = 130;
    const double colQty = 150;
    const double colAmt = 150;
    const double colDisc = 150;
    const double colTax = 150;
    const double colTotal = 150;
    const double colAvail = 110;
    const double colDamage = 110;
    const double colReturn = 110;
    const double colImg = 130;
    const double colReason = 180;

    const double totalTableWidth = colItem +
        colUnit +
        colQty +
        colAmt +
        colDisc +
        colTax +
        colTotal +
        colAvail +
        colDamage +
        colReturn +
        colImg +
        colReason;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: Item Name
        SizedBox(
          width: 250,
          child: Column(
            children: [
              _buildHeader1(
                Center(
                  child: CustomText(
                      content: 'Item',
                      textAlign: TextAlign.center,
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                250,
              ),
              ..._ctrl.cartItems.asMap().entries.map((e) {
                return Container(
                  height: ProductReturnDialogContent._fixedRowHeight,
                  width: double.infinity,
                  color: e.key.isEven ? Colors.grey[50] : Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Product Name - takes available space
                      Expanded(
                        child: Text(
                          '${e.value.productName ?? '-'} - ${e.value.variationName ?? '-'}',
                          // e.value.productName ?? '-',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // RIGHT: Scrollable
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                // thumbColor: WidgetStatePropertyAll( Color( primaryColor)), // Custom thumb color
                thumbColor: WidgetStatePropertyAll(Colors.blue),
                // WidgetStatePropertyAll(Theme.of(context).primaryColor),
                radius: const Radius.circular(10), // Optional: rounded corners
                thickness: WidgetStatePropertyAll(6), // Optional: thickness
              ),
            ),
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalTableWidth - 250,
                  child: Column(
                    children: [
                      _buildScrollableHeader(),
                      ..._ctrl.cartItems.asMap().entries.map((e) {
                        final cart = e.value;
                        final productReturnRowController =
                            ProductReturnRowController(cart);
                        _ctrl.rowControllers.add(productReturnRowController);
                        return Container(
                          height: ProductReturnDialogContent._fixedRowHeight,
                          color: e.key.isEven ? Colors.grey[50] : Colors.white,
                          child: Row(
                            children: [
                              // _col(cart.price?.toStringAsFixed(2) ?? '0.00',
                              //     colUnit),
                              _col(formatAmount(cart.price), colUnit),
                              _col(
                                  '${cart.pieces ?? 0} (${cart.quantity ?? 0} ${cart.packType ?? ''})'
                                      .trim(),
                                  colQty),
                              _col(
                                formatAmount(
                                    cart.totalPrice), // e.g., ₹ 1,500.00
                                colAmt,
                                align: TextAlign.right,
                              ),
                              // _col(cart.discountAmount ?? '0.00', colDisc),
                              _col(
                                formatAmount(
                                    cart.discountAmount), // e.g., ₹ 100.00
                                colDisc,
                                align: TextAlign.right,
                              ),
                              // _col(cart.tax?.toStringAsFixed(2) ?? '0.00',
                              //     colTax),
                              _col(
                                formatAmount(cart.tax), // e.g., ₹ 270.00
                                colTax,
                                align: TextAlign.right,
                              ),
                              // _col(
                              //     cart.totalPrice?.toStringAsFixed(2) ?? '0.00',
                              //     colTotal),
                              _col(
                                formatAmount(cart.totalPrice),
                                colTotal,
                                align: TextAlign.right,
                              ),
                              _col((cart.quantity ?? 0).toString(), colAvail,
                                  align: TextAlign.center),
                              SizedBox(
                                width: 10,
                              ),
                              // SizedBox(width: 80,child: _editableNumberField()),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller:
                                      productReturnRowController.damageCtrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: _numberFieldDecoration().copyWith(
                                    // Optional: Visual error if invalid
                                    errorText: _isRowInvalid(cart) ? '' : null,
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 80,
                              //   child: TextField(
                              //     controller:
                              //         productReturnRowController.damageCtrl,
                              //     keyboardType: TextInputType.number,
                              //     textAlign: TextAlign.center,
                              //     decoration:
                              //         _numberFieldDecoration(), // reuse your style
                              //   ),
                              // ),
                              SizedBox(
                                width: 30,
                              ),
                              //  SizedBox(width: 80,child: _editableNumberField()),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller:
                                      productReturnRowController.returnCtrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: _numberFieldDecoration().copyWith(
                                    errorText: _isRowInvalid(cart) ? '' : null,
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 80,
                              //   child: TextField(
                              //     controller:
                              //         productReturnRowController.returnCtrl,
                              //     keyboardType: TextInputType.number,
                              //     textAlign: TextAlign.center,
                              //     decoration: _numberFieldDecoration(),
                              //   ),
                              // ),
                              SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: 80,
                                child: _uploadImageBtn(),
                                //  _uploadImageBtn(
                                //   onPicked: (File file) =>
                                //       setState(() => cart.image = file),
                                //   currentFile: e.value.image,
                                // ),
                              ),
                              //  SizedBox(width:80,child:  _uploadImageBtn()),
                              SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: 310,
                                child: TextField(
                                  controller:
                                      productReturnRowController.reasonCtrl,
                                  decoration: _reasonFieldDecoration(),
                                ),
                              ),
                              // SizedBox(width:310, child: _reasonDropdown()),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* --------------------------------------------------------------
     Header helpers (exact copy of your code)
     -------------------------------------------------------------- */
  Widget _buildHeader1(Widget child, double width) => Container(
        width: width,
        alignment: Alignment.center,
        // color: primaryColor,
        color: const Color.fromARGB(255, 7, 127, 226),
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: child,
      );

  Widget _buildScrollableHeader() {
    return Container(
      // color: primaryColor,
      color: const Color.fromARGB(255, 7, 127, 226),
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          _headerCell('Unit Price', 130),
          _headerCell('Quantity', 150),
          _headerCell('Amount', 150),
          _headerCell('Discount', 150),
          _headerCell('Tax', 150),
          _headerCell('Total', 150),
          _headerCell('Available Qty', 110),
          _headerCell('Damage Qty', 110),
          _headerCell('Return Qty', 110),
          _headerCell('Image', 80),
          _headerCell('Reason', 300),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: CustomText(
          content: text,
          textAlign: TextAlign.center,
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _col(String txt, double width, {TextAlign align = TextAlign.left}) {
    return SizedBox(
      width: width,
      child: Center(
        child: CustomText(
          content: txt,
          fontSize: 12,
          textAlign: align,
        ),
      ),
    );
  }

  // Widget _editableNumberField() {
  //   return TextField(
  //     keyboardType: TextInputType.number,
  //     textAlign: TextAlign.center,
  //     decoration: InputDecoration(
  //       // Always visible border (when not focused)
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(
  //           color: Colors.blue,
  //           width: 1.5,
  //         ),
  //       ),
  //       // Border when focused (slightly thicker for better UX)
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(
  //           color: Colors.blue,
  //           width: 2.0,
  //         ),
  //       ),
  //       // Optional: fallback border
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       contentPadding: const EdgeInsets.all(6),
  //     ),
  //   );
  // }

  // Widget _uploadImageBtn(
  //     {required Function(File) onPicked, File? currentFile}) {
  //   return InkWell(
  //     onTap: () async {
  //       final picker = ImagePicker();
  //       final picked = await picker.pickImage(source: ImageSource.gallery);
  //       if (picked != null) onPicked(File(picked.path));
  //     },
  //     child: Container(
  //       height: 40,
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.blue),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Center(
  //         child: currentFile == null
  //             ? const Icon(Icons.camera_alt, size: 20)
  //             : const Icon(Icons.check, color: Colors.green),
  //       ),
  //     ),
  //   );
  // }

  Widget _uploadImageBtn() {
    return InkWell(
      onTap: () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Method'),
              actions: [
                IconButton(
                  onPressed: () async {
                    await pickImages(ImageSource.camera);
                    // setState(() {});
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(EneftyIcons.camera_outline),
                ),
                IconButton(
                  onPressed: () async {
                    await pickImages(ImageSource.gallery);
                    // setState(() {});
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(EneftyIcons.gallery_bold),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.upload, size: 16, color: Colors.blue),
            SizedBox(width: 4),
            // Text('Upload Image', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _reasonDropdown() {
    return TextField(
      keyboardType: TextInputType.text,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        // Always visible border (when not focused)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 1.5,
          ),
        ),
        // Border when focused (slightly thicker for better UX)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        // Optional: fallback border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(6),
      ),
    );
  }

  /* --------------------------------------------------------------
     TOTALS
     -------------------------------------------------------------- */

  Widget _buildTotals() {
    final order = _ctrl.orderData.value!;

    // 1. Calculate subtotal (excluding tax)
    double taxTotal = 0.0;
    if (order.tax != null) {
      for (var t in order.tax!) {
        final amount = double.tryParse(t.taxAmount.toString() ?? '0') ?? 0.0;
        taxTotal += amount;
      }
    }

    final double orderTotal =
        double.tryParse(order.orderTotal.toString() ?? '0') ?? 0.0;
    final double subtotal = orderTotal - taxTotal; // $2000 - $300 = $1700
    final double discount = 0.0; // You can get this from cart if needed

    final List<Widget> rows = [];

    // Subtotal
    rows.add(_totalRow(
      'Subtotal:',
      formatAmount(subtotal), // <-- uses currency symbol + Indian format
    ));
    // rows.add(_totalRow('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'));

    // Discount (only if > 0)
    if (discount > 0) {
      rows.add(_totalRow(
        'Discount:',
        '-${formatAmount(discount)}',
      ));
    }
    // if (discount > 0) {
    //   rows.add(_totalRow('Discount:', '-\$${discount.toStringAsFixed(2)}'));
    // }

    // Taxes (only if exist)
    if (order.tax != null && order.tax!.isNotEmpty) {
      for (var t in order.tax!) {
        final amount = double.tryParse(t.taxAmount.toString()) ?? 0.0;
        rows.add(_totalRow(
          '${t.taxName ?? ''} - ${t.tax ?? ''}%',
          formatAmount(amount),
        ));
      }
    }
    // if (order.tax != null && order.tax!.isNotEmpty) {
    //   for (var t in order.tax!) {
    //     final amount = double.tryParse(t.taxAmount.toString() ?? '0') ?? 0.0;
    //     rows.add(_totalRow(
    //       '${t.taxName ?? ''} - ${t.tax ?? ''}%',
    //       '\$${amount.toStringAsFixed(2)}',
    //     ));
    //   }
    // }

    // Divider before Total
    rows.add(const Divider(color: Colors.black));

    // Total (bold)
    rows.add(_totalRow(
      'Total:',
      formatAmount(orderTotal),
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));
    // rows.add(_totalRow(
    //   'Total:',
    //   '\$${orderTotal.toStringAsFixed(2)}',
    //   style: const TextStyle(fontWeight: FontWeight.bold),
    // ));

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: rows,
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style),
          const SizedBox(width: 16),
          Text(value, style: style),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     PAYMENT INFO
     -------------------------------------------------------------- */
  Widget _buildPaymentInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Payment Status: Paid',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Payment Method: Cash',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}



