//Cart Dialog

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/bulk/model/bulk_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/dialog/dialogs.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/calculate_discount.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_heading.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_rowcontent.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/dialogue_heading_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_totalamount_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_cart_button.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_header_container.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/widgets/variant_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/controller/customer_credit_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CartDialogue extends StatefulWidget {
  bool? active;
  int cartItemCount;
  ProductsController productsController;
  CustomerAndOrderController? customerOrderController;
  bool isDashboard;
  final bool isFromCalender;
  final bool isDirectDialogue;
  final bool isFromOrder;
  final bool? isFromCustomerDach;
  final VoidCallback? onContinueShopping;
  String? customerId;
  final VoidCallback? onDraftUpdated; // Add callback for draft updates
  CartDialogue({
    super.key,
    this.active,
    required this.cartItemCount,
    required this.productsController,
    required this.isDashboard,
    this.isFromCalender = false,
    this.isDirectDialogue = false,
    this.isFromOrder = false,
    this.customerOrderController,
    this.onContinueShopping,
    this.isFromCustomerDach = false,
    this.customerId,
    this.onDraftUpdated, // Add callback parameter
  });
  @override
  State<CartDialogue> createState() => CartDialogueState();
}

class CartDialogueState extends State<CartDialogue> {
  void refreshCart() {
    if (mounted) {
      setState(() {});
      try {
        final cid = widget.productsController.selectedCustomerId.value;
        if (cid.isNotEmpty) {
          final cusProvider =
              Provider.of<CustomersProvider>(context, listen: false);
          cusProvider.updateCartCount(cid);
        }
      } catch (_) {}
    }
  }

  late RxBool useCredit; // Reactive checkbox state
  late var customerCredit;
  late var currentCustomerCredit;

  // Current available credit
  List<int> quantities = [];
  List<int> preorderQuantities = [];
  List<int> draftQuantity = [];
  double orderSubtotal = 0.0;
  double orderTax = 0.0;
  double orderTaxx = 0.0;
  double totalDiscount = 0.0;
  double preorderSubtotal = 0.0;
  double preorderTax = 0.0;
  double orderTaxe = 0.0;
  double totalDiscountPreorder = 0.0;
  bool isOrder = true;
  String? _selectedValue;
  String? _dropdownValue;
  int? paymentType;
  final List<String> _options = [
    'Sale Order',
    "Quick Sale",
    'Booking',
    'Estimate'
  ];
  List<String> filteredOptions = [];
  CustomerAndOrderController customeController =
      Get.find<CustomerAndOrderController>();
  ProductsController productController = Get.find<ProductsController>();
  CustomerCreditController customerCreditController =
      Get.find<CustomerCreditController>();
  final subscriptionController = Get.find<SubscriptionController>();

  final TextEditingController totalQuickController = TextEditingController();
  final TextEditingController chequeOrTransactionNumberController =
      TextEditingController();
  final TextEditingController cashRemarkController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  bool _isLoading = true;
  bool isDraft = true;

  final ScrollController _mainVerticalScrollController = ScrollController();
  final ScrollController _mainHorizontalScrollController = ScrollController();
  final ScrollController _preVerticalScrollController = ScrollController();
  final ScrollController _preHorizontalScrollController = ScrollController();

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  ScrollController _scrollController3 = ScrollController();
  ScrollController _scrollController4 = ScrollController();
  final CustomerCreditController _customercreditctrl =
      Get.find<CustomerCreditController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final customerCreditCtrl = Get.find<CustomerCreditController>();
  late List<int> localCounts;
  @override
  void initState() {
    super.initState();
    useCredit = false.obs;
    customerCredit = 0.0;

    currentCustomerCredit = _customercreditctrl.customerCredit.value;
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
    _scrollController4 = ScrollController();

    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
    });

    _scrollController3.addListener(() {
      if (_scrollController4.hasClients &&
          _scrollController3.position.pixels !=
              _scrollController4.position.pixels) {
        _scrollController4.jumpTo(_scrollController3.position.pixels);
      }
    });

    _scrollController4.addListener(() {
      if (_scrollController3.hasClients &&
          _scrollController4.position.pixels !=
              _scrollController3.position.pixels) {
        _scrollController3.jumpTo(_scrollController4.position.pixels);
      }
    });

    localCounts =
        List<int>.filled(widget.productsController.cartItems.length, 0);

    // _loadCartItems();
    Provider.of<CustomersProvider>(context, listen: false).getCartItemCounts(
        widget.customerId ??
            widget.productsController.selectedCustomerId.value);
    calculateAmounts();
    _selectedValue = isOrder ? _options[0] : _options[2];
    setOptions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartItems();
      // orderTaxx = Utils().calculateTotalTax(widget.productsController.orderItems);
      // You likely need setState to update the UI with the calculated tax
      // setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload cart items whenever screen becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartItems();
    });
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    _scrollController4.dispose();
    super.dispose();
  }

  void setOptions() {
    setState(() {
      filteredOptions = isOrder
          ? ['Sale Order', 'Quick Sale', 'Estimate']
          : ['Booking', 'Estimate'];
    });
  }

  void _loadCartItems() async {
    try {
      final isOnline = await ConnectivityService().isOnline();
      final customerId = widget.customerId ??
          widget.productsController.selectedCustomerId.value;
      final bool isDraftView = widget.isFromCustomerDach == true && isOnline;

      if (isDraftView) {
        if (!isOnline) {
          var offlineDraftsBox = await Hive.openBox('offlineDrafts');
          List<dynamic> drafts =
              offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
          final draft = drafts.firstWhere(
            (d) => d['customer_id'] == customerId,
            orElse: () => null,
          );

          if (draft != null && draft['details'] != null) {
            final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
            final List details = draft['details'];
            final draftBox = Hive.box<CartItem>('draftBox');

            final keysToRemove = draftBox.keys.where((key) {
              final item = draftBox.get(key);
              return item != null && item.customerId == customerId;
            }).toList();

            for (var key in keysToRemove) {
              draftBox.get(key);
              await draftBox.delete(key);
            }

            for (var detail in details) {
              final String packTypeStr = (detail['packType'] ??
                  detail['packtype'] ??
                  detail['pack_type'] ??
                  '') as String;
              final bool isBulkDraft = (packTypeStr == 'Bulk') ||
                  (detail['bulk_id'] != null &&
                      detail['bulk_id'].toString().isNotEmpty &&
                      detail['bulk_id'].toString() != 'null') ||
                  (detail['is_bulk'] == 1 ||
                      detail['is_bulk'] == true ||
                      detail['is_bulk'] == '1');

              final num? bulkDiscountPct = isBulkDraft
                  ? (num.tryParse(detail['bulk_discount']?.toString() ?? '') ??
                      num.tryParse(detail['discount_percentage']?.toString() ?? '') ??
                      num.tryParse(detail['bulk_discount_percentage']?.toString() ?? '') ??
                      0)
                  : 0;

              final num? bulkDiscountAmt = isBulkDraft
                  ? ((bulkDiscountPct != null && bulkDiscountPct > 0)
                      ? 0
                      : (num.tryParse(detail['bulk_discount_amount']?.toString() ?? '') ??
                          num.tryParse(detail['discount_amount']?.toString() ?? '') ??
                          0))
                  : 0;

              final num? bulkTaxVal = isBulkDraft
                  ? (num.tryParse(detail['bulk_tax']?.toString() ?? '') ??
                      num.tryParse(detail['cat_tax']?.toString() ?? '') ??
                      0)
                  : 0;

              final cartItem = CartItem(
                detail: Detail(
                  productId: detail['product_id'],
                  variationId: detail['variant_id'],
                  sellPrice: detail['price'],
                  discount: isBulkDraft ? 0 : detail['discount'],
                  count: (detail['quantity'] as num?)?.toDouble() ?? 0,
                  pieces: int.tryParse(detail['pack'] ?? '0'),
                  variationName: detail['variant_name'],
                  saleBy: packTypeStr,
                  stock: detail['stock'] ?? 0,
                  unitType: detail['unitType'],
                  packtype: packTypeStr,
                  productName: detail['product_name'] ?? detail['variant_name'],
                  tax: detail['tax'],
                  inclTax: detail['incl_tax'],
                  bulkId: isBulkDraft ? detail['bulk_id']?.toString() : null,
                  bulkDiscountAmount: bulkDiscountAmt,
                  bulkDiscount: bulkDiscountPct,
                  bulkTax: bulkTaxVal,
                ),
                productName: detail['product_name'] ?? detail['variant_name'] ?? '',
                totalPrice:
                    double.tryParse(detail['price']?.toString() ?? '0') ?? 0,
                isPack: packTypeStr == 'Pack' || packTypeStr == 'Bulk',
                customerId: customerId,
                salesmanId: salesmanId,
                catId: 0,
                isPromo: false,
                CustomerDiscount: 0.0,
                taxAmount: (num.tryParse(detail['tax_amount']?.toString() ?? '') ??
                        num.tryParse(detail['total_tax']?.toString() ?? '') ??
                        0)
                    .toDouble(),
              );
              await draftBox.add(cartItem);
            }
          }
        }
      }

      widget.productsController.cartItems =
          await CartDatabaseManager().getCartItems(customerId);

      if (isOnline) {
        await ApiWorker().fetchDiscounts(
            SessionHelper.loginSavedData?.company_id ?? 0,
            SessionHelper.loginSavedData?.salesmanId ?? '');
      }

      final discountBox =
          await Hive.openBox<CustomerDiscountModel>('discounts');
      final discountData = discountBox.values.firstWhere(
        (discount) => discount.customerId == customerId,
        orElse: () => CustomerDiscountModel(),
      );

      for (final item in widget.productsController.cartItems) {
        final bool isBulkItem = (item.detail.bulkId != null &&
                item.detail.bulkId!.isNotEmpty) ||
            (item.detail.packtype == 'Bulk') ||
            (item.detail.saleBy == 'Bulk') ||
            (item.isPack == true &&
                item.detail.bulkDiscount != null &&
                item.detail.bulkDiscount! > 0) ||
            (item.detail.bulkDiscountAmount != null &&
                item.detail.bulkDiscountAmount! > 0);

        if (isBulkItem) {
          item.CustomerDiscount = 0.0;
        } else if (isOnline) {
          double effectiveSellingPrice =
              double.tryParse(item.detail.sellPrice ?? '0') ?? 0;
          num itemCount = item.detail.count > 0 ? item.detail.count : 1;
          double discountSellingPrice = (item.isPack == true ||
                  item.detail.packtype == 'Pack')
              ? (effectiveSellingPrice * (item.detail.pieces ?? 1) * itemCount)
              : (effectiveSellingPrice * itemCount);

          double newCustomerDiscount = 0.0;
          if (discountData.discounts != null) {
            for (var discount in discountData.discounts!) {
              if (discount.categoriesId == item.catId.toString() &&
                  discountSellingPrice >
                      (double.tryParse(discount.value ?? '0') ?? 0)) {
                newCustomerDiscount =
                    double.tryParse(discount.discount ?? '0') ?? 0.0;
                break;
              }
            }
          }
          item.CustomerDiscount = newCustomerDiscount;
        }

        // 1. Calculate Base Sell Amount (Original Pre-Discount & Pre-Edit)
        double originalUnitPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '') ?? 0.0;
        if (originalUnitPrice <= 0.0) {
          originalUnitPrice =
              double.tryParse(item.detail.price?.toString() ?? '') ?? 0.0;
        }
        int qtyFactor = (item.isPack == true || item.detail.packtype == 'Pack')
            ? (item.detail.pieces?.toInt() ?? 1)
            : 1;

        final double? apiSellingPackPrice = (item.isPack == true ||
                item.detail.packtype == 'Pack')
            ? (double.tryParse(
                item.detail.sellingPackPrice?.toString() ?? ''))
            : null;

        final double originalBaseSellAmount = (apiSellingPackPrice != null && apiSellingPackPrice > 0)
            ? apiSellingPackPrice
            : originalUnitPrice * qtyFactor;

        double currentBaseSellAmount = originalBaseSellAmount;
        if (item.detail.displayPrice != null) {
          final double editedUnitPrice =
              double.tryParse(item.detail.displayPrice!) ?? originalUnitPrice;
          currentBaseSellAmount = (apiSellingPackPrice != null && apiSellingPackPrice > 0)
              ? (double.tryParse(item.detail.displayPrice!) ?? originalBaseSellAmount)
              : editedUnitPrice * qtyFactor;
        }

        // 2. Get Quantity
        double productQuantity = item.detail.count.toDouble();

        // 3. Edit-price discount (salesman price override)
        double editPriceDiscountAmount = 0.0;
        if (item.detail.displayPrice != null) {
          final double diff = originalBaseSellAmount - currentBaseSellAmount;
          if (diff > 0) {
            editPriceDiscountAmount = diff * productQuantity;
          }
        }

        // 4. Get Discount Percentages
        final bool isBulk = (item.detail.bulkId != null && item.detail.bulkId!.isNotEmpty) ||
            (item.detail.packtype == 'Bulk') ||
            (item.isPack == true && item.detail.bulkDiscount != null && item.detail.bulkDiscount! > 0) ||
            (item.detail.bulkDiscountAmount != null && item.detail.bulkDiscountAmount! > 0);

        final bool isPromoItem = (item.isPromo == true) && !isBulk;

        double customerDiscount =
            (!isBulk && item.CustomerDiscount != null && item.CustomerDiscount! > 0)
                ? item.CustomerDiscount!
                : 0.0;

        num tieredDiscount =
            (isPromoItem && item.tieredDiscount != null && item.tieredDiscount! > 0)
                ? item.tieredDiscount!
                : 0;
        num bogoDiscount = (isPromoItem && item.bogoDiscount != null && item.bogoDiscount! > 0)
            ? item.bogoDiscount!
            : 0;
        num flatDiscount = (isPromoItem && item.flatDiscount != null && item.flatDiscount! > 0)
            ? item.flatDiscount!
            : 0;
        num? bulkDiscount =
            (item.detail.bulkDiscount != null && item.detail.bulkDiscount! > 0)
                ? item.detail.bulkDiscount
                : 0;

        double totalDiscountPercent =
            customerDiscount + tieredDiscount + bogoDiscount + (bulkDiscount ?? 0);

        // 5. Calculate Total Discount Amount
        double percentageDiscountAmount =
            (originalBaseSellAmount * productQuantity) * (totalDiscountPercent / 100.0);

        // Only apply flat bulkDiscountAmount if bulk percentage discount is NOT already applied
        double bulkDiscountAmt = ((bulkDiscount ?? 0) > 0)
            ? 0.0
            : (item.detail.bulkDiscountAmount ?? 0).toDouble();

        double totalDiscountAmount =
            percentageDiscountAmount + bulkDiscountAmt + editPriceDiscountAmount;

        item.totalDiscountAmount = totalDiscountAmount;

        // 6. Calculate Price After Discount
        double priceAfterDiscount =
            (originalBaseSellAmount * productQuantity) - totalDiscountAmount;
        if (priceAfterDiscount < 0) priceAfterDiscount = 0.0;

        // 7. Calculate Tax strictly from priceAfterDiscount
        double bulkTaxPercentage = (item.detail.bulkTax ?? 0).toDouble();
        double catTaxVal = (item.catTax ?? 0).toDouble();
        if (catTaxVal == 0 &&
            item.detail.productId != null &&
            item.detail.productId!.isNotEmpty) {
          catTaxVal = getStoredTaxFromCache(item.detail.productId!);
          if (catTaxVal > 0) {
            item.catTax = catTaxVal;
          }
        }
        double taxPercentage = bulkTaxPercentage > 0
            ? bulkTaxPercentage
            : catTaxVal;

        double calculatedTax = 0.0;
        if (item.detail.inclTax == "N.A") {
          calculatedTax = 0.0;
          item.taxAmount = 0.0;
        } else if (taxPercentage > 0) {
          calculatedTax = priceAfterDiscount * (taxPercentage / 100);
          item.taxAmount = calculatedTax;
        } else {
          double totalRawTax =
              (item.detail.tax ?? 0).toDouble() * productQuantity * qtyFactor;
          calculatedTax = totalRawTax * (1 - (totalDiscountPercent / 100.0));
          item.taxAmount = calculatedTax;
        }

        // 8. Final Price Logic
        if (item.detail.inclTax == "incl_tax" || item.detail.inclTax == "N.A") {
          item.finalPrice = priceAfterDiscount;
          item.totalPrice = (originalBaseSellAmount * productQuantity);
        } else {
          item.finalPrice = priceAfterDiscount + calculatedTax;
          item.totalPrice = (originalBaseSellAmount * productQuantity) + calculatedTax;
        }     
      }

      await setCartToOrderAndPreorder();

      // Helper to process items and set taxAmount
      void processItems(List<CartItem> items) {
        for (var item in items) {
          item.isChecked = true; // Required by your fold function

          final double sellPrice = item.detail.displayPrice != null
              ? (double.tryParse(item.detail.displayPrice!) ??
                  (double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0))
              : (double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0);
          final double effectiveSellPrice = sellPrice > 0.0
              ? sellPrice
              : (double.tryParse(item.detail.price?.toString() ?? '0') ?? 0.0);
          final int qtyFactor = (item.isPack == true || item.detail.packtype == 'Pack')
              ? (item.detail.pieces?.toInt() ?? 1)
              : 1;

          final double? apiSellingPackPrice = (item.isPack == true ||
                  item.detail.packtype == 'Pack')
              ? (double.tryParse(item.detail.sellingPackPrice?.toString() ?? ''))
              : null;

          final double baseSellAmount = (apiSellingPackPrice != null && apiSellingPackPrice > 0)
              ? apiSellingPackPrice
              : effectiveSellPrice * qtyFactor;

          final double count = item.detail.count.toDouble();
          final inclTax = item.detail.inclTax;

          // 2. Calculate Total Price (Base Price + Tax if not inclusive)
          double basePrice = count * baseSellAmount;
          if (inclTax != 'incl_tax' && inclTax != 'N.A') {
            item.totalPrice = basePrice + (item.taxAmount ?? 0.0);
          } else {
            item.totalPrice = basePrice;
          }
        }
      }

      processItems(widget.productsController.orderItems);
      processItems(widget.productsController.preorderItems);

      setState(() {
        quantities = List.generate(
            widget.productsController.cartItems.length, (index) => 1);

        print('orderTaxe calculated in setState:${orderTaxe}');
        preorderTax =
            Utils().calculateTotalTax(widget.productsController.preorderItems);

        orderSubtotal =
            Utils().calculateSubtotal(widget.productsController.orderItems);
        preorderSubtotal =
            Utils().calculateSubtotal(widget.productsController.preorderItems);
        orderTaxe =
            Utils().calculateTotalTax(widget.productsController.orderItems);
        // orderTaxe = widget.productsController.orderItems.fold(
        //   0.0,
        //   (sum, item) {
        //     // 1. If unchecked, skip
        //     if (item.isChecked != true) return sum;

        //     // 2. Get the base Total Price
        //     double totalPrice = item.totalPrice ?? 0.0;

        //     // 3. Determine Discount Amount (Replicating your logic)
        //     double totalDiscountAmount;

        //     // Check if backend value exists first
        //     if (item.totalDiscountAmount != null &&
        //         item.totalDiscountAmount! > 0) {
        //       totalDiscountAmount = item.totalDiscountAmount!;
        //     } else {
        //       // Otherwise calculate it: (CustomerDiscount + TieredDiscount)
        //       double customerDisc = item.CustomerDiscount ?? 0.0;
        //       num tieredDisc = item.tieredDiscount ?? 0;
        //       double totalDiscPercent = customerDisc + tieredDisc;

        //       totalDiscountAmount = totalPrice * (totalDiscPercent / 100.0);
        //     }

        //     // 4. Calculate Final Price (Price - Discount)
        //     double finalPrice = totalPrice - totalDiscountAmount;

        //     // Safety check: ensure price isn't negative
        //     if (finalPrice < 0) finalPrice = 0;

        //     // 5. Calculate Tax Amount: Final Price * (TaxPercentage / 100)
        //     double taxPercentage = (item.catTax ?? 0).toDouble();
        //     double itemTaxAmount = finalPrice * (taxPercentage / 100);

        //     return sum + itemTaxAmount;
        //   },
        // );
        totalDiscountPreorder = Utils()
            .calculateTotalDiscount(widget.productsController.preorderItems);
        totalDiscount =
            widget.productsController.orderItems.fold(0.0, (sum, item) {
          if (item.isChecked != true) return sum;
          return sum + (item.totalDiscountAmount ?? 0.0);
        });

        _isLoading = false;
      });

      if (_selectedValue == null) {
        if (widget.productsController.orderItems.isNotEmpty) {
          isOrder = true;
          _selectedValue = _options[0];
        } else if (widget.productsController.preorderItems.isNotEmpty) {
          isOrder = false;
          _selectedValue = _options[2];
        }
      }
      setOptions();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

//   void _loadCartItems() async {
//     try {
//       final isOnline = await ConnectivityService().isOnline();

//       final customerId = widget.customerId ??
//           widget.productsController.selectedCustomerId.value;
//       final bool isDraftView = widget.isFromCustomerDach == true && isOnline;

//       if (isDraftView) {
//         if (!isOnline) {
//           var offlineDraftsBox = await Hive.openBox('offlineDrafts');
//           List<dynamic> drafts =
//               offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
//           final draft = drafts.firstWhere(
//             (d) => d['customer_id'] == customerId,
//             orElse: () => null,
//           );

//           if (draft != null && draft['details'] != null) {
//             final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
//             final List details = draft['details'];
//             final draftBox = Hive.box<CartItem>('draftBox');

//             final keysToRemove = draftBox.keys.where((key) {
//               final item = draftBox.get(key);
//               return item != null && item.customerId == customerId;
//             }).toList();

//             for (var key in keysToRemove) {
//               draftBox.get(key);
//               await draftBox.delete(key);
//             }

//             for (var detail in details) {
//               final cartItem = CartItem(
//                 detail: Detail(
//                   productId: detail['product_id'],
//                   variationId: detail['variant_id'],
//                   sellPrice: detail['price'],
//                   discount: detail['discount'],
//                   count: (detail['quantity'] as num?)?.toDouble() ?? 0,
//                   pieces: int.tryParse(detail['pack'] ?? '0'),
//                   variationName: detail['variant_name'],
//                   saleBy: detail['packType'],
//                   stock: detail['stock'] ?? 0,
//                   unitType: detail['unitType'],
//                 ),
//                 productName: detail['variant_name'] ?? '',
//                 totalPrice:
//                     double.tryParse(detail['price']?.toString() ?? '0') ?? 0,
//                 isPack: detail['packType'] == 'Pack',
//                 customerId: customerId,
//                 salesmanId: salesmanId,
//                 catId: 0,
//               );
//               await draftBox.add(cartItem);
//             }
//           }
//         }
//       }

//       // --- End offline draft loading ---

//       widget.productsController.cartItems = await CartDatabaseManager()
//           .getCartItems(customerId, draftsOnly: isDraftView);
//       for (final item in widget.productsController.cartItems) {
//         calculateItemDiscounts(item);
//         // print('calculate discount called:${calculateItemDiscounts(item)}');
//       }

//       await setCartToOrderAndPreorder();

//       for (var item in widget.productsController.cartItems) {
//         item.isChecked = true;
//         final count = item.detail.count;
//         final pieces = item.detail.pieces ?? 1;
//         final sellPrice =
//             double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
//         final tax = item.detail.tax?.toDouble() ?? 0.0;
//         final inclTax = item.detail.inclTax;
//         if (item.isPack == true || item.detail.packtype == 'Pack') {
//           item.totalPrice = (count * pieces * sellPrice);
//         } else {
//           item.totalPrice = (count * sellPrice);
//         }
//         if (inclTax != 'incl_tax') {
//           if (item.isPack == true || item.detail.packtype == 'Pack') {
//             item.totalPrice += (count * pieces * tax);
//           } else {
//             item.totalPrice += (count * tax);
//           }
//         }
//       }
//       for (var item in widget.productsController.preorderItems) {
//         for (final item in widget.productsController.preorderItems) {
//           calculateItemDiscounts(item);
//           // print('calculate discount called in second');
//         }

//         item.isChecked = true;
//         final count = item.detail.count;
//         final pieces = item.detail.pieces ?? 1;
//         final sellPrice =
//             double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
//         final tax = item.detail.tax?.toDouble() ?? 0.0;
//         final inclTax = item.detail.inclTax;
//         if (item.isPack == true || item.detail.packtype == 'Pack') {
//           item.totalPrice = (count * pieces * sellPrice);
//         } else {
//           item.totalPrice = (count * sellPrice);
//         }
//         if (inclTax != 'incl_tax') {
//           if (item.isPack == true || item.detail.packtype == 'Pack') {
//             item.totalPrice += (count * pieces * tax);
//           } else {
//             item.totalPrice += (count * tax);
//           }
//         }
//       }
//       orderSubtotal =
//           widget.productsController.orderItems.fold(0.0, (sum, item) {
//         return item.isChecked! ? sum + (item.totalPrice) : sum;
//       });
//       print('subTotalll:$orderSubtotal');
//       preorderSubtotal =
//           widget.productsController.preorderItems.fold(0.0, (sum, item) {
//         return item.isChecked! ? sum + (item.totalPrice) : sum;
//       });
//       orderTaxx = widget.productsController.orderItems.fold(
//   0.0,
//   (sum, item) {
//     // 1. If unchecked, skip
//     if (item.isChecked != true) return sum;

//     // 2. Get the base Total Price
//     double totalPrice = item.totalPrice ?? 0.0;

//     // 3. Determine Discount Amount (Replicating your logic)
//     double totalDiscountAmount;

//     // Check if backend value exists first
//     if (item.totalDiscountAmount != null && item.totalDiscountAmount! > 0) {
//       totalDiscountAmount = item.totalDiscountAmount!;
//     } else {
//       // Otherwise calculate it: (CustomerDiscount + TieredDiscount)
//       double customerDisc = item.CustomerDiscount ?? 0.0;
//       num tieredDisc = item.tieredDiscount ?? 0;
//       double totalDiscPercent = customerDisc + tieredDisc;

//       totalDiscountAmount = totalPrice * (totalDiscPercent / 100.0);
//     }

//     // 4. Calculate Final Price (Price - Discount)
//     double finalPrice = totalPrice - totalDiscountAmount;

//     // Safety check: ensure price isn't negative
//     if (finalPrice < 0) finalPrice = 0;

//     // 5. Calculate Tax Amount: Final Price * (TaxPercentage / 100)
//     double taxPercentage = (item.catTax ?? 0).toDouble();
//     double itemTaxAmount = finalPrice * (taxPercentage / 100);

//     return sum + itemTaxAmount;
//   },
// );
//       // widget.productsController.totalOrderTax.value = orderTaxx;

// //
//       // orderTaxx =
//       //       Utils().calculateTotalTax(widget.productsController.orderItems);
//       preorderTax = widget.productsController.preorderItems.fold(
//         0.0,
//         (sum, item) {
//           if (item.isChecked == true) {
//             final double itemTax = item.detail.tax?.toDouble() ?? 0.0;
//             if (item.isPack == true || item.detail.packtype == "Pack") {
//               return sum +
//                   (itemTax * (item.detail.pieces ?? 1) * (item.detail.count));
//             } else {
//               return sum + (itemTax * (item.detail.count));
//             }
//           } else {
//             return 0;
//           }
//         },
//       );

//       totalDiscountPreorder = widget.productsController.preorderItems.fold(
//         0.0,
//         (sum, item) {
//           if (item.isChecked != true) return sum;

//           final double sellPrice =
//               double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
//           final double discountPercentage =
//               double.tryParse(item.detail.discount?.toString() ?? '0') ?? 0.0;
//           final double? maxDiscount = item.detail.maxDiscount?.toDouble();

//           final double totalQuantity =
//               (item.isPack == true || item.detail.packtype == 'Pack')
//                   ? (item.detail.pieces?.toDouble() ?? 1) *
//                       item.detail.count.toDouble()
//                   : item.detail.count.toDouble();

//           final double totalPrice = sellPrice * totalQuantity;

//           double discountAmount = totalPrice * (discountPercentage / 100);

//           if (maxDiscount != null &&
//               maxDiscount > 0 &&
//               discountAmount > maxDiscount) {
//             discountAmount = maxDiscount;
//           }

//           return sum + discountAmount;
//         },
//       );
//       setState(() {
//         quantities = List.generate(
//             widget.productsController.cartItems.length, (index) => 1);
//         _isLoading = false;
//         widget.productsController.orderItems =
//             widget.productsController.orderItems;
//         widget.productsController.preorderItems =
//             widget.productsController.preorderItems;
//         orderTaxx =
//             Utils().calculateTotalTax(widget.productsController.orderItems);
//         preorderSubtotal =
//             Utils().calculateSubtotal(widget.productsController.preorderItems);
//         preorderTax =
//             Utils().calculateTotalTax(widget.productsController.preorderItems);
//       });
//       if (widget.productsController.orderItems.isNotEmpty) {
//         isOrder = true;
//         _selectedValue = _options[0];
//       } else if (widget.productsController.preorderItems.isNotEmpty) {
//         isOrder = false;
//         _selectedValue = _options[2];
//       }
//       setOptions();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

  Future<void> setCartToOrderAndPreorder() async {
    List<CartItem> orderItems = [];
    List<CartItem> preorderItems = [];

    for (var item in widget.productsController.cartItems) {
      if ((item.detail.stock ?? 0) > 0) {
        orderItems.add(item);
      } else {
        preorderItems.add(item);
      }
    }

    setState(() {
      widget.productsController.orderItems = orderItems;
      widget.productsController.preorderItems = preorderItems;
    });
  }

  bool _needsRefresh = true;
  @override
  Widget build(BuildContext context) {
    if (_needsRefresh) {
      _needsRefresh = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCartItems();
      });
    }
    if (_isLoading) {
      return const Center(
        child: SpinKitFadingCube(
          color: primaryColor,
          size: 20.0,
        ),
      );
    }
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;
    final bool isLandscape = width > 750 && width > height;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 20 : 10,
        vertical: isLandscape ? 16 : 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double availableHeight = constraints.maxHeight;
          double fontSize = availableWidth / 55;
          if (fontSize < 11) fontSize = 11;
          if (fontSize > 15) fontSize = 15;
          double rowHeight = 52.0;

          if (isLandscape) {
            // === MODERN SPLIT-VIEW FOR TABLET / DESKTOP LANDSCAPE ===
            return SizedBox(
              width: width * 0.94,
              height: height * 0.92,
              child: Column(
                children: [
                  _buildHeaderSection(height, width),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // LEFT PANEL (66%): Tabs + Scrollable Products Table
                        Expanded(
                          flex: 66,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTabSwitcherSection(),
                              const SizedBox(height: 6),
                              Expanded(
                                child: _buildItemsList(
                                  context: context,
                                  availableWidth: availableWidth * 0.66,
                                  fontSize: fontSize,
                                  rowHeight: rowHeight,
                                  isLandscape: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // VERTICAL DIVIDER
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xFFE2E8F0),
                        ),
                        // RIGHT PANEL (34%): Sticky Order Summary & Actions Card
                        Expanded(
                          flex: 34,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: _buildSummaryAndActions(
                              context: context,
                              isLandscape: true,
                              width: width,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // === RESPONSIVE SINGLE-COLUMN FOR PORTRAIT ===
            return SizedBox(
              width: width * 0.96,
              height: height * 0.88,
              child: Column(
                children: [
                  _buildHeaderSection(height, width),
                  const SizedBox(height: 6),
                  _buildTabSwitcherSection(),
                  const SizedBox(height: 6),
                  Expanded(
                    child: _buildItemsList(
                      context: context,
                      availableWidth: availableWidth,
                      fontSize: fontSize,
                      rowHeight: rowHeight,
                      isLandscape: false,
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildSummaryAndActions(
                      context: context,
                      isLandscape: false,
                      width: width,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeaderSection(double height, double width) {
    return GetBuilder<CustomerCreditController>(
      builder: (creditCtrl) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final customerId = widget.productsController.selectedCustomerId.value;
          if (customerId.isNotEmpty &&
              (creditCtrl.allCustomers.isEmpty ||
                  !creditCtrl.allCustomers
                      .any((c) => c.customerId == customerId))) {
            creditCtrl.fetchCustomerCredit(
              companyId: SessionHelper.loginSavedData?.company_id ?? 1,
              salesmanId: SessionHelper.loginSavedData?.salesmanId,
              searchedCustomerId: customerId,
            );
          }
        });

        final credit = creditCtrl.customerCredit.value;
        final isLoading = creditCtrl.isLoading.value;
        customerCredit = credit;
        return DialogueHedingWidget(
          height: height,
          width: width,
          title: 'My Cart'.tr,
          orderCount: widget.productsController.orderItems.length,
          preorderCount: widget.productsController.preorderItems.length,
          isOrder: isOrder,
          onTabChanged: (val) {
            setState(() {
              isOrder = val;
              _selectedValue = isOrder ? _options[0] : _options[2];
            });
            setOptions();
          },
          creditWidget: isLoading
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Loading...'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: credit > 0
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: credit > 0
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: credit > 0
                            ? const Color(0xFF059669)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Credit: '.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: credit > 0
                              ? const Color(0xFF047857)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        formatAmount(credit.toStringAsFixed(2)),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: credit > 0
                              ? const Color(0xFF059669)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTabSwitcherSection() {
    return const SizedBox.shrink();
  }

  Widget _buildItemsList({
    required BuildContext context,
    required double availableWidth,
    required double fontSize,
    required double rowHeight,
    required bool isLandscape,
  }) {
    if (isOrder) {
      if (widget.productsController.orderItems.isEmpty) {
        return Center(
          child: CustomText(
            content: 'Your cart is empty.'.tr,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        );
      }

      final productNames = widget.productsController.orderItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .map((item) => item.productName)
          .toSet()
          .toList();

      return RawScrollbar(
        controller: _mainVerticalScrollController,
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(8),
        thumbColor: const Color(0xFF5B50EC),
        notificationPredicate: (notification) => notification.depth == 1,
        child: RawScrollbar(
          controller: _mainHorizontalScrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(8),
          thumbColor: const Color(0xFF5B50EC),
          child: SingleChildScrollView(
            controller: _mainHorizontalScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SingleChildScrollView(
              controller: _mainVerticalScrollController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
          child: IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: availableWidth > 750 ? availableWidth : 750,
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: productNames.map((productName) {
                List<CartItem> groupedItems = widget
                    .productsController.orderItems
                    .where((item) =>
                        item.productName == productName &&
                        (item.detail.stock ?? 0) > 0)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildGroupedItems(
                    productName: productName,
                    groupedItems: groupedItems,
                    availableWidth: availableWidth,
                    fontSize: fontSize,
                    rowHeight: rowHeight,
                    context: context,
                    productQuantityManager: productQuantityManager,
                    deleteConfirmationDialogue: deleteConfirmationDialogue,
                    isPreOrder: false,
                    calCulateAmount: calculateAmounts,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ),
  ),
);
    } else {
      if (widget.productsController.preorderItems.isEmpty) {
        return Center(
          child: CustomText(
            content: 'No bookings items available.'.tr,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        );
      }

      final preorderNames = widget.productsController.preorderItems
          .where((item) => item.detail.stock == 0 || item.detail.stock == null)
          .map((item) => item.productName)
          .toSet()
          .toList();

      return RawScrollbar(
        controller: _preVerticalScrollController,
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(8),
        thumbColor: const Color(0xFF5B50EC),
        notificationPredicate: (notification) => notification.depth == 1,
        child: RawScrollbar(
          controller: _preHorizontalScrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(8),
          thumbColor: const Color(0xFF5B50EC),
          child: SingleChildScrollView(
            controller: _preHorizontalScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SingleChildScrollView(
              controller: _preVerticalScrollController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
          child: IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: availableWidth > 750 ? availableWidth : 750,
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: preorderNames.map((productName) {
                List<CartItem> groupedItems = widget
                    .productsController.preorderItems
                    .where((item) => item.productName == productName)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildGroupedItems(
                    productName: productName,
                    groupedItems: groupedItems,
                    availableWidth: availableWidth,
                    fontSize: fontSize,
                    rowHeight: rowHeight,
                    context: context,
                    productQuantityManager: productQuantityManager,
                    deleteConfirmationDialogue: deleteConfirmationDialogue,
                    isPreOrder: true,
                    calCulateAmount: calculateAmounts,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ),
  ),
);
    }
  }

  Widget _buildSummaryAndActions({
    required BuildContext context,
    required bool isLandscape,
    required double width,
  }) {
    final String cid = widget.productsController.selectedCustomerId.value;
    final double flatDisc =
        widget.productsController.flatDiscountByCustomer[cid] ?? 0.0;
    var customerCredit = _customercreditctrl.customerCredit.value ?? 0.0;

    const Color brandPurple = Color(0xFF5B50EC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLandscape)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: brandPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      size: 18, color: brandPurple),
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Summary'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: fontFamilyName,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

        // 1. FINANCIAL BREAKDOWN CARD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1.1 SUBTOTAL
              Builder(builder: (context) {
                final currentItems = isOrder
                    ? widget.productsController.orderItems
                    : widget.productsController.preorderItems;

                final double baseAmount = currentItems.fold(
                  0.0,
                  (sum, item) {
                    if (item.isChecked != true) return sum;

                    double originalUnitPrice =
                        double.tryParse(item.detail.sellPrice?.toString() ?? '') ?? 0.0;
                    if (originalUnitPrice <= 0.0) {
                      originalUnitPrice =
                          double.tryParse(item.detail.price?.toString() ?? '') ?? 0.0;
                    }

                    final int qtyFactor =
                        (item.detail.packtype == 'Pack' || item.isPack == true)
                            ? (item.detail.pieces?.toInt() ?? 1)
                            : 1;

                    final double? apiSellingPackPrice = (item.isPack == true ||
                            item.detail.packtype == 'Pack')
                        ? (double.tryParse(
                            item.detail.sellingPackPrice?.toString() ?? ''))
                        : null;

                    final double originalBaseSellAmount =
                        (apiSellingPackPrice != null && apiSellingPackPrice > 0)
                            ? apiSellingPackPrice
                            : originalUnitPrice * qtyFactor;

                    final double productQuantity = item.detail.count.toDouble();

                    return sum + (originalBaseSellAmount * productQuantity);
                  },
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.layers_outlined,
                              size: 20,
                              color: brandPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Subtotal'.tr,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: fontFamilyName,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatAmount(baseAmount),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        fontFamily: fontFamilyName,
                        color: brandPurple,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                );
              }),

              const Divider(height: 22, thickness: 1, color: Color(0xFFF1F5F9)),

              // 1.2 DISCOUNT
              Builder(builder: (context) {
                final currentItems = isOrder
                    ? widget.productsController.orderItems
                    : widget.productsController.preorderItems;

                final double totalDiscount = currentItems.fold(
                  0.0,
                  (sum, item) {
                    if (item.isChecked != true) return sum;
                    return sum + (item.totalDiscountAmount ?? 0.0);
                  },
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_offer_outlined,
                              size: 20,
                              color: brandPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Discount'.tr,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: fontFamilyName,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatAmount(totalDiscount),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        fontFamily: fontFamilyName,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                );
              }),

              const Divider(height: 22, thickness: 1, color: Color(0xFFF1F5F9)),

              // 1.3 FINAL AMOUNT & TAX BREAKDOWN LINE BELOW IT
              Builder(builder: (context) {
                final currentItems = isOrder
                    ? widget.productsController.orderItems
                    : widget.productsController.preorderItems;

                double baseAmount = currentItems.fold(
                  0.0,
                  (sum, item) {
                    if (item.isChecked != true) return sum;
                    return sum + (item.finalPrice ?? item.totalPrice ?? 0.0);
                  },
                );
                if (isOrder) {
                  baseAmount =
                      (baseAmount - flatDisc).clamp(0.0, double.infinity);
                }

                final double finalBeforeCredit =
                    baseAmount.clamp(0.0, double.infinity);
                final double payableAmount = useCredit.value
                    ? (finalBeforeCredit - customerCredit)
                        .clamp(0.0, double.infinity)
                    : finalBeforeCredit;

                final Map<String, double> taxPortions = {};
                final Map<String, double> taxRates = {};
                double totalTaxAmt = 0.0;

                for (final item in currentItems) {
                  if (item.isChecked != true) continue;
                  final double itemTax = item.taxAmount?.toDouble() ?? 0.0;
                  if (itemTax <= 0) continue;
                  totalTaxAmt += itemTax;

                  CategoryData? catData;
                  if (widget.productsController.categoryData.value.data !=
                      null) {
                    final allCats =
                        widget.productsController.categoryData.value.data!;
                    if (item.catId != null && item.catId! > 0) {
                      for (final c in allCats) {
                        if (c.id.toString() == item.catId.toString()) {
                          catData = c;
                          break;
                        }
                      }
                    }
                    if (catData == null &&
                        item.catTax != null &&
                        item.catTax! > 0) {
                      for (final c in allCats) {
                        if (c.categoryTax != null &&
                            c.categoryTax!.isNotEmpty) {
                          final double sum = c.categoryTax!.fold(0.0,
                              (s, t) => s + (t.tax ?? 0).toDouble());
                          if ((sum - item.catTax!).abs() < 0.01) {
                            catData = c;
                            break;
                          }
                        }
                      }
                    }
                  }

                  if (catData != null &&
                      catData.categoryTax != null &&
                      catData.categoryTax!.isNotEmpty) {
                    final double sumTaxRates = catData.categoryTax!.fold(
                        0.0, (sum, t) => sum + (t.tax ?? 0).toDouble());
                    for (final t in catData.categoryTax!) {
                      final double rate = (t.tax ?? 0).toDouble();
                      if (rate <= 0) continue;
                      final double portion = (sumTaxRates > 0)
                          ? (itemTax * (rate / sumTaxRates))
                          : 0.0;
                      final String tName = (t.taxName != null &&
                              t.taxName!.trim().isNotEmpty)
                          ? t.taxName!.trim().toUpperCase()
                          : 'GST';
                      taxPortions[tName] = (taxPortions[tName] ?? 0.0) + portion;
                      taxRates[tName] = rate;
                    }
                  } else {
                    double taxPct = (item.catTax != null && item.catTax! > 0)
                        ? item.catTax!
                        : ((item.detail.bulkTax ?? 0) > 0
                            ? (item.detail.bulkTax!).toDouble()
                            : 0.0);

                    if (taxPct <= 0) {
                      final int qtyFactor = (item.isPack == true ||
                              item.detail.packtype == 'Pack')
                          ? (item.detail.pieces?.toInt() ?? 1)
                          : 1;
                      final double sellPx =
                          double.tryParse(item.detail.sellPrice ?? '0') ??
                              0.0;
                      final double base =
                          sellPx * qtyFactor * item.detail.count;
                      if (base > 0) {
                        taxPct = ((itemTax / base) * 100).roundToDouble();
                      }
                    }

                    final String tName = 'GST';
                    taxPortions[tName] = (taxPortions[tName] ?? 0.0) + itemTax;
                    taxRates[tName] = taxPct > 0 ? taxPct : 0.0;
                  }
                }

                final double totalTaxPercent = taxRates.values.fold(0.0, (sum, r) => sum + r);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 20,
                                  color: brandPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Final Amount'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: fontFamilyName,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formatAmount(payableAmount),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: fontFamilyName,
                            color: brandPurple,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    if (totalTaxAmt > 0) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text(
                            'TAX - ${taxPortions.entries.map((entry) {
                              final rate = taxRates[entry.key] ?? 0.0;
                              final rateStr = rate % 1 == 0 ? rate.toInt().toString() : rate.toString();
                              return '${entry.key} : $rateStr% : ${formatAmount(entry.value)}';
                            }).join('   ')}   TOTAL : ${totalTaxPercent % 1 == 0 ? totalTaxPercent.toInt() : totalTaxPercent}% : ${formatAmount(totalTaxAmt)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: brandPurple,
                              fontFamily: fontFamilyName,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. ORDER TYPE SELECTOR (Sale Order, Quick Sale, Estimate in 1 Row)
        Row(
          children: filteredOptions.map((option) {
            if (totalQuickController.text.isEmpty) {
              final String cid =
                  widget.productsController.selectedCustomerId.value;
              final double flatDisc =
                  widget.productsController.flatDiscountByCustomer[cid] ?? 0.0;
              double discountedSubtotal =
                  widget.productsController.orderItems.fold(
                0.0,
                (sum, item) {
                  if (item.isChecked != true) return sum;
                  return sum + (item.finalPrice ?? item.totalPrice ?? 0.0);
                },
              );
              discountedSubtotal =
                  (discountedSubtotal - flatDisc).clamp(0.0, double.infinity);

              double discountedPreorderSubtotal =
                  widget.productsController.preorderItems.fold(
                0.0,
                (sum, item) {
                  if (item.isChecked != true) return sum;
                  return sum + (item.finalPrice ?? item.totalPrice ?? 0.0);
                },
              );

              totalQuickController.text = isOrder
                  ? discountedSubtotal.toStringAsFixed(2)
                  : discountedPreorderSubtotal.toStringAsFixed(2);
            }
            final isSelected = _selectedValue == option;
            IconData optionIcon;
            if (option == "Sale Order" || option == _options[0]) {
              optionIcon = Icons.article_outlined;
            } else if (option == "Quick Sale" || option == _options[1]) {
              optionIcon = Icons.bolt_rounded;
            } else {
              optionIcon = Icons.article_outlined;
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (option == _options[1]) {
                        if (subscriptionController.appQuickSale.value ==
                            "true") {
                          setState(() {
                            _selectedValue = option;
                            _dropdownValue = null;
                            paymentType = null;
                            totalQuickController.clear();
                          });
                        } else {
                          showUpgradePlanDialog(context);
                        }
                      } else {
                        setState(() {
                          _selectedValue = option;
                          _dropdownValue = null;
                          totalQuickController.clear();
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 16,
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            optionIcon,
                            size: 16,
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              option.tr,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontFamily: fontFamilyName,
                                color: isSelected
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // 3. QUICK SALE INPUTS (Sleek Form Card)
        if (_selectedValue == "Quick Sale" ||
            _selectedValue == _options[1]) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18, color: Color(0xFF64748B)),
                          hint: Text("Payment".tr,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: fontFamilyName,
                                  color: Color(0xFF64748B))),
                          value: _dropdownValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              _dropdownValue = newValue!;
                              switch (_dropdownValue) {
                                case 'Cash':
                                  paymentType = 0;
                                  break;
                                case 'Cheque':
                                  paymentType = 1;
                                  break;
                                case 'Bank Transfer':
                                  paymentType = 2;
                                  break;
                                default:
                                  paymentType = null;
                              }
                            });
                          },
                          items: <String>[
                            'Cash',
                            'Cheque',
                            'Bank Transfer',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: fontFamilyName,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B))),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a payment method';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 44,
                      child: TextFormField(
                        controller: totalQuickController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        style: const TextStyle(
                            fontSize: 13, fontFamily: fontFamilyName),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the total amount';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          prefixText: '${addCurrencySymbol()} ',
                          labelText: "Amount".tr,
                          labelStyle: const TextStyle(
                              fontSize: 13,
                              fontFamily: fontFamilyName,
                              color: Color(0xFF64748B)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide:
                                const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(
                                color: brandPurple, width: 1.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_dropdownValue == "Cheque" ||
                      _dropdownValue == "Bank Transfer") ...[
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 44,
                        child: TextFormField(
                          controller: chequeOrTransactionNumberController,
                          style: const TextStyle(
                              fontSize: 13, fontFamily: fontFamilyName),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            labelText: _dropdownValue == "Cheque"
                                ? "Cheque Number"
                                : "Txn Number",
                            labelStyle: const TextStyle(
                                fontSize: 13,
                                fontFamily: fontFamilyName,
                                color: Color(0xFF64748B)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide:
                                  const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                  color: brandPurple, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 44,
                        child: TextFormField(
                          controller: dateController,
                          readOnly: true,
                          style: const TextStyle(
                              fontSize: 13, fontFamily: fontFamilyName),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            labelText: "Date",
                            labelStyle: const TextStyle(
                                fontSize: 13,
                                fontFamily: fontFamilyName,
                                color: Color(0xFF64748B)),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.calendar_today_rounded,
                                  size: 15, color: Color(0xFF64748B)),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    dateController.text =
                                        DateFormat('dd/MM/yyyy')
                                            .format(pickedDate);
                                  });
                                }
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide:
                                  const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                  color: brandPurple, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 44,
                      child: TextFormField(
                        controller: remarkController,
                        style: const TextStyle(
                            fontSize: 13, fontFamily: fontFamilyName),
                        validator: (value) {
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          labelText: "Remark",
                          labelStyle: const TextStyle(
                              fontSize: 13,
                              fontFamily: fontFamilyName,
                              color: Color(0xFF64748B)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide:
                                const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(
                                color: brandPurple, width: 1.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 14),

        // 4. ACTION BUTTONS (Continue Shopping & Save & Send)
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      size: 18, color: brandPurple),
                  label: Text(
                    'Continue Shopping'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: brandPurple,
                      fontSize: 14.5,
                      fontFamily: fontFamilyName,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    if (widget.isFromCustomerDach == true ||
                        widget.isDashboard == true) {
                      widget.onContinueShopping!();
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).pop();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: brandPurple, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined,
                      size: 18, color: Colors.white),
                  label: Text(
                    'Save & Send'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: fontFamilyName,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onPressed: () async {
                    final cartProvider =
                        Provider.of<CustomersProvider>(context, listen: false);
                    final hasCheckInOutPermission =
                        subscriptionController.customerCheckInOut.value ==
                            "true";
                    final isCheckedIn = widget.active == true;

                    if (!(isCheckedIn || !hasCheckInOutPermission)) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 60),
                          content: Text(
                              'Please check-in before processing the order'.tr),
                          actions: [
                            SizedBox(
                              width: 150,
                              height: 45,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF727CF5), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  'OK'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF727CF5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    final String customerId = widget.customerId ??
                        widget.productsController.selectedCustomerId.value;

                    final String cid =
                        widget.productsController.selectedCustomerId.value;
                    final double flatDisc =
                        widget.productsController.flatDiscountByCustomer[cid] ??
                            0.0;
                    final double subtotal =
                        isOrder ? orderSubtotal : preorderSubtotal;
                    final double baseAmount =
                        (subtotal - flatDisc).clamp(0.0, double.infinity);

                    if (_selectedValue == "Quick Sale") {
                      if (totalQuickController.text.trim().isEmpty) {
                        totalQuickController.text = baseAmount.toStringAsFixed(2);
                      }
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all required fields'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                    }

                    final sanitizedText = totalQuickController.text
                        .replaceAll(RegExp(r'[^\d.]'), '')
                        .trim();
                    final double userEnteredAmount =
                        double.tryParse(sanitizedText) ?? 0.0;

                    final double originalTotal = (_selectedValue == "Quick Sale" && userEnteredAmount > 0)
                        ? userEnteredAmount
                        : baseAmount;

                    final availableCredit =
                        _customercreditctrl.customerCredit.value ?? 0.0;

                    bool? useCreditResult = false;
                    bool isEligibleForCreditPopup =
                        _selectedValue == 'Sale Order' ||
                            _selectedValue == 'Quick Sale';

                    if (isEligibleForCreditPopup &&
                        availableCredit > 0 &&
                        originalTotal > 0) {
                      useCreditResult = await showCreditUsageDialog(
                        context: context,
                        availableCredit: availableCredit,
                        amountToPayBeforeCredit: originalTotal,
                      );
                      if (useCreditResult == null) return;
                    }

                    final cartDetails = await CartDatabaseManager()
                        .getDraftAndCartIdsFromApi(customerId);
                    await Future.delayed(const Duration(milliseconds: 500));
                    final firstOrder = cartDetails.isNotEmpty
                        ? cartDetails.last
                        : {'cart_id': '', 'draft_id': ''};
                    final cartIdPrefs = firstOrder['cart_id'] ?? '';
                    final draftIdPrefs = firstOrder['draft_id'] ?? '';

                    if (widget.productsController.storedBulkList.isEmpty) {
                      await widget.productsController.fetchBulkData();
                    }

                    await processSaveAndSend(
                      context: context,
                      finalAmount: originalTotal,
                      useCreditConfirmed: useCreditResult ?? false,
                      paymentType: paymentType,
                      cartId: cartIdPrefs,
                      draftId: draftIdPrefs,
                      bulkDataList: widget.productsController.storedBulkList,
                    );

                    cartProvider.getCartItemCounts(customerId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    elevation: 2,
                    shadowColor: brandPurple.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupedItems({
    required String productName,
    required List<CartItem> groupedItems,
    required double availableWidth,
    required double fontSize,
    required double rowHeight,
    required BuildContext context,
    required dynamic Function(CartItem, String, double, double)
        productQuantityManager,
    required Function(BuildContext, CartItem, List<CartItem>)
        deleteConfirmationDialogue,
    required bool isPreOrder,
    required Function calCulateAmount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRODUCT GROUP HEADER BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 15,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    productName.startsWith('Bundle') ? "Bundle" : productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${groupedItems.length} items',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: const Color(0xFFFEF2F2),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      showVariantDeleteDialog(
                        context,
                        productName,
                        !isOrder,
                        false,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 32,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PRODUCT TABLE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(13),
              bottomRight: Radius.circular(13),
            ),
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 60,
              horizontalMargin: 8,
              columnSpacing: 14,
              headingRowColor:
                  MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              columns: DataTableColumns.getColumns(
                  isPhonePortrait(context) ? 12 : fontSize,
                  isBundle: productName.startsWith('Bundle')),
              rows: GroupedItemDataRows.getRows(
                groupedItems: groupedItems,
                fontSize: isPhonePortrait(context) ? 12 : availableWidth / 55,
                availableWidth: isPhonePortrait(context)
                    ? fullScreenWidth(context) * 2
                    : availableWidth,
                context: context,
                productQuantityManager: productQuantityManager,
                deleteConfirmationDialogue: deleteConfirmationDialogue,
                calculateAmount: calCulateAmount,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> processSaveAndSend({
    required BuildContext context,
    required double finalAmount,
    required bool useCreditConfirmed,
    int? paymentType,
    required String cartId,
    required String draftId,
    List<BulkData>? bulkDataList,
  }) async {
    List<CartItem> itemList;
    String customerId = (widget.customerId != null && widget.customerId != '')
        ? widget.customerId ??
            widget.productsController.selectedCustomerId.value
        : widget.productsController.selectedCustomerId.value;
    if (_selectedValue == 'Sale Order' ||
        _selectedValue == 'Quick Sale' ||
        _selectedValue == 'Estimate') {
      itemList = [
        ...widget.productsController.orderItems
            .where((item) => item.isChecked == true)
      ];
    } else if (_selectedValue == 'Booking') {
      itemList = [
        ...widget.productsController.preorderItems
            .where((item) => item.isChecked == true)
      ];
    } else {
      itemList = [];
    }

    final connectivityService = ConnectivityService();

    if (itemList.isNotEmpty &&
        (customeController.customerId.value.isNotEmpty ||
            widget.productsController.selectedCustomerId.value.isNotEmpty)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      try {
        bool isOnline = await connectivityService.isOnline();

        if (!isOnline) {
          int status = _selectedValue == 'Sale Order'
              ? 11
              : _selectedValue == 'Booking'
                  ? 0
                  : _selectedValue == 'Estimate'
                      ? 7
                      : 14;

          await saveOrderOffline(finalAmount, paymentType, status);
          Navigator.pop(context);
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actionsPadding:
                  const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text('Offline Mode'),
              content: const Text(
                  'The order will be placed automatically when connected to the internet.'),
              actions: [
                SizedBox(
                  width: 150,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                        Navigator.of(context, rootNavigator: true).pop();
                        _clearCartItem(itemList, customerId);
                      });
                      if (widget.onDraftUpdated != null) {
                        widget.onDraftUpdated!();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF727CF5), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'OK'.tr,
                      style: const TextStyle(
                        color: Color(0xFF727CF5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          if (widget.productsController.orderItems.isEmpty &&
              widget.productsController.preorderItems.isEmpty) {
            clearEntireCartForCustomer();
          }
          return;
        } else {
          List<Detail> detail = itemList.map((e) => e.detail).toList();
          final productBYData = AddToCartModel(
            customerId: customerId,
            salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
            cartId: '',
            cartList: await Future.wait(itemList.map((item) async {
              final e = item.detail;

              // Calculate Pack Value
              // String packValue =
              //     e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();
              String displayPackType =
                  (e.packtype == 'Pack' || item.isPack == true)
                      ? (e.packtype ?? 'Bulk')
                      : (e.packtype == null ? 'Bulk' : 'Pcs');

              // Calculate Pack Value consistently with UI
              String packValue = (e.packtype == 'Pack' || item.isPack == true)
                  ? e.pieces.toString()
                  : e.count.toString();
              print('bundle promo msg: ${item.promoMsg}');
              final double combinedDiscount =
                  (item.totalDiscountAmount ?? 0).toDouble() +
                      (item.flatDiscount ?? 0).toDouble() +
                      (item.bogoDiscount ?? 0).toDouble();

              final num combinedPromoDiscount = (item.tieredDiscount ?? 0) +
                  (item.flatDiscount ?? 0) +
                  (item.bogoDiscount ?? 0);
              // 1. Check if it is a Promo Item
              if (item.isPromo == true) {
                bool isBundle = item.promoMsg != null &&
                    item.promoMsg!.startsWith("Bundle");

                if (isBundle) {
                  // --- Bundle Logic ---
                  return SendCartData(
                    productId: e.productId ?? '',
                    variantId: e.variationId ?? '',
                    pack: packValue,
                    price: e.sellPrice.toString(),
                    packType: displayPackType,
                    discount: combinedDiscount,
                    quantity: e.count.toInt(),
                    variantName: e.variationName ?? '',
                    maxDiscount: e.maxDiscount?.toInt(),
                    // Specific Bundle Flags
                    isPromo: true,
                    isBundle: true,
                    promoCode: item.promoCode ?? '',
                    promoMsg: "Bundle: ${e.variationName}",
                    bundleDetails: "Bundle: ${e.variationName}",

                    customerDiscount: item.CustomerDiscount,
                    promoDiscount: combinedPromoDiscount,
                    unitPrice: e.sellPrice.toString(),
                    isBulk: false,
                    originalUnitPrice: e.sellPrice.toString(),
                    originalPackPrice: (() {
                      final double? apiPP =
                          double.tryParse(e.sellingPackPrice?.toString() ?? '');
                      return (apiPP != null && apiPP > 0)
                          ? apiPP.toString()
                          : ((double.tryParse(e.sellPrice?.toString() ?? '0') ??
                                      0.0) *
                                  (e.pieces?.toInt() ?? 1))
                              .toString();
                    })(),
                    editedAmount: 0.0,
                    customerDiscountPercentage: item.CustomerDiscount,
                  );
                } else {
                  // --- Standard Promo Logic ---
                  return SendCartData(
                    productId: e.productId ?? '',
                    variantId: e.variationId ?? '',
                    pack: packValue,
                    price: e.sellPrice.toString(),
                    packType: displayPackType,
                    discount: combinedDiscount,
                    quantity: e.count.toInt(),
                    variantName: e.variationName ?? '',
                    maxDiscount: e.maxDiscount?.toInt(),

                    // Standard Promo Flags
                    isPromo: true,
                    isBundle: false, // Not a bundle
                    promoCode: item.promoCode ?? '',
                    promoMsg: item.promoMsg ?? '',

                    customerDiscount: item.CustomerDiscount,
                    promoDiscount: combinedPromoDiscount,
                    unitPrice: e.sellPrice.toString(),
                    isBulk: false,
                    originalUnitPrice: e.sellPrice.toString(),
                    originalPackPrice: (() {
                      final double? apiPP =
                          double.tryParse(e.sellingPackPrice?.toString() ?? '');
                      return (apiPP != null && apiPP > 0)
                          ? apiPP.toString()
                          : ((double.tryParse(e.sellPrice?.toString() ?? '0') ??
                                      0.0) *
                                  (e.pieces?.toInt() ?? 1))
                              .toString();
                    })(),
                    editedAmount: 0.0,
                    customerDiscountPercentage: item.CustomerDiscount,
                  );
                }
              } else {
                // 2. Normal Item Logic (Check for Bulk)

// 2. Normal Item Logic (Check for Bulk)
                bool isBulkItem = false;

// 1. Try to get it from the direct property first (Just like your other function)
                String? currentBulkId = e.bulkId;

// 2. Fallback: If bulkId is null, try to extract it from the variation name using Regex
                if ((currentBulkId == null || currentBulkId.isEmpty) &&
                    e.variationName?.contains('[BULK_ID:') == true) {
                  final regex = RegExp(r'\[BULK_ID:(\d+)\]');
                  final match = regex.firstMatch(e.variationName!);
                  if (match != null) {
                    // Add "BULK_" prefix so it matches your storedBulkList format ("BULK_5")
                    currentBulkId = 'BULK_${match.group(1)}';
                  }
                }

// 3. Set up default values before checking the list
                String? idToSendToBackend = currentBulkId;
                String finalPrice = e.sellPrice.toString();

// 4. Apply the exact same bulkDataList matching logic
                if (currentBulkId != null && currentBulkId.isNotEmpty) {
                  isBulkItem = true;

                  if (bulkDataList != null) {
                    try {
                      final matchingBulk = bulkDataList.firstWhere(
                        (element) => element.bulkId == currentBulkId,
                      );

                      // Update the ID to send to backend
                      idToSendToBackend =
                          matchingBulk.id?.toString() ?? currentBulkId;

                      // Update the price if a volume price exists
                      if (matchingBulk.volumePrice != null &&
                          matchingBulk.volumePrice!.isNotEmpty) {
                        finalPrice = matchingBulk.volumePrice!;
                      }
                    } catch (err) {
                      print(
                          'Bulk ID $currentBulkId found but not matched in BulkData list: $err');
                    }
                  }
                }

                // ── Edit-price discount for non-promo items ───────────────────
                // When the salesman overrides the unit price via displayPrice, the
                // difference relative to the original sellPrice is an implicit
                // discount. We add it on top of the existing combinedDiscount
                // so the backend receives the full discount amount.
                double editPriceDiscountAmt = 0.0;
                if (e.displayPrice != null) {
                  final double origPrice =
                      double.tryParse(e.sellPrice?.toString() ?? '0') ?? 0.0;
                  final double newPrice =
                      double.tryParse(e.displayPrice!) ?? origPrice;
                  final int itemQtyFactor =
                      (e.packtype == 'Pack' || item.isPack == true)
                          ? (e.pieces?.toInt() ?? 1)
                          : 1;
                  final double priceDiff = origPrice - newPrice;
                  if (priceDiff > 0) {
                    editPriceDiscountAmt =
                        priceDiff * itemQtyFactor * e.count.toDouble();
                  }
                }
                final double totalCombinedDiscount =
                    combinedDiscount + editPriceDiscountAmt;

                // Use displayPrice as the unit_price when it has been edited,
                // so the backend stores the overridden price.
                final String effectiveUnitPrice =
                    e.displayPrice ?? e.sellPrice.toString();

                return SendCartData(
                  productId: e.productId ?? '',
                  variantId: e.variationId ?? '',
                  pack: packValue,
                  price: finalPrice,
                  packType: isBulkItem ? 'Bulk' : displayPackType,
                  discount: totalCombinedDiscount,
                  quantity: e.count.toInt(),
                  variantName: e.variationName ?? '',

                  // Normal/Bulk Flags
                  isPromo: false,
                  isBundle: false,
                  isBulk: isBulkItem,
                  bulkId: idToSendToBackend,

                  customerDiscount: item.CustomerDiscount,
                  promoDiscount: combinedPromoDiscount,
                  unitPrice: effectiveUnitPrice,
                  originalUnitPrice: e.sellPrice.toString(),
                  originalPackPrice: (() {
                    final double? apiPP =
                        double.tryParse(e.sellingPackPrice?.toString() ?? '');
                    return (apiPP != null && apiPP > 0)
                        ? apiPP.toString()
                        : ((double.tryParse(e.sellPrice?.toString() ?? '0') ??
                                    0.0) *
                                (e.pieces?.toInt() ?? 1))
                            .toString();
                  })(),
                  editedAmount: editPriceDiscountAmt,
                  customerDiscountPercentage: item.CustomerDiscount,
                );
              }
            }).toList()),
            total: finalAmount.toStringAsFixed(0),
          );

          List<String> varientIdsPass = [];
          for (var item in detail) {
            varientIdsPass.add(item.variationId ?? '');
          }

          CartOrderModel? cartOrder =
              await ApiWorker().addToCart(productBYData.toJson());
          print(
              'addtocartttt productBYData to json: ${productBYData.toJson()}');

          if (cartOrder != null) {
            final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
            int orderStatus = _selectedValue == 'Sale Order'
                ? 11
                : _selectedValue == 'Booking'
                    ? 0
                    : _selectedValue == 'Estimate'
                        ? 7
                        : 14;

            final customerCreditCtrl = Get.find<CustomerCreditController>();
            final availableCredit =
                customerCreditCtrl.customerCredit.value ?? 0.0;
            final double originalTotal = finalAmount; // Before credit

            final bool shouldUseCredit =
                useCreditConfirmed && availableCredit > 0 && originalTotal > 0;
            final creditUsed = shouldUseCredit
                ? (originalTotal > availableCredit
                    ? availableCredit
                    : originalTotal)
                : 0.0;

            final double amountToPayAfterCredit =
                (originalTotal - creditUsed).clamp(0.0, double.infinity);

            print(
                "Credit Debug → Available: $availableCredit | Used: $creditUsed | Pay Now: $amountToPayAfterCredit");

            // === FINAL ORDER ===
            int orderStatuses = _selectedValue == 'Sale Order'
                ? 11
                : _selectedValue == 'Booking'
                    ? 0
                    : _selectedValue == 'Estimate'
                        ? 7
                        : 14;

            CartOrderModel order = CartOrderModel(
              customerId: customerId,
              salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
              cartId: cartOrder.cartId,
              orderStatus: orderStatus,
              orderPrice: finalAmount,
              paymentType: paymentType != null ? paymentType.toString() : null,
              companyId: companyId,
              paymentDetail: remarkController.text.trim().isNotEmpty
                  ? remarkController.text.trim()
                  : null,
              transactionNumber: (_dropdownValue == "Cheque" ||
                          _dropdownValue == "Bank Transfer") &&
                      chequeOrTransactionNumberController.text.trim().isNotEmpty
                  ? chequeOrTransactionNumberController.text.trim()
                  : null,
              transactionDate: (_dropdownValue == "Cheque" ||
                          _dropdownValue == "Bank Transfer") &&
                      dateController.text.trim().isNotEmpty
                  ? dateController.text.trim()
                  : null,
              draftId: draftId.isNotEmpty ? draftId : '',
              varientIds: varientIdsPass,
              creditAmount: shouldUseCredit ? creditUsed : 0,
            );
            print('place order data: ${order.toJson()}');

            await ApiWorker().placeOrder(order,
                (statusCode, message, response) async {
              Navigator.pop(context);
              if (statusCode == 200) {
                if (shouldUseCredit) {
                  // Deduct used credit from controller (immediate UI update)
                  customerCreditCtrl.customerCredit.value =
                      (availableCredit - creditUsed)
                          .clamp(0.0, double.infinity)
                          .toInt();
                }

                productController.isCartModified.value = false;

                _clearCartItem(itemList, customerId);

                try {
                  final apiService = ApiService();
                  final salesmanId =
                      SessionHelper.loginSavedData?.salesmanId ?? '';

                  final now = DateTime.now();
                  final startDate = DateTime(now.year, 1, 1);
                  final endDate = DateTime(now.year, 12 + 1, 0);

                  final formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);
                  final formattedEndDate =
                      DateFormat('yyyy-MM-dd').format(endDate);

                  String orderType;
                  switch (_selectedValue) {
                    case 'Sale Order':
                      orderType = 'sale_order';
                      break;
                    case 'Quick Sale':
                      orderType = 'quick_sale';
                      break;
                    case 'Booking':
                      orderType = 'booking';
                      break;
                    case 'Estimate':
                      orderType = 'estimate';
                      break;
                    default:
                      orderType = 'draft';
                  }

                  await apiService.updateCachedDraftsAfterSaveAndSend(
                    context,
                    customerId: customerId,
                    draftId: draftId.isNotEmpty ? draftId : '',
                    salesmanId: salesmanId,
                    startDate: formattedStartDate,
                    endDate: formattedEndDate,
                    orderType: orderType,
                    sentCartIds: [cartOrder.cartId],
                    sentAmount: finalAmount,
                  );
                } catch (e) {}

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      actionsPadding: const EdgeInsets.only(
                          bottom: 20, left: 16, right: 16),
                      actionsAlignment: MainAxisAlignment.center,
                      title: Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Lottie.asset(
                              'assets/images/Animation - 1726906882515.json'),
                        ),
                      ),
                      content: CustomText(
                        content: message,
                        fontSize: 18,
                      ),
                      actions: [
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: OutlinedButton(
                            onPressed: () async {
                              final cartProvider =
                                  Provider.of<CustomersProvider>(context,
                                      listen: false);

                              CartDatabaseManager().addListener(() {
                                cartProvider.updateCartCount(customerId);
                              });
                              if (widget.isDashboard == true) {
                                Provider.of<DashboardProvider>(context,
                                        listen: false)
                                    .fetchData();
                              } else {
                                Provider.of<CustomersProvider>(context,
                                        listen: false)
                                    .fetchCustomerDashboardCountData(
                                        customerId);
                              }

                              setState(() {
                                Navigator.pop(context);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              });
                              if (widget.onDraftUpdated != null) {
                                widget.onDraftUpdated!();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF727CF5), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'OK'.tr,
                              style: const TextStyle(
                                color: Color(0xFF727CF5),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      actionsPadding: const EdgeInsets.only(
                          bottom: 20, left: 16, right: 16),
                      actionsAlignment: MainAxisAlignment.center,
                      title: Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset(
                              'assets/images/Warning_animation.json'),
                        ),
                      ),
                      content: CustomText(
                        content: message,
                        fontSize: 18,
                      ),
                      actions: [
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF727CF5), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'OK'.tr,
                              style: const TextStyle(
                                color: Color(0xFF727CF5),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            });
          }
        }
      } catch (e) {
        Navigator.pop(context);
        showFailureDialog(context, 'An unexpected error occurred.');
      }
    } else {
      Navigator.pop(context);
      if (widget.customerId == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No Customer Selected'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     backgroundColor: Colors.red,
        //     content: Text('Your cart is empty.'),
        //     duration: Duration(seconds: 3),
        //   ),
        // );
      }
    }
  }

//   Future<void> processSaveAndSend({
//     required BuildContext context,
//     required double finalAmount,
//     required bool useCreditConfirmed,
//     int? paymentType,
//     required String cartId,
//     required String draftId,
//   }) async {
//     // Determine which items to process based on the active tab (_selectedValue)
//     List<CartItem> itemList;
//     String customerId = (widget.customerId != null && widget.customerId != '')
//         ? widget.customerId ??
//             widget.productsController.selectedCustomerId.value
//         : widget.productsController.selectedCustomerId.value;
//     if (_selectedValue == 'Sale Order' ||
//         _selectedValue == 'Quick Sale' ||
//         _selectedValue == 'Estimate') {
//       itemList = [
//         ...widget.productsController.orderItems
//             .where((item) => item.isChecked == true)
//       ];
//     } else if (_selectedValue == 'Booking') {
//       itemList = [
//         ...widget.productsController.preorderItems
//             .where((item) => item.isChecked == true)
//       ];
//     } else {
//       itemList = [];
//     }
//     // Debug logging
//     final connectivityService = ConnectivityService();
//     if (itemList.isNotEmpty &&
//         (customeController.customerId.value.isNotEmpty ||
//             widget.productsController.selectedCustomerId.value.isNotEmpty)) {
//       showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           return const Center(child: CircularProgressIndicator());
//         },
//       );
//       try {
//         bool isOnline = await connectivityService.isOnline();

//         if (!isOnline) {
//           int status = _selectedValue == 'Sale Order'
//               ? 11
//               : _selectedValue == 'Booking'
//                   ? 0
//                   : _selectedValue == 'Estimate'
//                       ? 7
//                       : 14;
//           await saveOrderOffline(finalAmount, paymentType, status);
//           Navigator.pop(context);
//           showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Offline Mode'),
//               content: const Text(
//                   'The order will be placed automatically when connected to the internet.'),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       Navigator.pop(context);
//                       Navigator.of(context, rootNavigator: true).pop();
//                       _clearCartItem(itemList, customerId);
//                     });
//                     // Call the callback to refresh the draft list
//                     if (widget.onDraftUpdated != null) {
//                       widget.onDraftUpdated!();
//                     }
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//           );
//           if (widget.productsController.orderItems.isEmpty &&
//               widget.productsController.preorderItems.isEmpty) {
//             clearEntireCartForCustomer();
//           }
//           return;
//         } else {
//           final productBYData = AddToCartModel(
//             customerId: customerId,
//             salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
//             cartId: '',
//             cartList: await Future.wait(itemList.map((item) async {
//               final e = item.detail; // for easier reference

//               String packValue =
//                   e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();

//               if (item.isPromo == true) {
//                 bool isBundle = item.promoMsg != null &&
//                     item.promoMsg!.startsWith("Bundle");

//                 if (isBundle) {
//                   return SendCartData(
//                     productId: e.productId ?? '',
//                     variantId: e.variationId ?? '',
//                     pack: packValue,
//                     price: e.sellPrice.toString(),
//                     packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
//                     discount: e.discount ?? 0,
//                     quantity: e.count.toInt(),
//                     variantName: e.variationName ?? '',
//                     maxDiscount: e.maxDiscount?.toInt(),
//                     isPromo: true,
//                     promoCode: item.promoCode ?? '',
//                     promoMsg: "Bundle: ${e.variationName}",
//                     isBundle: true,
//                     bundleDetails:
//                         isBundle ? "Bundle: ${e.variationName}" : null,
//                   );
//                 } else {
//                   return SendCartData(
//                     productId: e.productId ?? '',
//                     variantId: e.variationId ?? '',
//                     pack: packValue,
//                     price: e.sellPrice.toString(),
//                     packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
//                     discount: e.discount ?? 0,
//                     quantity: e.count.toInt(),
//                     variantName: e.variationName ?? '',
//                     maxDiscount: e.maxDiscount?.toInt(),
//                     isPromo: true,
//                     promoCode: item.promoCode ?? '',
//                     promoMsg: item.promoMsg ?? '',
//                     customerDiscount: item.CustomerDiscount,
//                     promoDiscount: item.tieredDiscount,
//                   );
//                 }
//               } else {
//                 // ✅ Normal items
//                 return SendCartData(
//                   productId: e.productId ?? '',
//                   variantId: e.variationId ?? '',
//                   pack: packValue,
//                   price: e.sellPrice.toString(),
//                   packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
//                   discount: e.discount ?? 0,
//                   quantity: e.count.toInt(),
//                   variantName: e.variationName ?? '',
//                   isPromo: false,
//                   promoCode: "",
//                   customerDiscount: item.CustomerDiscount,
//                   promoDiscount: item.tieredDiscount,
//                 );
//               }
//             }).toList()),
//             total: finalAmount.toStringAsFixed(0),
//           );

//           List<String> variantIdsPass = [];

//           final RegExp variantIdRegex = RegExp(r'Variant Id:\s*(\S+)');

//           for (var item in itemList) {
//             final variantId = item.detail.variationId ?? '';
//             if (variantId.isNotEmpty && !variantId.contains("BUNDLE")) {
//               variantIdsPass.add(variantId);
//             }

//             if (item.isPromo == true &&
//                 (item.promoMsg?.startsWith('Bundle') ?? false)) {
//               final promoMsg = item.promoMsg ?? '';
//               for (final m in variantIdRegex.allMatches(promoMsg)) {
//                 final extracted = m.group(1);
//                 if (extracted != null && extracted.isNotEmpty) {
//                   variantIdsPass.add(extracted);
//                 }
//               }
//             }
//           }

//           variantIdsPass = variantIdsPass.toSet().toList();

//           CartOrderModel? cartOrder =
//               await ApiWorker().addToCart(productBYData.toJson());

//           if (cartOrder != null) {
//             final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
//             int orderStatus = _selectedValue == 'Sale Order'
//                 ? 11
//                 : _selectedValue == 'Booking'
//                     ? 0
//                     : _selectedValue == 'Estimate'
//                         ? 7
//                         : 14;

// //
//             // final customerCreditCtrl = Get.find<CustomerCreditController>();
//             // final availableCredit =
//             //     customerCreditCtrl.customerCredit.value; // fresh value
//             // final originalTotal = finalAmount; // total before any credit

//             // final bool shouldUseCredit = (_selectedValue == 'Sale Order' ||
//             //         _selectedValue == 'Quick Sale') &&
//             //     useCredit.value == true &&
//             //     availableCredit > 0;

//             // final creditUsed = shouldUseCredit
//             //     ? (originalTotal > availableCredit
//             //         ? availableCredit
//             //         : originalTotal)
//             //     : 0.0;

//             // final amountToPay =
//             //     (originalTotal - creditUsed).clamp(0.0, double.infinity);

//             // print(
//             //     "Available Credit: $availableCredit | Credit Used: $creditUsed | Pay Now: $amountToPay");

//  final customerCreditCtrl = Get.find<CustomerCreditController>();
//     final  availableCredit = customerCreditCtrl.customerCredit.value ?? 0.0;
//     final double originalTotal = finalAmount; // Before credit

//     final bool shouldUseCredit = useCreditConfirmed && availableCredit > 0 && originalTotal > 0;
//     final  creditUsed = shouldUseCredit
//         ? (originalTotal > availableCredit ? availableCredit : originalTotal)
//         : 0.0;

//     final double amountToPayAfterCredit = (originalTotal - creditUsed).clamp(0.0, double.infinity);

//     print("Credit Debug → Available: $availableCredit | Used: $creditUsed | Pay Now: $amountToPayAfterCredit");

//     // === FINAL ORDER ===
//     int orderStatuses = _selectedValue == 'Sale Order'
//         ? 11
//         : _selectedValue == 'Booking'
//             ? 0
//             : _selectedValue == 'Estimate'
//                 ? 7
//                 : 14;

//             CartOrderModel order = CartOrderModel(
//               customerId: customerId,
//               salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
//               cartId: cartOrder.cartId,
//               orderStatus: orderStatus,
//               orderPrice: finalAmount,
//               paymentType: paymentType.toString(),
//               companyId: companyId,
//               paymentDetail: remarkController.text.trim(),
//               transactionNumber:
//                   chequeOrTransactionNumberController.text.trim(),
//               transactionDate: dateController.text.trim(),
//               draftId: draftId.isNotEmpty ? draftId : '',
//               varientIds: variantIdsPass,
//               useCredit: shouldUseCredit,
//               creditAmount: shouldUseCredit ? creditUsed : 0,
//             );
//             // print('Cart Order: ${order.toJson()}');

//             await ApiWorker().placeOrder(order,
//                 (statusCode, message, response) async {
//               Navigator.pop(context);
//               // print(
//               //     'statusCodeww: $statusCode, message: $message, response: $response');
//               if (statusCode == 200) {
//                 if (shouldUseCredit) {
//     // Deduct used credit from controller (immediate UI update)
//    customerCreditCtrl.customerCredit.value =
//     (availableCredit - creditUsed).clamp(0.0, double.infinity).toInt();

//   }

//                 productController.isCartModified.value = false;
//                 // showSuccessFullDialogCtrl(context: context);
//                 _clearCartItem(itemList, customerId);

//                 // Update cached drafts after successful order placement
//                 try {
//                   final apiService = ApiService();
//                   final salesmanId =
//                       SessionHelper.loginSavedData?.salesmanId ?? '';

//                   final now = DateTime.now();
//                   final startDate = DateTime(now.year, 1, 1);
//                   final endDate = DateTime(now.year, 12 + 1, 0);

//                   final formattedStartDate =
//                       DateFormat('yyyy-MM-dd').format(startDate);
//                   final formattedEndDate =
//                       DateFormat('yyyy-MM-dd').format(endDate);

//                   // Determine order type based on _selectedValue
//                   String orderType;
//                   switch (_selectedValue) {
//                     case 'Sale Order':
//                       orderType = 'sale_order';
//                       break;
//                     case 'Quick Sale':
//                       orderType = 'quick_sale';
//                       break;
//                     case 'Booking':
//                       orderType = 'booking';
//                       break;
//                     case 'Estimate':
//                       orderType = 'estimate';
//                       break;
//                     default:
//                       orderType = 'draft';
//                   }

//                   await apiService.updateCachedDraftsAfterSaveAndSend(
//                     context,
//                     customerId: customerId,
//                     draftId: draftId.isNotEmpty ? draftId : '',
//                     salesmanId: salesmanId,
//                     startDate: formattedStartDate,
//                     endDate: formattedEndDate,
//                     orderType: orderType,
//                     sentCartIds: [
//                       cartOrder.cartId
//                     ], // The cart ID that was just sent
//                     sentAmount: finalAmount,
//                   );
//                 } catch (e) {
//                   // Don't show error to user as this is a background operation
//                 }

//                 showDialog(
//                   barrierDismissible: false,
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: Center(
//                         child: SizedBox(
//                           height: 100,
//                           width: 100,
//                           child: Lottie.asset(
//                               'assets/images/Animation - 1726906882515.json'),
//                         ),
//                       ),
//                       content: CustomText(
//                         content: message,
//                         fontSize: 18,
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () async {
//                             // Navigator.pop(context);
//                             final cartProvider = Provider.of<CustomersProvider>(
//                                 context,
//                                 listen: false);

//                             CartDatabaseManager().addListener(() {
//                               cartProvider.updateCartCount(customerId);
//                             });
//                             if (widget.isDashboard == true) {
//                               Provider.of<DashboardProvider>(context,
//                                       listen: false)
//                                   .fetchData();
//                             } else {
//                               Provider.of<CustomersProvider>(context,
//                                       listen: false)
//                                   .fetchCustomerDashboardCountData(customerId);
//                             }

//                             setState(() {
//                               Navigator.pop(context);
//                               Navigator.of(context, rootNavigator: true).pop();
//                             });
//                             if (widget.onDraftUpdated != null) {
//                               widget.onDraftUpdated!();
//                             }
//                           },
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               } else {
//                 showDialog(
//                   barrierDismissible: false,
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: Center(
//                         child: SizedBox(
//                           height: 200,
//                           width: 200,
//                           child: Lottie.asset(
//                               'assets/images/Warning_animation.json'),
//                         ),
//                       ),
//                       content: CustomText(
//                         content: message,
//                         fontSize: 18,
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               }
//             });
//           }
//         }
//       } catch (e) {
//         Navigator.pop(context);
//         showFailureDialog(context, 'An unexpected error occurred.');
//       }
//     } else {
//       Navigator.pop(context);
//       if (
//           // customeController.customerId.value.isEmpty ||
//           //   widget.productsController.selectedCustomerId.value.isEmpty
//           widget.customerId == '') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             backgroundColor: Colors.red,
//             content: Text('No Customer Selected'),
//             duration: Duration(seconds: 3),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             backgroundColor: Colors.red,
//             content: Text('Your cart is empty.'),
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

  Future<void> clearEntireCartForCustomer() async {
    String customerId = customeController.customerId.isNotEmpty
        ? customeController.customerId.value
        : widget.productsController.selectedCustomerId.value;
    await CartDatabaseManager().clearAllItemsForCustomer(customerId);
    setState(() {
      widget.productsController.cartItems.clear();
      widget.productsController.orderItems.clear();
      widget.productsController.preorderItems.clear();
    });
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    cartProvider.getCartItemCounts(customerId);
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child:
                  Lottie.asset('assets/images/Animation - 1726906882515.json'),
            ),
          ),
          content: CustomText(content: message, fontSize: 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pop();
                //_clearCartItem(itemList);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset('assets/images/Warning_animation.json'),
            ),
          ),
          content: CustomText(content: message, fontSize: 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> saveOrderOffline(
      double finalAmount, int? paymentType, int? status) async {
    final isQuickSale = _selectedValue == "Quick Sale";
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final businessName = widget.productsController.selectedCustomerName.value;
    final email = (widget.productsController.selectedCustomerEmail.value);
    final mobileNo = (widget.productsController.selectedCustomerMobileNo.value);
    final imageUrl = widget.productsController.selectedCustomerImageUrl.value;
    final createdAt = DateTime.now().toIso8601String();

    // Determine which items to process based on the active tab
    List<CartItem> processedItems;
    if (_selectedValue == 'Sale Order' ||
        _selectedValue == 'Quick Sale' ||
        _selectedValue == 'Estimate') {
      // For order tab - process order items (items with stock > 0)
      processedItems = widget.productsController.orderItems
          .where((item) => item.isChecked == true)
          .toList();
    } else {
      // For booking tab - process booking items (items with stock == 0)
      processedItems = widget.productsController.preorderItems
          .where((item) => item.isChecked == true)
          .toList();
    }

    // Save the order to offline orders box
    Map<String, dynamic> orderData = {
      'order_id': orderId,
      'customer_id': widget.productsController.selectedCustomerId.value,
      'businessName': businessName,
      'email': email,
      'mobileNo': mobileNo,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'salesman_id': SessionHelper.loginSavedData?.salesmanId ?? '',
      'order_price': Utils().calculateSubtotal(processedItems),
      // finalAmount,
      'paymentType': paymentType,
      'order_status': status,
      'cart_list': processedItems.map((e) {
        final double combinedDiscount =
            (e.totalDiscountAmount ?? 0).toDouble() +
                (e.flatDiscount ?? 0).toDouble() +
                (e.bogoDiscount ?? 0).toDouble();

        final num combinedPromoDiscount = (e.tieredDiscount ?? 0) +
            (e.flatDiscount ?? 0) +
            (e.bogoDiscount ?? 0);

        bool isBundle = e.promoMsg != null && e.promoMsg!.startsWith("Bundle");

        bool isBulkItem =
            (e.detail.bulkId != null && e.detail.bulkId!.isNotEmpty) ||
                (e.detail.variationName?.contains('[BULK_ID:') == true);

        return {
          'product_id': e.detail.productId,
          'product_name': e.productName,
          'variant_id': e.detail.variationId,
          'variant_name': e.detail.variationName,
          'pack': e.detail.saleBy == 'Pack'
              ? (e.detail.count * (e.detail.pieces ?? 1)).toString()
              : e.detail.count.toString(),
          'perPack': e.detail.saleBy == 'Pack'
              ? (e.detail.pieces).toString()
              : e.detail.count.toString(),
          'packType': e.detail.saleBy == 'Pack' ? 'Pack' : 'Pcs',
          'price': (e.detail.displayPrice ?? e.detail.sellPrice).toString(),
          'discount': '0',
          'quantity': e.detail.count.toInt(),
          'tax': e.detail.tax?.toInt(),
          'unitTax': e.detail.unitTax?.toInt(),
          'inclTax': e.detail.inclTax,
          'totalTax': (e.detail.tax ?? 0) *
              (e.isPack == true || e.detail.packtype == 'Pack'
                  ? (e.detail.pieces ?? 0) * e.detail.count
                  : 1),
          'discountPrice': (((double.tryParse(
                          (e.detail.displayPrice ?? e.detail.sellPrice)
                                  ?.toString() ??
                              '0') ??
                      0.0) *
                  ((double.tryParse(e.detail.discount?.toString() ?? '0') ??
                          0.0) /
                      100)) *
              ((e.isPack == true || e.detail.packtype == 'Pack')
                  ? (e.detail.pieces?.toDouble() ?? 1) *
                      e.detail.count.toDouble()
                  : e.detail.count.toDouble())),
          'totalPrice': e.detail.totalPrice,
          'isPack': e.isPack,
          'unitPrice': (e.detail.displayPrice ?? e.detail.sellPrice).toString(),
          'maxDiscount': e.detail.maxDiscount?.toInt(),
          'isPromo': e.isPromo ?? false,
          'isBundle': isBundle,
          'promoCode': e.promoCode ?? '',
          'promoMsg': isBundle
              ? "Bundle: ${e.detail.variationName}"
              : (e.promoMsg ?? ''),
          'bundleDetails': isBundle ? "Bundle: ${e.detail.variationName}" : '',
          'customerDiscount': e.CustomerDiscount ?? 0.0,
          'promoDiscount': combinedPromoDiscount,
          'isBulk': isBulkItem,
          'bulkId': e.detail.bulkId ?? '',
        };
      }).toList(),
      if (isQuickSale) ...{
        'paymentDetail': remarkController.text.trim(),
        'transactionNumber': chequeOrTransactionNumberController.text.trim(),
        'transactionDate': dateController.text.trim(),
      }
    };

    var offlineBox = await Hive.openBox('offlineOrders');
    await offlineBox.put(orderId, orderData);

    for (final item in processedItems) {
      CartDatabaseManager().deleteCartItem(item);
    }

    setState(() {
      widget.productsController.cartItems
          .removeWhere((item) => processedItems.contains(item));
      widget.productsController.orderItems = widget.productsController.cartItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .toList();
      widget.productsController.preorderItems = widget
          .productsController.cartItems
          .where((item) => item.detail.stock == 0)
          .toList();
    });

    // Update cached drafts after offline save
    try {
      final apiService = ApiService();
      final customerId = widget.productsController.selectedCustomerId.value;
      final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

      final now = DateTime.now();
      final startDate = DateTime(now.year, 1, 1);
      final endDate = DateTime(now.year, 12 + 1, 0);

      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      // Determine order type based on _selectedValue
      String orderType;
      switch (_selectedValue) {
        case 'Sale Order':
          orderType = 'sale_order';
          break;
        case 'Quick Sale':
          orderType = 'quick_sale';
          break;
        case 'Booking':
          orderType = 'booking';
          break;
        case 'Estimate':
          orderType = 'estimate';
          break;
        default:
          orderType = 'draft';
      }

      // For offline orders, we don't have a cart ID yet, so we'll use the order ID
      // The actual cart ID will be assigned when the order is synced online
      await apiService.updateCachedDraftsAfterSaveAndSend(
        context,
        customerId: customerId,
        draftId: orderId,
        salesmanId: salesmanId,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        orderType: orderType,
        sentCartIds: [orderId],
        sentAmount: finalAmount,
      );
    } catch (e) {
      //
    }

    {
      String checkCustomerId = customeController.customerId.isNotEmpty
          ? customeController.customerId.value
          : widget.productsController.selectedCustomerId.value;

      // Get remaining items that were not processed (not in the current order)
      List<CartItem> remainingItems = widget.productsController.cartItems
          .where((item) => !processedItems.contains(item))
          .toList();

      var offlineDraftsBox = await Hive.openBox('offlineDrafts');
      List<dynamic> drafts =
          offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
      int existingDraftIndex =
          drafts.indexWhere((draft) => draft['customer_id'] == checkCustomerId);

      if (existingDraftIndex != -1) {
        List<dynamic> detailsAfterProcessing = [];

        var newCartItems = remainingItems;

        for (var item in newCartItems) {
          item.isChecked = true;
        }

        if (newCartItems.isEmpty || newCartItems == []) {
          drafts.removeAt(existingDraftIndex);
        } else {
          drafts[existingDraftIndex]['displayData'] = {
            'customerId': checkCustomerId,
            'customerName': businessName,
            'mobileNo': mobileNo,
            'email': email,
            'imageUrl': imageUrl,
            'displayTotal': Utils().calculateSubtotal(newCartItems),
            'createdDate': DateTime.now().toIso8601String(),
          };

          for (var detail in newCartItems) {
            final bool isBulkDetail = (detail.detail.bulkId != null &&
                    detail.detail.bulkId!.isNotEmpty) ||
                (detail.detail.saleBy == 'Bulk' || detail.detail.packtype == 'Bulk') ||
                (detail.detail.bulkDiscount != null && detail.detail.bulkDiscount! > 0) ||
                (detail.detail.bulkDiscountAmount != null && detail.detail.bulkDiscountAmount! > 0);

            detailsAfterProcessing.add({
              'product_id': detail.detail.productId ?? '',
              'variant_id': detail.detail.variationId ?? '',
              'pack': detail.detail.saleBy == 'Pack'
                  ? detail.detail.pieces.toString()
                  : detail.detail.count.toString(),
              'packType': detail.detail.saleBy == 'Pack' ? 'Pack' : (isBulkDetail ? 'Bulk' : 'Pcs'),
              'price': detail.detail.sellPrice.toString(),
              'discount': isBulkDetail ? 0 : detail.detail.discount,
              'quantity': detail.detail.count.toInt(),
              'variant_name': detail.detail.variationName ?? '',
              'stock': detail.detail.stock ?? 0,
              'unitType': detail.detail.unitType,
              'product_name': detail.detail.productName,
              'tax': detail.detail.tax,
              'incl_tax': detail.detail.inclTax,
              'pieces': detail.detail.pieces,
              'cat_tax': getStoredTaxFromCache(detail.detail.productId ?? ''),
              'tax_amount': detail.detail.tax ?? 0.0,
              'total_tax': detail.detail.totaltax ?? 0.0,
              'unit_tax': detail.detail.unitTax ?? 0.0,
              'cat_id': 0,
              'bulk_id': detail.detail.bulkId,
              'is_bulk': isBulkDetail,
              'bulk_discount': detail.detail.bulkDiscount,
              'discount_percentage': detail.detail.bulkDiscount,
              'bulk_discount_amount': detail.detail.bulkDiscountAmount,
              'bulk_tax': detail.detail.bulkTax,
            });
          }

          drafts[existingDraftIndex]['details'] = detailsAfterProcessing;
        }

        await offlineDraftsBox.put('drafts', drafts);
      }
    }
  }

  Future<dynamic> deleteConfirmationDialogue(
      BuildContext context, CartItem groupedItem, List<CartItem> groupedItems) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actionsPadding:
              const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          title: CustomText(
            content: 'Delete ${groupedItem.detail.variationName}..?'.tr,
            fontWeight: FontWeight.w700,
          ),
          actions: [
            Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  content: 'Are you sure you want to delete..?'.tr,
                  fontSize: 17,
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF727CF5), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'No'.tr,
                      style: const TextStyle(
                        color: Color(0xFF727CF5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final provider = Provider.of<CustomersProvider>(context,
                          listen: false);
                      print('delete variant called');
                      await _deleteVariant(groupedItem, provider);
                      widget.productsController.isCartModified.value = true;
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Yes'.tr,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<dynamic> showVariantDeleteDialog(
      BuildContext context, String productName, bool isPreOrder, bool isDraft) {
    String customerId = widget.customerId ?? '';
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actionsPadding:
              const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  content: 'Delete $productName..?'.tr,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: CustomText(
            content: 'Are you sure you want to delete this item?'.tr,
            fontSize: 15,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF727CF5), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        color: Color(0xFF727CF5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final provider = Provider.of<CustomersProvider>(context,
                          listen: false);
                      _deleteProduct(productName, isPreorder: isPreOrder);
                      await provider.updateCartCount(customerId);
                      Navigator.pop(context);
                      widget.productsController.isCartModified.value = true;
                      showCustomToastDisplay(
                        context,
                        'Item deleted successfully',
                        Colors.green,
                        Icons.check,
                      );
                    },
                    child: Text(
                      'Confirm'.tr,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> _deleteVariant(
      CartItem variantToDelete, CustomersProvider provider) async {
    final String customerId = widget.customerId ?? '';
    // 1. Remove from local controller lists FIRST
    widget.productsController.cartItems.removeWhere((item) =>
        (item.detail.variationId == variantToDelete.detail.variationId ||
            (item.productName == variantToDelete.productName &&
                item.detail.variationName ==
                    variantToDelete.detail.variationName)) &&
        item.isPack == variantToDelete.isPack &&
        item.isPromo == variantToDelete.isPromo);

    // 2. Actually delete from the database
    await CartDatabaseManager().deleteCartItem(variantToDelete);

    // 3. Rebuild order and preorder lists
    List<CartItem> orderItems = widget.productsController.cartItems
        .where((item) => (item.detail.stock ?? 0) > 0)
        .toList();
    List<CartItem> preorderItems = widget.productsController.cartItems
        .where((item) => item.detail.stock == 0)
        .toList();

    // 4. Update Controller State
    widget.productsController.orderItems = orderItems;
    widget.productsController.preorderItems = preorderItems;

    // 5. Recalculate Totals
    orderSubtotal = Utils().calculateSubtotal(orderItems);
    orderTaxe = Utils().calculateTotalTax(orderItems);
    preorderSubtotal = Utils().calculateSubtotal(preorderItems);
    preorderTax = Utils().calculateTotalTax(preorderItems);

    await provider.updateCartCount(customerId);
    _maybeClearFlatDiscountForCustomer(customerId);
    if (mounted) {
      setState(() {});
    }
  }

  Container productQuantityManager(CartItem cartItem, String sellPrice,
      double fontSize, double availableWidth) {
    double padding = availableWidth > 400 ? 6 : 3;
    ProductsController productsController = Get.find<ProductsController>();

    final bool isTieredDiscount = (cartItem.isPromo == true) &&
        (cartItem.detail.initialCount != null &&
            cartItem.detail.initialCount! > 1);

    final int tierStep = cartItem.detail.initialCount?.toInt() ?? 1;

    // --- Helper function to update Item values locally ---
    void updateItemCalculations() {
      // 1. Calculate Base Amount (Original Pre-Discount & Pre-Edit)
      double originalUnitPrice =
          double.tryParse(cartItem.detail.sellPrice?.toString() ?? '') ?? 0.0;
      if (originalUnitPrice <= 0.0) {
        originalUnitPrice =
            double.tryParse(cartItem.detail.price?.toString() ?? '') ?? 0.0;
      }

      int qtyFactor =
          (cartItem.detail.packtype == 'Pack' || cartItem.isPack == true)
              ? (cartItem.detail.pieces?.toInt() ?? 1)
              : 1;

      final double? apiSellingPackPrice = (cartItem.isPack == true ||
              cartItem.detail.packtype == 'Pack')
          ? (double.tryParse(
              cartItem.detail.sellingPackPrice?.toString() ?? ''))
          : null;

      final double originalBaseSellAmount =
          (apiSellingPackPrice != null && apiSellingPackPrice > 0)
              ? apiSellingPackPrice
              : originalUnitPrice * qtyFactor;

      double currentBaseSellAmount = originalBaseSellAmount;
      if (cartItem.detail.displayPrice != null) {
        final double editedUnitPrice =
            double.tryParse(cartItem.detail.displayPrice!) ?? originalUnitPrice;
        currentBaseSellAmount = (apiSellingPackPrice != null && apiSellingPackPrice > 0)
            ? (double.tryParse(cartItem.detail.displayPrice!) ?? originalBaseSellAmount)
            : editedUnitPrice * qtyFactor;
      }

      double productQuantity = cartItem.detail.count.toDouble();

      // 2. Edit-price discount (difference between original and edited price)
      double editPriceDiscountAmount = 0.0;
      if (cartItem.detail.displayPrice != null) {
        final double diff = originalBaseSellAmount - currentBaseSellAmount;
        if (diff > 0) {
          editPriceDiscountAmount = diff * productQuantity;
        }
      }

      // 3. Calculate Discount Percentages
      double customerDisc =
          (cartItem.CustomerDiscount != null && cartItem.CustomerDiscount! > 0)
              ? cartItem.CustomerDiscount!
              : 0.0;
      num tieredDisc =
          (cartItem.tieredDiscount != null && cartItem.tieredDiscount! > 0)
              ? cartItem.tieredDiscount!
              : 0;

      double totalDiscountPercent = customerDisc + tieredDisc;

      // 4. Total Discount Amount
      double percentageDiscountAmount =
          (originalBaseSellAmount * productQuantity) * (totalDiscountPercent / 100.0);

      double totalDiscountAmount = percentageDiscountAmount + editPriceDiscountAmount;

      cartItem.totalDiscountAmount = totalDiscountAmount;

      // 5. Calculate Price After Discount
      double priceAfterDiscount =
          (originalBaseSellAmount * productQuantity) - totalDiscountAmount;
      if (priceAfterDiscount < 0) priceAfterDiscount = 0.0;

      // 6. Calculate Tax
      double bulkTaxPercentage = (cartItem.detail.bulkTax ?? 0).toDouble();
      double taxPercentage = bulkTaxPercentage > 0
          ? bulkTaxPercentage
          : (cartItem.catTax ?? 0).toDouble();

      double tax = 0.0;
      if (cartItem.detail.inclTax == "N.A") {
        tax = 0.0;
      } else if (taxPercentage > 0) {
        tax = priceAfterDiscount * (taxPercentage / 100);
      } else {
        double unitTax = (cartItem.detail.tax ?? 0).toDouble();
        double totalUnits = cartItem.detail.count.toDouble();
        if (cartItem.isPack == true || cartItem.detail.packtype == 'Pack') {
          totalUnits = totalUnits * (cartItem.detail.pieces ?? 1);
        }
        tax = totalUnits > 0
            ? (unitTax * totalUnits * (1 - (totalDiscountPercent / 100.0)))
            : 0.0;
      }

      cartItem.taxAmount = tax;
      if (cartItem.detail.inclTax == "incl_tax" || cartItem.detail.inclTax == "N.A") {
        cartItem.finalPrice = priceAfterDiscount;
        cartItem.totalPrice = (originalBaseSellAmount * productQuantity);
      } else {
        cartItem.finalPrice = priceAfterDiscount + tax;
        cartItem.totalPrice = (originalBaseSellAmount * productQuantity) + tax;
      }
    }

    return Container(
      width: availableWidth > 400 ? 110 : 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final bool isMinCount = isTieredDiscount
                    ? (cartItem.detail.count <= tierStep)
                    : (cartItem.detail.count <= 1);
                if (isMinCount) return;

                setState(() {
                  if (isTieredDiscount) {
                    if (cartItem.detail.count > tierStep) {
                      cartItem.detail.count -= tierStep;
                    }
                  } else {
                    if (cartItem.detail.count > 1) {
                      cartItem.detail.count--;
                    }
                  }

                  cartItem.totalPrice = Utils().calculateTotalPrice(
                    cartItem,
                    cartItem.detail.count.toInt(),
                  );

                  updateItemCalculations();
                  calculateAmounts();

                  CartDatabaseManager().updateCart(cartItem);
                  CartDatabaseManager().getCartItems(cartItem.customerId ?? '');
                  widget.productsController.isCartModified.value = true;
                });
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: (isTieredDiscount
                          ? (cartItem.detail.count > tierStep)
                          : (cartItem.detail.count > 1))
                      ? primaryColor
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  color: (isTieredDiscount
                          ? (cartItem.detail.count > tierStep)
                          : (cartItem.detail.count > 1))
                      ? Colors.white
                      : Colors.grey.shade500,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Center(
              child: CustomText(
                content: cartItem.detail.count.toStringAsFixed(0),
                fontSize: fontSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isTieredDiscount) {
                    cartItem.detail.count += tierStep;
                  } else {
                    cartItem.detail.count++;
                  }

                  cartItem.totalPrice = Utils().calculateTotalPrice(
                    cartItem,
                    cartItem.detail.count.toInt(),
                  );

                  updateItemCalculations();
                  calculateAmounts();

                  CartDatabaseManager().updateCart(cartItem);
                  widget.productsController.isCartModified.value = true;
                });
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void calculateAmounts() {
    setState(() {
      if (isOrder) {
        orderSubtotal =
            Utils().calculateSubtotal(widget.productsController.orderItems);
        // orderTax =
        //     Utils().calculateTotalTax(widget.productsController.orderItems);
        totalDiscount =
            widget.productsController.orderItems.fold(0.0, (sum, item) {
          if (item.isChecked != true) return sum;
          return sum + (item.totalDiscountAmount ?? 0.0);
        });
        // totalDiscount = Utils()
        //     .calculateTotalDiscount(widget.productsController.orderItems);
      } else {
        preorderSubtotal =
            Utils().calculateSubtotal(widget.productsController.preorderItems);
        preorderTax =
            Utils().calculateTotalTax(widget.productsController.preorderItems);
        totalDiscountPreorder = Utils()
            .calculateTotalDiscount(widget.productsController.preorderItems);
      }
    });
  }

  void _clearCartItem(List<CartItem> cartItem, String customerId) async {
    for (final item in cartItem) {
      CartDatabaseManager().deleteCartItem(item);
    }
    setState(() {
      widget.productsController.cartItems
          .removeWhere((item) => cartItem.contains(item));
      widget.productsController.orderItems = widget.productsController.cartItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .toList();
      widget.productsController.preorderItems = widget
          .productsController.cartItems
          .where((item) => item.detail.stock == 0)
          .toList();
    });
    // Clear flat discount if its source items are gone
    _maybeClearFlatDiscountForCustomer(customerId);
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    cartProvider.getCartItemCounts(customerId);
  }

  void _deleteProduct(String productName, {bool isPreorder = false}) {
    setState(() {
      final variantsToDelete =
          widget.productsController.cartItems.where((item) {
        final isMatchingProduct = item.productName == productName;
        final isPreorderItem = item.detail.stock == 0;
        final isOrderItem = (item.detail.stock ?? 0) > 0;
        return isMatchingProduct &&
            ((isPreorder && isPreorderItem) || (!isPreorder && isOrderItem));
      }).toList();

      if (variantsToDelete.isEmpty) {
        return;
      }

      // 1. Delete all matching variants from DB
      for (var variant in variantsToDelete) {
        CartDatabaseManager().deleteCartItem(variant);
      }

      // 2. Remove from controller list
      widget.productsController.cartItems.removeWhere((item) =>
          item.productName == productName &&
          ((isPreorder && item.detail.stock == 0) ||
              (!isPreorder && (item.detail.stock ?? 0) > 0)));

      // 3. Rebuild Lists
      final orderItems = widget.productsController.cartItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .toList();
      final preorderItems = widget.productsController.cartItems
          .where((item) => item.detail.stock == 0)
          .toList();

      widget.productsController.orderItems = orderItems;
      widget.productsController.preorderItems = preorderItems;

      // 4. Recalculate
      orderSubtotal = Utils().calculateSubtotal(orderItems);
      orderTaxe = Utils().calculateTotalTax(orderItems);
      preorderSubtotal = Utils().calculateSubtotal(preorderItems);
      preorderTax = Utils().calculateTotalTax(preorderItems);
    });
  }
  //  void _deleteProduct(String productName, {bool isPreorder = false}) {
  //   setState(() {
  //     final variantsToDelete =
  //         widget.productsController.cartItems.where((item) {
  //       final isMatchingProduct = item.productName == productName;
  //       final isPreorderItem = item.detail.stock == 0;
  //       final isOrderItem = (item.detail.stock ?? 0) > 0;
  //       return isMatchingProduct &&
  //           ((isPreorder && isPreorderItem) || (!isPreorder && isOrderItem));
  //     }).toList();

  //     if (variantsToDelete.isEmpty) {
  //       return;
  //     }

  //     for (var variant in variantsToDelete) {
  //       variant.detail.count = 0;
  //       CartDatabaseManager().deleteCartItem(variant);
  //       CartDatabaseManager().updateCart(variant);
  //     }
  //     widget.productsController.cartItems.removeWhere((item) =>
  //         item.productName == productName &&
  //         ((isPreorder && item.detail.stock == 0) ||
  //             (!isPreorder && (item.detail.stock ?? 0) > 0)));
  //     final orderItems = widget.productsController.cartItems
  //         .where((item) => (item.detail.stock ?? 0) > 0)
  //         .toList();
  //     final preorderItems = widget.productsController.cartItems
  //         .where((item) => item.detail.stock == 0)
  //         .toList();

  //     orderSubtotal = Utils().calculateSubtotal(orderItems);
  //     orderTaxe = Utils().calculateTotalTax(orderItems);
  //     preorderSubtotal = Utils().calculateSubtotal(preorderItems);
  //     preorderTax = Utils().calculateTotalTax(preorderItems);
  //   });
  // }

  // void _deleteProduct(String productName, {bool isPreorder = false}) {
  //   setState(() {
  //     final variantsToDelete =
  //         widget.productsController.cartItems.where((item) {
  //       final isMatchingProduct = item.productName == productName;
  //       final isPreorderItem = item.detail.stock == 0;
  //       final isOrderItem = (item.detail.stock ?? 0) > 0;
  //       return isMatchingProduct &&
  //           ((isPreorder && isPreorderItem) || (!isPreorder && isOrderItem));
  //     }).toList();

  //     if (variantsToDelete.isEmpty) {
  //       return;
  //     }

  //     for (var variant in variantsToDelete) {
  //       variant.detail.count = 0;
  //       CartDatabaseManager().deleteCartItem(variant);
  //       CartDatabaseManager().updateCart(variant);
  //     }
  //     widget.productsController.cartItems.removeWhere((item) =>
  //         item.productName == productName &&
  //         ((isPreorder && item.detail.stock == 0) ||
  //             (!isPreorder && (item.detail.stock ?? 0) > 0)));
  //     final orderItems = widget.productsController.cartItems
  //         .where((item) => (item.detail.stock ?? 0) > 0)
  //         .toList();
  //     final preorderItems = widget.productsController.cartItems
  //         .where((item) => item.detail.stock == 0)
  //         .toList();

  //     orderSubtotal = Utils().calculateSubtotal(orderItems);
  //     orderTax = Utils().calculateTotalTax(orderItems);
  //     preorderSubtotal = Utils().calculateSubtotal(preorderItems);
  //     preorderTax = Utils().calculateTotalTax(preorderItems);
  //   });

  //   // Clear flat discount if its source items are gone
  //   final String cid =
  //       widget.customerId ?? widget.productsController.selectedCustomerId.value;
  //   _maybeClearFlatDiscountForCustomer(cid);
  // }

  /// Clears cart-level flat discount for a customer if no remaining items
  /// are associated with the flat discount promo (based on promoMsg marker).
  void _maybeClearFlatDiscountForCustomer(String customerId) {
    try {
      final hasFlatPromoItems = widget.productsController.cartItems.any((item) {
        final msg = item.promoMsg?.toLowerCase() ?? '';
        return msg.contains('flat discount');
      });
      if (!hasFlatPromoItems) {
        if (widget.productsController.flatDiscountByCustomer
            .containsKey(customerId)) {
          widget.productsController.flatDiscountByCustomer.remove(customerId);
          setState(() {});
        }
      }
    } catch (_) {}
  }

  Map<String, dynamic> castToStringDynamic(Map<dynamic, dynamic> input) {
    return input.map((key, value) {
      final newKey = key is String ? key : key.toString();
      final newValue = value is Map
          ? castToStringDynamic(Map<dynamic, dynamic>.from(value))
          : (value is List
              ? value
                  .map((e) => e is Map
                      ? castToStringDynamic(Map<dynamic, dynamic>.from(e))
                      : e)
                  .toList()
              : value);
      return MapEntry<String, dynamic>(newKey, newValue);
    });
  }
}

Future<bool?> showCreditUsageDialog({
  required BuildContext context,
  required dynamic availableCredit,
  required double amountToPayBeforeCredit,
}) async {
  final double availCred =
      (num.tryParse(availableCredit?.toString() ?? '0') ?? 0).toDouble();
  final double amtBefore = amountToPayBeforeCredit.toDouble();

  // Calculate how much credit would be used if applied
  final double creditToBeUsed =
      amtBefore > availCred ? availCred : amtBefore;

  final double amountAfterCredit =
      (amtBefore - creditToBeUsed).clamp(0.0, double.infinity);

  return await showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Apply Customer Credit?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        content: SizedBox(
          width: 540,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Credit & Order Total Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Available Credit: ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          formatAmount(availableCredit),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order Total: ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          formatAmount(amountToPayBeforeCredit),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Visual Summary Card in Green
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 14,
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(
                              text: "After applying the credit, your total payable amount will be:\u00A0",
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Text(
                                formatAmount(amountAfterCredit),
                                style: const TextStyle(
                                  fontFamily: 'Poppins_Regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button
          OutlinedButton(
            onPressed: () => Navigator.pop(context, null),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Skip Credit Button
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text(
              "Pay without Credit",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFEFF6FF),
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Pay with Credit Button
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle_rounded, size: 19, color: Colors.white),
            label: Text(
              amountAfterCredit == 0 ? "Pay with Credit" : "Apply Credit",
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Future<bool> showCreditUsageDialog({
//   required BuildContext context,
//   required  availableCredit,
//   required double amountToPayBeforeCredit,
// }) async {
//   // Default: auto-check if credit can fully or partially cover the amount
//   bool useCredit = availableCredit > 0 && amountToPayBeforeCredit > 0;

//   final bool? result = await showDialog<bool>(
//     context: context,
//     barrierDismissible: false, // User must choose
//     builder: (BuildContext dialogContext) {
//       return StatefulBuilder(
//         builder: (context, StateSetter setState) {
//           // Calculate how much credit will actually be used
//           final double creditToBeUsed = useCredit
//               ? (amountToPayBeforeCredit > availableCredit
//                   ? availableCredit
//                   : amountToPayBeforeCredit)
//               : 0.0;

//           final double amountAfterCredit = (amountToPayBeforeCredit - creditToBeUsed).clamp(0.0, double.infinity);

//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: const Text(
//               "Apply Customer Credit?",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Available Credit
//                 Row(
//                   children: [
//                     const Text("Available Credit: ", style: TextStyle(fontWeight: FontWeight.w600)),
//                     Text(
//                       formatAmount(availableCredit),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 // Order Amount Before Credit
//                 Row(
//                   children: [
//                     const Text("Order Amount: ", style: TextStyle(fontWeight: FontWeight.w600)),
//                     Text(
//                       formatAmount(amountToPayBeforeCredit),
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Checkbox with live preview
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Column(
//                     children: [
//                       CheckboxListTile(
//                         dense: true,
//                         contentPadding: EdgeInsets.zero,
//                         controlAffinity: ListTileControlAffinity.leading,
//                         title: Text(
//                           useCredit
//                               ? "Use Credit – Deduct ${formatAmount(creditToBeUsed)}"
//                               : "Do not use credit",
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                         subtitle: useCredit
//                             ? Text(
//                                 "You will pay: ${formatAmount(amountAfterCredit)}",
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   color: amountAfterCredit == 0 ? Colors.green : Colors.blue[700],
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               )
//                             : null,
//                         value: useCredit,
//                         activeColor: Colors.green,
//                         onChanged: availableCredit <= 0
//                             ? null
//                             : (bool? value) {
//                                 setState(() {
//                                   useCredit = value ?? false;
//                                 });
//                               },
//                       ),
//                     ],
//                   ),
//                 ),

//                 if (amountAfterCredit == 0 && useCredit)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.celebration, color: Colors.green),
//                         const SizedBox(width: 8),
//                         Text(
//                           "Full amount covered by credit!",
//                           style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//             actionsAlignment: MainAxisAlignment.spaceBetween,
//             actions: [
//               TextButton(
//                 style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
//                 onPressed: () => Navigator.pop(dialogContext, false),
//                 child: const Text("Skip Credit", style: TextStyle(fontSize: 16)),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: useCredit ? Colors.green : Colors.blue,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Navigator.pop(dialogContext, useCredit),
//                 child: Text(
//                   useCredit
//                       ? (amountAfterCredit == 0 ? "Pay with Credit" : "Apply & Pay ${formatAmount(amountAfterCredit)}")
//                       : "Pay Full ${formatAmount(amountToPayBeforeCredit)}",
//                   style: const TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );

//   // Return true/false based on user choice
//   return result ?? false;
// }

class CartTextFields extends StatelessWidget {
  const CartTextFields({
    super.key,
    required this.controller,
    required this.text,
  });

  final TextEditingController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
