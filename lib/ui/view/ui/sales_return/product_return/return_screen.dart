import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_invoice.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/product_return_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/product_return_row_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/return_info_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/return_info_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/return_info_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/custom_scrollbar.dart';
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

  static const double _fixedRowHeight = 100;

  @override
  State<ProductReturnDialogContent> createState() =>
      _ProductReturnDialogContentState();
}

class _ProductReturnDialogContentState
    extends State<ProductReturnDialogContent> {
  File? leadsImage;
  Future<File?> pickImages(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return null;

    final imageFile = File(pickedFile.path);
    final sizeInBytes = imageFile.lengthSync();
    const maxSizeInBytes = 500 * 1024;

    if (sizeInBytes <= maxSizeInBytes) {
      // ✅ Good to go
      setState(() {
        leadsImage = imageFile;
      });
      return imageFile;
    } else {
      // ❌ Too big – inform the user
      if (!mounted) return null;
      Get.snackbar(
          'Image too large (${(sizeInBytes / 1024).toStringAsFixed(1)} KB). ',
          'Please select an image 500 KB or smaller',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP);

      return null;
    }
  }

  late final ProductReturnController _ctrl;
  final ScrollController _horizontalScrollController = ScrollController();
  late final PendingReturnsController _returnInfoCtrl;
  @override
void initState() {
  super.initState();
  _ctrl = Get.find<ProductReturnController>();
  _returnInfoCtrl = Get.find<PendingReturnsController>();
  _horizontalScrollController.addListener(() {
    setState(() {});
  });
  
  if (_ctrl.orderId.value != widget.orderId) {
    _ctrl.orderData.value = null;
    _ctrl.cartItems.clear();
    _ctrl.orderId.value = widget.orderId;
    
    // First fetch product details
    _ctrl.fetchProductReturnDetails().then((_) {
      // Reset cart items
      for (var item in _ctrl.cartItems) {
        item.damageQty = 0;
        item.returnQty = 0;
        item.image = null;
        item.itemReason = '';
      }
      
      // Then fetch pending returns (now orderData is available)
      return _returnInfoCtrl.fetchPendingReturns(
        cartId: _ctrl.orderData.value?.cartId ?? '',
        companyId: _ctrl.orderData.value?.companyId?.toString() ?? '',
      );
    }).then((_) {
      // Assign immediately after pending returns completes
      _ctrl.returnInfo.value = _returnInfoCtrl.returnsResponse.value;
    });
    
  } else {
    // Reset cart items
    for (var item in _ctrl.cartItems) {
      item.damageQty = 0;
      item.returnQty = 0;
      item.image = null;
      item.itemReason = '';
    }
    
    // Fetch pending returns and assign immediately
    _returnInfoCtrl.fetchPendingReturns(
      cartId: _ctrl.orderData.value!.cartId!,
      companyId: _ctrl.orderData.value!.companyId!.toString(),
    ).then((_) {
      _ctrl.returnInfo.value = _returnInfoCtrl.returnsResponse.value;
    });
  }
}
  // @override
  // void initState() {
  //   super.initState();
  //   _ctrl = Get.find<ProductReturnController>();
  //   _returnInfoCtrl = Get.find<PendingReturnsController>();

  //   _horizontalScrollController.addListener(() {
  //     setState(() {});
  //   });

  //   if (_ctrl.orderId.value != widget.orderId) {
  //     _ctrl.orderData.value = null;
  //     _ctrl.cartItems.clear();

  //     _ctrl.orderId.value = widget.orderId;

  //     _ctrl.fetchProductReturnDetails().then((_) {
  //       for (var item in _ctrl.cartItems) {
  //         item.damageQty = 0;
  //         item.returnQty = 0;
  //         item.image = null;
  //         item.itemReason = '';
  //       }
  //       _returnInfoCtrl.fetchPendingReturns(
  //           cartId: _ctrl.orderData.value!.cartId!,
  //           companyId: _ctrl.orderData.value!.companyId!.toString());
  //       _ctrl.returnInfo.value = _returnInfoCtrl.returnsResponse.value;
  //     });
  //   } else {
  //     for (var item in _ctrl.cartItems) {
  //       item.damageQty = 0;
  //       item.returnQty = 0;
  //       item.image = null;
  //       item.itemReason = '';
  //     }
  //     _returnInfoCtrl.fetchPendingReturns(
  //         cartId: _ctrl.orderData.value!.cartId!,
  //         companyId: _ctrl.orderData.value!.companyId!.toString());
  //     _ctrl.returnInfo.value = _returnInfoCtrl.returnsResponse.value;
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _ctrl.globalRemarkCtrl.clear();
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
                  _buildTaxTotal(),
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
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
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
                        onPressed: () {
                          Get.back();
                        },
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
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _ctrl.isSubmitting.value
                            ? null
                            : () => _ctrl.submitReturn(),
                        child: _ctrl.isSubmitting.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : CustomText(
                                content: 'Submit Return',
                                color: Colors.white,
                              ),
                      ),
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
      return const Center(child: SizedBox());
    }

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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                            ApiConstants.imageEndpoint), // your network image
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: order.imageUrl == null
                        ? const Icon(Icons.person,
                            size: 24, color: Color.fromARGB(255, 244, 8, 8))
                        : null,
                  ),
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
                'Invoice: ${order.invoice?.isNotEmpty == true ? order.invoice!.first.invoiceId : 'N/A'} | ${NKDateUtils.commonFullDateTimeFormat2(order.invoice!.firstOrNull!.createdAt!)}',
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
                        child: ProductNameWithTax(
                          productName: '${e.value.productName ?? '-'}',
                          variationName: '${e.value.variationName ?? '-'}', 
                          isInclTax: e.value.inclTax == "incl_tax" , 
                          maxWidth: isPhonePortrait(
                                                        context)
                                                    ? fullScreenWidth(context) *
                                                        0.4
                                                    : fullScreenWidth(context) *
                                                        0.2, 
                          style: TextStyle(
                                                    fontSize: 14),
                          ),

                        // child: Text(
                        //   '${e.value.productName ?? '-'} - ${e.value.variationName ?? '-'}',
                        //   // e.value.productName ?? '-',
                        //   style: const TextStyle(fontSize: 13),
                        //   maxLines: 2,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
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
          child: Stack(
            children: [
              SingleChildScrollView(
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
                        File? selectedImage;

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
                              // ---------- SUPPLIED QTY + INFO BUTTON (only if pending return exists) ----------
// ---------- SUPPLIED QTY + INFO BUTTON ----------

                              _suppQtyCol(
                                (cart.suppliedQty ?? 0).toString(),
                                colAvail,
                                align: TextAlign.center,
                                cart: cart,
                              ),

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
                                    decoration: _numberFieldDecoration()),
                              ),

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
                                    decoration: _numberFieldDecoration()),
                              ),
                              // SizedBox(

                              SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: 80,
                                child: _uploadImageBtn(
                                  onPicked: (File file) =>
                                      setState(() => cart.image = file),
                                  currentFile: cart.image,
                                ),
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomHorizontalScrollbar(
                  controller: _horizontalScrollController,
                ),
              ),
            ],
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
          _headerCell('Sup. Qty', 110),
          _headerCell('Dam. Qty', 110),
          _headerCell('Ret. Qty', 110),
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

  /// ---------------------------------------------------------------
  ///  Updated _col – now supports an optional trailing info button
  /// ---------------------------------------------------------------
  


  Widget _suppQtyCol(
  String txt,
  double width, {
  TextAlign align = TextAlign.left,
  required Cart cart,
}) {
  return SizedBox(
    width: width,
    child: Center(
      child: Obx(() {
        // --- ALL LOGIC INSIDE Obx → fully reactive ---
        final info = _ctrl.returnInfo.value;
        if (info == null) {
          return _buildQtyText(txt, align);
        }

        final hasPending = info.aggregated.any((a) => a.variationId == cart.variationId);
        final pendingQty = info.aggregated
                .firstWhere(
                  (a) => a.variationId == cart.variationId,
                  orElse: () => Aggregated(variationId: '', pendingQty: 0),
                )
                .pendingQty ??
            0;

        // Filter the full data list
        final filtered = info.data
            .where((r) => r.variationId == cart.variationId)
            .toList();

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Supplied Qty
            Flexible(
              child: CustomText(
                content: txt,
                fontSize: 12,
                textAlign: align,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 2. Info Button
            if (hasPending) ...[
              const SizedBox(width: 6),
              SizedBox(
                width: 20,
                height: 20,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  tooltip: 'Pending: $pendingQty',
                  onPressed: () {
                    
                    showPendingReturnsDialog(context,cart.productName ?? '',cart.variationName ?? '',filtered);
                  },
                ),
              ),
            ],
          ],
        );
      }),
    ),
  );
}
void showPendingReturnsDialog(BuildContext context,String productName,String variationName,List<ReturnInfoData> filtered ) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 10,
        child:  PendingReturnsPopup(
           productName: productName,        // Use parameter
          variationName: variationName,    // Use parameter
          returnItems: filtered,

        ),
      );
    },
  );
}

// Helper: just the text part (for when no data)
Widget _buildQtyText(String txt, TextAlign align) {
  return Flexible(
    child: CustomText(
      content: txt,
      fontSize: 12,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

// Widget _uploadImageBtn({
//   required Function(File file) onPicked,
//   required VoidCallback onDelete, // 👈 Add this callback for delete action
//   File? currentFile,
// }) {
//   return InkWell(
//     onTap: () {
//       if (currentFile != null) return; // 👈 Prevent reopening dialog when image exists
//       showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Select Method'),
//             actions: [
//               IconButton(
//                 onPressed: () async {
//                   final file = await pickImages(ImageSource.camera);
//                   if (file != null) onPicked(file);
//                   Navigator.of(context).pop();
//                 },
//                 icon: const Icon(EneftyIcons.camera_outline),
//               ),
//               IconButton(
//                 onPressed: () async {
//                   final file = await pickImages(ImageSource.gallery);
//                   if (file != null) onPicked(file);
//                   Navigator.of(context).pop();
//                 },
//                 icon: const Icon(EneftyIcons.gallery_bold),
//               ),
//             ],
//           );
//         },
//       );
//     },
//     child: Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.blue),
//         borderRadius: BorderRadius.circular(8),
//         image: currentFile != null
//             ? DecorationImage(
//                 image: FileImage(currentFile),
//                 fit: BoxFit.cover,
//               )
//             : null,
//       ),
//       child: currentFile == null
//           ? Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Icon(Icons.upload, size: 24, color: Colors.blue),
//                   SizedBox(height: 4),
//                   Text(
//                     "Upload",
//                     style: TextStyle(fontSize: 12, color: Colors.blue),
//                   ),
//                 ],
//               ),
//             )
//           : Align(
//               alignment: Alignment.topRight,
//               child: Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red, size: 20),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       onPressed: onDelete, // 👈 Calls delete callback
//                     ),
//                     const SizedBox(width: 4),
//                     const Icon(Icons.check_circle,
//                         color: Colors.green, size: 20),
//                   ],
//                 ),
//               ),
//             ),
//     ),
//   );
// }

  Widget _uploadImageBtn({
    required Function(File file) onPicked,
    File? currentFile,
  }) {
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
                    final file = await pickImages(
                      ImageSource.camera,
                    );
                    if (file != null) onPicked(file);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(EneftyIcons.camera_outline),
                ),
                IconButton(
                  onPressed: () async {
                    final file = await pickImages(
                      ImageSource.gallery,
                    );
                    if (file != null) onPicked(file);
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
          children: [
            Icon(Icons.upload, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            if (currentFile != null)
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }

  /* --------------------------------------------------------------
     TOTALS
     -------------------------------------------------------------- */

  Widget _buildTaxTotal() {
    final order = _ctrl.orderData.value!;

    if (order.tax == null || order.tax!.isEmpty) {
      return const SizedBox.shrink();
    }

    double taxTotal = 0.0;
    final List<String> taxParts = [];

    for (var t in order.tax!) {
      final amount = double.tryParse(t.taxAmount.toString()) ?? 0.0;
      taxTotal += amount;

      final taxName = t.taxName ?? '';
      final taxRate = t.tax ?? '';
      final formatted = formatAmount(amount);

      taxParts.add('$taxName - $taxRate% : $formatted');
    }

    final middle = taxParts.join('   ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black),
              children: [
                const TextSpan(
                  text: 'TAX : ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: middle),
                const TextSpan(
                  text: '  TOTAL : ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: formatAmount(taxTotal)),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    final order = _ctrl.orderData.value!;

    final double orderTotal =
        double.tryParse(order.orderTotal.toString()) ?? 0.0;
    final double subtotal = double.tryParse(order.subTotal.toString()) ?? 0.0;
    final double discount = 0.0;

    final List<Widget> rows = [];

    // ---------- SUBTOTAL ----------
    rows.add(_totalRow('Subtotal:', formatAmount(subtotal)));

    // ---------- DISCOUNT ----------
    rows.add(_totalRow('Discount:', '${formatAmount(discount)}'));

    // ---------- TOTAL (BEFORE TAX) ----------
    rows.add(
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: _totalRow(
          'Total:',
          formatAmount(orderTotal),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    // ---------- TAX (now a separate widget method) ----------
    // rows.add(_buildTaxTotal());

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
    final order = _ctrl.orderData.value!;

    // ---- 1. Payment Status (unchanged) ----
    String paymentStatusText;
    switch (order.paymentStatus) {
      case 0:
        paymentStatusText = 'Pending';
        break;
      case 1:
        paymentStatusText = 'Paid';
        break;
      case 3:
        paymentStatusText = 'Partially Paid';
        break;
      default:
        paymentStatusText = 'Unknown';
    }

    // ---- 2. Payment Method (conditional) ----
    String paymentMethodText;

    if (order.paymentStatus == 0) {
      // Pending → No payment method
      paymentMethodText = '';
    } else {
      // Paid or Partially Paid → Show actual method
      switch (order.paymentType) {
        case 0:
          paymentMethodText = 'Cash';
          break;
        case 1:
          paymentMethodText = 'Check';
          break;
        case 2:
          paymentMethodText = 'Bank Transfer';
          break;
        default:
          paymentMethodText = 'N/A';
      }
    }

    // ---- Final UI ----
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Payment Status: $paymentStatusText',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10,),
        Text(
          'Payment Method: $paymentMethodText',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// At the bottom of the file (replace the old function)
