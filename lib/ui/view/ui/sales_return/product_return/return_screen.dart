import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/offline_order_details_dialog.dart';
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
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

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
  // Single-continuous-gradient table header: the frozen "Item" header cell
  // and the scrollable header row must stay in sync horizontally while
  // being painted by one shared gradient container (see _buildReturnTable),
  // matching the pattern already used for Leads/Pending Payments tables.
  final LinkedScrollControllerGroup _horizontalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _headerHorizontalController =
      _horizontalGroup.addAndGet();
  late final ScrollController _bodyHorizontalController =
      _horizontalGroup.addAndGet();
  late final PendingReturnsController _returnInfoCtrl;
  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProductReturnController>();
    _returnInfoCtrl = Get.find<PendingReturnsController>();
    _bodyHorizontalController.addListener(() {
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
      _returnInfoCtrl
          .fetchPendingReturns(
        cartId: _ctrl.orderData.value!.cartId!,
        companyId: _ctrl.orderData.value!.companyId!.toString(),
      )
          .then((_) {
        _ctrl.returnInfo.value = _returnInfoCtrl.returnsResponse.value;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _ctrl.globalRemarkCtrl.clear();
  }

  @override
  void dispose() {
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  InputDecoration _numberFieldDecoration() => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(6),
      );

  InputDecoration _reasonFieldDecoration() => InputDecoration(
        hintText: 'Reason',
        hintStyle: const TextStyle(
          fontFamily: 'Poppins_Regular',
          color: Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(6),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: Obx(() {
            if (_ctrl.orderData.value == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // ---------- HEADER (single gradient bar acting as the
            // AlertDialog's missing header, since the outer AlertDialog
            // shape/call-site can't be edited here) + scrollable body ----------
            return Column(
              children: [
                _buildDialogHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const Text('Remark *',
                            style: TextStyle(
                              fontFamily: 'Poppins_Regular',
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _ctrl.globalRemarkCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                              fontFamily: 'Poppins_Regular', fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Additional remarks or notes...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              color: Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: primaryColor,
                                width: 1.5,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF94A3B8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Poppins_Regular',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
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
                                  : const Text(
                                      'Submit Return',
                                      style: TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          })),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     DIALOG HEADER – gradient bar standing in for the (unstyled,
     out-of-scope) outer AlertDialog header. The close action below is
     the exact same `Navigator.of(context).pop()` the plain FaIcon button
     used to call — only the visuals changed.
     -------------------------------------------------------------- */
  Widget _buildDialogHeader(BuildContext context) {
    final order = _ctrl.orderData.value;
    final invoiceId = (order?.invoice != null && order!.invoice!.isNotEmpty)
        ? order.invoice!.first.invoiceId
        : 'N/A';
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_return_outlined,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Product Return - Invoice #$invoiceId',
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkResponse(
            onTap: () => Navigator.of(context).pop(),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
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

    const labelStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: Color(0xFF94A3B8),
    );
    const nameStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF0F172A),
    );
    const metaStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 12.5,
      color: Color(0xFF64748B),
      height: 1.5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FROM', style: labelStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: primaryColor.withOpacity(0.15), width: 2),
                        image: DecorationImage(
                          image: NetworkImage(ApiConstants.imageEndpoint),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: order.imageUrl == null
                          ? const Icon(Icons.person,
                              size: 22, color: Color(0xFF94A3B8))
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('JRBS', style: nameStyle)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('470 St Kilda Rd', style: metaStyle),
                const Text('VIC, Australia', style: metaStyle),
                const SizedBox(height: 4),
                const Text('Email: buskit@google.com', style: metaStyle),
                const Text('Phone: 1800865022', style: metaStyle),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('TO', style: labelStyle),
                const SizedBox(height: 8),
                Text(order.businessName ?? 'N/A',
                    textAlign: TextAlign.right, style: nameStyle),
                const SizedBox(height: 8),
                Text(order.address ?? '',
                    textAlign: TextAlign.right, style: metaStyle),
                Text('Email: ${order.email}',
                    textAlign: TextAlign.right, style: metaStyle),
                Text('Phone: ${order.mobileno}',
                    textAlign: TextAlign.right, style: metaStyle),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${order.invoice?.isNotEmpty == true ? order.invoice!.first.invoiceId : "N/A"} | ${order.invoice?.isNotEmpty == true && order.invoice!.first.createdAt != null ? TimeUtils.formatTimeInZone(order.invoice!.first.createdAt!, format: "dd/MM/yyyy hh:mm a") : "N/A"}',
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- SINGLE CONTINUOUS GRADIENT HEADER ----------
        // Drawn as ONE gradient Container spanning the frozen "Item" column
        // and the scrollable columns together, instead of two separate
        // gradient boxes side by side — two independently-sized gradients
        // each normalize to their own bounds and produce a visible seam at
        // the boundary. Same fix as LeadBottomScreen._buildHeader for its
        // frozen-column + scrollable table.
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, Color(0xFF2D3748)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
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
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerHorizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalTableWidth - 250,
                      child: _buildScrollableHeader(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---------- BODY ----------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: Item Name
            SizedBox(
              width: 250,
              child: Column(
                children: [
                  ..._ctrl.cartItems.asMap().entries.map((e) {
                    return Container(
                      height: ProductReturnDialogContent._fixedRowHeight,
                      width: double.infinity,
                      color:
                          e.key.isEven ? const Color(0xFFF8FAFC) : Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          // Product Name - takes available space
                          Expanded(
                            child: ProductNameWithTax(
                              productName: '${e.value.productName ?? '-'}',
                              variationName: '${e.value.variationName ?? '-'}',
                              isInclTax: e.value.inclTax == "incl_tax",
                              maxWidth: isPhonePortrait(context)
                                  ? fullScreenWidth(context) * 0.4
                                  : fullScreenWidth(context) * 0.2,
                              style: TextStyle(fontSize: 14),
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
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _bodyHorizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalTableWidth - 250,
                      child: Column(
                        children: [
                          ..._ctrl.cartItems.asMap().entries.map((e) {
                            final cart = e.value;
                            final productReturnRowController =
                                ProductReturnRowController(cart);
                            _ctrl.rowControllers
                                .add(productReturnRowController);
                            File? selectedImage;

                            return Container(
                              height:
                                  ProductReturnDialogContent._fixedRowHeight,
                              color: e.key.isEven
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white,
                              child: Row(
                                children: [
                                  _col(formatAmount(cart.price), colUnit),
                                  _col(
                                      '${cart.pieces ?? 0} (${cart.quantity ?? 0} ${cart.packType ?? ''})'
                                          .trim(),
                                      colQty),
                                  _col(
                                    formatAmount(cart.totalPrice),
                                    colAmt,
                                    align: TextAlign.right,
                                  ),

                                  _col(
                                    formatAmount(
                                        cart.discountAmount), // e.g., ₹ 100.00
                                    colDisc,
                                    align: TextAlign.right,
                                  ),

                                  _col(
                                    formatAmount(cart.tax), // e.g., ₹ 270.00
                                    colTax,
                                    align: TextAlign.right,
                                  ),

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
                                        controller: productReturnRowController
                                            .damageCtrl,
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
                                        controller: productReturnRowController
                                            .returnCtrl,
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
                      controller: _bodyHorizontalController,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /* --------------------------------------------------------------
     Header helpers – background/gradient now lives on the single
     continuous Container in _buildReturnTable (see comment there), so
     these only provide the width/alignment/cell layout.
     -------------------------------------------------------------- */
  Widget _buildHeader1(Widget child, double width) => SizedBox(
        width: width,
        child: Center(child: child),
      );

  Widget _buildScrollableHeader() {
    return Row(
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
  //new one added//

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
          // Add a safety check for cart.suppliedQty
          final displayQty = (cart.suppliedQty ?? 0).toString();

          final info = _ctrl.returnInfo.value;

          // If no return info, just show the quantity
          if (info == null || info.aggregated.isEmpty) {
            return CustomText(
              content: displayQty,
              fontSize: 12,
              textAlign: align,
              overflow: TextOverflow.ellipsis,
            );
          }

          final hasPending =
              info.aggregated.any((a) => a.variationId == cart.variationId);

          if (!hasPending) {
            return CustomText(
              content: displayQty,
              fontSize: 12,
              textAlign: align,
              overflow: TextOverflow.ellipsis,
            );
          }

          final pendingQty = info.aggregated
                  .firstWhere(
                    (a) => a.variationId == cart.variationId,
                    orElse: () => Aggregated(variationId: '', pendingQty: 0),
                  )
                  .pendingQty ??
              0;

          final filtered = info.data
              .where((r) => r.variationId == cart.variationId)
              .toList();

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: CustomText(
                  content: displayQty,
                  fontSize: 12,
                  textAlign: align,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 20,
                height: 20,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.info_outline,
                      color: Colors.blue, size: 16),
                  tooltip: 'Pending: $pendingQty',
                  onPressed: () {
                    showPendingReturnsDialog(context, cart.productName ?? '',
                        cart.variationName ?? '', filtered);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void showPendingReturnsDialog(BuildContext context, String productName,
      String variationName, List<ReturnInfoData> filtered) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: PendingReturnsPopup(
            productName: productName, // Use parameter
            variationName: variationName, // Use parameter
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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Method',
                            style: TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _selectMethodOption(
                        context: context,
                        icon: EneftyIcons.camera_outline,
                        label: 'Camera',
                        onTap: () async {
                          final file = await pickImages(
                            ImageSource.camera,
                          );
                          if (file != null) onPicked(file);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 10),
                      _selectMethodOption(
                        context: context,
                        icon: EneftyIcons.gallery_bold,
                        label: 'Gallery',
                        onTap: () async {
                          final file = await pickImages(
                            ImageSource.gallery,
                          );
                          if (file != null) onPicked(file);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload, size: 16, color: primaryColor),
            const SizedBox(width: 4),
            if (currentFile != null)
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }

  /// Modern rounded list-item row used by the "Select Method" picker above.
  /// Purely presentational — the tap callback passed in is whatever the
  /// caller already wired up (camera/gallery picking), unchanged.
  Widget _selectMethodOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
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
    final List<Widget> chips = [];

    for (var t in order.tax!) {
      final amount = double.tryParse(t.taxAmount.toString()) ?? 0.0;
      taxTotal += amount;

      final taxName = t.taxName ?? '';
      final taxRate = t.tax ?? '';

      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          '$taxName - $taxRate% : ${formatAmount(amount)}',
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        const Text(
          'TAX',
          style: TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        ...chips,
        Text(
          'Total: ${formatAmount(taxTotal)}',
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildTotals() {
    final order = _ctrl.orderData.value!;

    final double orderTotal =
        double.tryParse(order.orderTotal.toString()) ?? 0.0;
    final double subtotal = double.tryParse(order.subTotal.toString()) ?? 0.0;
    final double discount = 0.0;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _totalRow('Subtotal', formatAmount(subtotal)),
            const SizedBox(height: 6),
            _totalRow('Discount', formatAmount(discount)),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            _totalRow(
              'Total',
              formatAmount(orderTotal),
              isEmphasis: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isEmphasis = false}) {
    final labelStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: isEmphasis ? 13.5 : 12.5,
      fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
      color: isEmphasis ? const Color(0xFF0F172A) : const Color(0xFF64748B),
    );
    final valueStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: isEmphasis ? 15 : 12.5,
      fontWeight: FontWeight.w700,
      color: isEmphasis ? primaryColor : const Color(0xFF0F172A),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    final order = _ctrl.orderData.value!;

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

    String paymentMethodText;

    if (order.paymentStatus == 0) {
      paymentMethodText = '';
    } else {
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

    Color statusColor;
    switch (order.paymentStatus) {
      case 1:
        statusColor = const Color(0xFF059669); // paid - green
        break;
      case 3:
        statusColor = const Color(0xFF2563EB); // partially paid - blue
        break;
      case 0:
        statusColor = const Color(0xFFD97706); // pending - amber
        break;
      default:
        statusColor = const Color(0xFF64748B); // unknown - grey
    }

    // ---- Final UI ----
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            paymentStatusText,
            style: TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
        if (paymentMethodText.isNotEmpty)
          Text(
            'Paid via $paymentMethodText',
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
      ],
    );
  }
}

// At the bottom of the file (replace the old function)
