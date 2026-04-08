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
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
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
              final cartItem = CartItem(
                detail: Detail(
                  productId: detail['product_id'],
                  variationId: detail['variant_id'],
                  sellPrice: detail['price'],
                  discount: detail['discount'],
                  count: (detail['quantity'] as num?)?.toDouble() ?? 0,
                  pieces: int.tryParse(detail['pack'] ?? '0'),
                  variationName: detail['variant_name'],
                  saleBy: detail['packType'],
                  stock: detail['stock'] ?? 0,
                  unitType: detail['unitType'],
                ),
                productName: detail['variant_name'] ?? '',
                totalPrice:
                    double.tryParse(detail['price']?.toString() ?? '0') ?? 0,
                isPack: detail['packType'] == 'Pack',
                customerId: customerId,
                salesmanId: salesmanId,
                catId: 0,
              );
              await draftBox.add(cartItem);
            }
          }
        }
      }

      widget.productsController.cartItems = await CartDatabaseManager()
          .getCartItems(customerId, draftsOnly: isDraftView);

          for (final item in widget.productsController.cartItems) {
        // 1. Calculate Base Sell Amount (Unit Price * Pieces per Pack)
        double sellPrice = double.tryParse(item.detail.sellPrice ?? '0') ?? 0.0;
        double pieces = (item.isPack == true || item.detail.packtype == 'Pack')
            ? (item.detail.pieces ?? 1).toDouble()
            : 1.0;
        
        // This matches your 'baseSellAmount' from the correct file
        double baseSellAmount = sellPrice * pieces; 
        
        // 2. Get Quantity
        double productQuantity = item.detail.count.toDouble();

        // 3. Get Discount Percentages
        double customerDiscount = (item.CustomerDiscount != null && item.CustomerDiscount! > 0)
            ? item.CustomerDiscount!
            : 0.0;
        
        num tieredDiscount = (item.tieredDiscount != null && item.tieredDiscount! > 0)
            ? item.tieredDiscount!
            : 0;
        num bogoDiscount = (item.bogoDiscount != null && item.bogoDiscount! > 0)
            ? item.bogoDiscount!
            : 0;
        num? bulkDiscount = (item.detail.bulkDiscount != null && item.detail.bulkDiscount! > 0)
            ? item.detail.bulkDiscount
            : 0;
        print('bulk discount in load cart items:${item.detail.bulkDiscount}');

        double totalDiscountPercent = customerDiscount + tieredDiscount + bogoDiscount + bulkDiscount!;
       

        // 4. Calculate Total Discount Amount
        // Logic: (Base Price * Quantity) * Percentage
        // 4. Calculate Total Discount Amount
        // Logic: (Base Price * Quantity) * Percentage
        double totalDiscountAmount = (baseSellAmount * productQuantity) * (totalDiscountPercent / 100.0);
        
        // 👇 ADD THESE LINES TO INCLUDE FIXED DISCOUNTS 👇
        // double flatDiscount = (item.flatDiscount ?? 0).toDouble();
        double bulkDiscountAmt = (item.detail.bulkDiscountAmount ?? 0).toDouble();
        
        // Add them to the total discount amount
        totalDiscountAmount +=   bulkDiscountAmt;
        
        item.totalDiscountAmount = totalDiscountAmount ;

        // 5. Calculate Price After Discount
        double priceAfterDiscount = (baseSellAmount * productQuantity) - totalDiscountAmount;
        // double totalDiscountAmount = (baseSellAmount * productQuantity) * (totalDiscountPercent / 100.0);
        
        // item.totalDiscountAmount = totalDiscountAmount;

        // // 5. Calculate Price After Discount
        // double priceAfterDiscount = (baseSellAmount * productQuantity) - totalDiscountAmount;
      print('price after discount in the load cart items:$priceAfterDiscount');
        // 6. Calculate Tax
        double bulkTaxPercentage = (item.detail.bulkTax ?? 0).toDouble();
        print('bulk tax perecnatge in the load cart items:$bulkTaxPercentage');
        double taxPercentage = bulkTaxPercentage > 0 
          ? bulkTaxPercentage 
          : (item.catTax ?? 0).toDouble();
        print('tax perrecntage in the load cart items:$taxPercentage');
        double calculatedTax = 0.0;

        if (taxPercentage > 0) {
          // Scenario A: Use Category Tax Percentage on the Discounted Price
          calculatedTax = priceAfterDiscount * (taxPercentage / 100);
          print('tax in the if case in the load cart items:$calculatedTax');
        } else {
          // Scenario B: Fallback to Unit Tax (for Promo Variants)
          // We must apply the discount to the unit tax as well
          double totalRawTax = (item.detail.tax ?? 0).toDouble() * productQuantity * pieces;
          print('tala row tax:$totalRawTax');
          print('itemn.detail.tax:${item.detail.tax}');
          print('producrt quantity:$productQuantity');
          print('pieses:$pieces');
          // Apply the same discount percentage to the tax
          // If discount is 10%, we only charge 90% of the tax
      print('total discountperecentage in the cart load :$totalDiscountPercent');
          calculatedTax = totalRawTax * (1 - (totalDiscountPercent / 100.0));
          print('calculated tax in the else case in the load cart items:$calculatedTax');
        }
        if (bulkTaxPercentage <= 0) {
          item.taxAmount = calculatedTax;
        } else {
          print('Skipped assigning item.taxAmount because bulk tax is active');
          // item.taxAmount will remain null or 0, forcing the UI to calculate it dynamically
        }
        
        // item.taxAmount = calculatedTax;

        // 7. Final Price Logic (Inclusive vs Exclusive)
        if (item.detail.inclTax == "incl_tax") {
          item.finalPrice = priceAfterDiscount;
          print('final price in load cart items:${ item.finalPrice}');
          // For consistency with other parts of the app that rely on totalPrice
          item.totalPrice = (baseSellAmount * productQuantity); 
        } else {
          item.finalPrice = priceAfterDiscount + calculatedTax;
          item.totalPrice = (baseSellAmount * productQuantity) + calculatedTax;
        }
      }

      await setCartToOrderAndPreorder();

      // Helper to process items and set taxAmount
      void processItems(List<CartItem> items) {
        for (var item in items) {
          item.isChecked = true; // Required by your fold function

          final count = item.detail.count;
          final pieces = (item.isPack == true || item.detail.packtype == 'Pack')
              ? (item.detail.pieces ?? 1).toDouble()
              : 1.0;
          final sellPrice =
              double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
          final unitTax = item.detail.tax?.toDouble() ?? 0.0;
          final inclTax = item.detail.inclTax;

          // 1. Calculate the taxAmount for the fold function to use
          // taxAmount = unitTax * total Quantity
          // item.taxAmount = unitTax * pieces * count;

          // 2. Calculate Total Price (Base Price + Tax if not inclusive)
          double basePrice = count * pieces * sellPrice;
          if (inclTax != 'incl_tax') {
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
            totalDiscount = widget.productsController.orderItems.fold(0.0, (sum, item) {
          if (item.isChecked != true) return sum;
          return sum + (item.totalDiscountAmount ?? 0.0);
        });

        _isLoading = false;
      });

      if (widget.productsController.orderItems.isNotEmpty) {
        isOrder = true;
        _selectedValue = _options[0];
      } else if (widget.productsController.preorderItems.isNotEmpty) {
        isOrder = false;
        _selectedValue = _options[2];
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
    double dialogHeight;
    if (width > 1200) {
      dialogHeight = height * 0.8;
    } else if (width > 650) {
      dialogHeight = height * 0.7;
    } else {
      dialogHeight = height * 0.5;
    }
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double availableHeight = constraints.maxHeight;
          double fontSize = availableWidth / 50;
          double rowHeight = availableHeight / 14;
          // var useCredit = false.obs; // Reactive boolean for checkbox
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: availableWidth,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GetBuilder<CustomerCreditController>(
                    builder: (creditCtrl) {
                      // Auto-fetch credit when dialog opens (only if not already loaded)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final customerId =
                            widget.productsController.selectedCustomerId.value;

                        if (customerId.isNotEmpty &&
                                creditCtrl.allCustomers.isEmpty || // First time
                            !creditCtrl.allCustomers
                                .any((c) => c.customerId == customerId)) {
                          creditCtrl.fetchCustomerCredit(
                            companyId:
                                SessionHelper.loginSavedData?.company_id ?? 1,
                            salesmanId:
                                SessionHelper.loginSavedData?.salesmanId,
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
                        creditWidget: Obx(() {
                          final latestCredit =
                              customerCreditController.customerCredit.value;

                          return isLoading
                              ?  Text(
                                  'Credit: Loading...'.tr,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: fontFamilyName,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                       TextSpan(
                                        text: 'Credit: '.tr,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: formatAmount(
                                            latestCredit.toStringAsFixed(2)),
                                        style: TextStyle(
                                          color: latestCredit > 0
                                              ? Colors.green.shade700
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        }),
                      );
                    },
                  ),
                  if (widget.productsController.orderItems.isNotEmpty ||
                      widget.productsController.preorderItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            if (widget.productsController.orderItems.isNotEmpty)
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                        color: isOrder ? primaryColor : white,
                                        borderRadius: widget.productsController
                                                .preorderItems.isNotEmpty
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                              )
                                            : BorderRadius.circular(20),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isOrder = true;
                                            _selectedValue = _options[0];
                                          });
                                          setOptions();
                                        },
                                        child: Center(
                                          child: CustomText(
                                            content: 'ORDERS'.tr,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                isOrder ? white : primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${widget.productsController.orderItems.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget
                                .productsController.preorderItems.isNotEmpty)
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                        color: !isOrder ? primaryColor : white,
                                        borderRadius: widget.productsController
                                                .orderItems.isNotEmpty
                                            ? const BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                              )
                                            : BorderRadius.circular(20),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isOrder = false;
                                            _selectedValue = _options[2];
                                          });
                                          setOptions();
                                        },
                                        child: Center(
                                          child: CustomText(
                                            content: 'BOOKINGS',
                                            fontWeight: FontWeight.w700,
                                            color:
                                                isOrder ? primaryColor : white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${widget.productsController.preorderItems.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(),
                  ],
                  if (isOrder) ...[
                    (widget.productsController.orderItems.isEmpty)
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: CustomText(
                                content: 'Your cart is empty.',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                          )
                        : Flexible(
                            child: SizedBox(
                              height: dialogHeight * 0.5,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      controller: _scrollController4,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController1,
                                        child: SizedBox(
                                          height: double.maxFinite,
                                          width: isPhonePortrait(context)
                                              ? fullScreenWidth(context) * 2
                                              : fullScreenWidth(context) * 1.15,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: widget
                                                      .productsController
                                                      .orderItems
                                                      .where((item) =>
                                                          (item.detail.stock ??
                                                              0) >
                                                          0)
                                                      .map((item) =>
                                                          item.productName)
                                                      .toSet()
                                                      .toList()
                                                      .map((productName) {
                                                    List<CartItem> groupedItems = widget
                                                        .productsController
                                                        .orderItems
                                                        .where((item) =>
                                                            item.productName ==
                                                                productName &&
                                                            (item.detail.stock ??
                                                                    0) >
                                                                0)
                                                        .toList();

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child: _buildGroupedItems(
                                                        productName:
                                                            productName,
                                                        groupedItems:
                                                            groupedItems,
                                                        availableWidth:
                                                            availableWidth,
                                                        fontSize: fontSize,
                                                        rowHeight: rowHeight,
                                                        context: context,
                                                        productQuantityManager:
                                                            productQuantityManager,
                                                        deleteConfirmationDialogue:
                                                            deleteConfirmationDialogue,
                                                        isPreOrder: false,
                                                        calCulateAmount:
                                                            calculateAmounts,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0,
                                    child: ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thumbColor: WidgetStateProperty
                                              .resolveWith<Color>((states) {
                                            if (states.contains(
                                                WidgetState.dragged)) {
                                              return primaryColor
                                                  .withOpacity(0.5);
                                            }
                                            return primaryColor
                                                .withOpacity(0.5);
                                          }),
                                          trackColor: WidgetStateProperty.all(
                                              primaryColor.withOpacity(0.2)),
                                          trackBorderColor:
                                              WidgetStateProperty.all(
                                                  primaryColor
                                                      .withOpacity(0.2)),
                                          thickness:
                                              WidgetStateProperty.all(10),
                                          radius: const Radius.circular(10),
                                          minThumbLength: 50,
                                          thumbVisibility:
                                              WidgetStateProperty.all(true),
                                          trackVisibility:
                                              WidgetStateProperty.all(true),
                                        ),
                                        child: Scrollbar(
                                            thickness: 6,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            controller: _scrollController3,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              controller: _scrollController3,
                                              child: Column(
                                                children: widget
                                                    .productsController
                                                    .orderItems
                                                    .where((item) =>
                                                        (item.detail.stock ??
                                                            0) >
                                                        0)
                                                    .map((item) =>
                                                        item.productName)
                                                    .toSet()
                                                    .toList()
                                                    .map((productName) {
                                                  List<CartItem> groupedItems =
                                                      widget.productsController
                                                          .orderItems
                                                          .where((item) =>
                                                              item.productName ==
                                                                  productName &&
                                                              (item.detail.stock ??
                                                                      0) >
                                                                  0)
                                                          .toList();

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 20),
                                                    child: _buildGroupedItems(
                                                      productName: productName,
                                                      groupedItems:
                                                          groupedItems,
                                                      availableWidth:
                                                          availableWidth,
                                                      fontSize: fontSize,
                                                      rowHeight: rowHeight,
                                                      context: context,
                                                      productQuantityManager:
                                                          productQuantityManager,
                                                      deleteConfirmationDialogue:
                                                          deleteConfirmationDialogue,
                                                      isPreOrder: false,
                                                      calCulateAmount:
                                                          calculateAmounts,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.dragged)) {
                            return primaryColor.withOpacity(0.5);
                          }
                          return primaryColor.withOpacity(0.5);
                        }),
                        trackColor: WidgetStateProperty.all(
                            primaryColor.withOpacity(0.2)),
                        trackBorderColor: WidgetStateProperty.all(
                            primaryColor.withOpacity(0.2)),
                        thickness: WidgetStateProperty.all(6),
                        radius: const Radius.circular(10),
                        minThumbLength: 50,
                        thumbVisibility: WidgetStateProperty.all(true),
                        trackVisibility: WidgetStateProperty.all(true),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 6,
                        controller: _scrollController2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController2,
                          child: Container(
                            width: isPhonePortrait(context)
                                ? fullScreenWidth(context) * 2
                                : fullScreenWidth(context) * 1.15,
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      var customerCredit =
                          _customercreditctrl.customerCredit.value ?? 0.0;
                  
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      print('flat discount:$flatDisc');
                      // final double baseAmount = orderSubtotal - flatDisc;
                      double baseAmount =
                          widget.productsController.orderItems.fold(
                        0.0,
                        (sum, item) {
                          if (!item.isChecked!) return sum;
                          return sum + (item.finalPrice ?? item.totalPrice);
                        },
                      );

                      // print('base amount:$baseAmount');
                      final double finalBeforeCredit =
                          baseAmount.clamp(0.0, double.infinity);

                      // print('final before credit:$finalBeforeCredit');
                      final double payableAmount = useCredit.value
                          ? (finalBeforeCredit - customerCredit)
                              .clamp(0.0, double.infinity)
                          : finalBeforeCredit;
                      // print('payble amount:$payableAmount');
                      //thi is the portion of orders//
                      return CartTotalWidget(
                        title: 'Subtotal'.tr,
                        //  payableAmount <= 0 ? 'Amount Paid by Credit' : 'Final Payable Amount',
                        content: payableAmount,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color2:
                            payableAmount <= 0 ? Colors.green : primaryColor,
                      );
                    }),

                    const SizedBox(height: 5.0),
                    Obx(() {
  // 1. Get the flat discount (if you still want to include it)
  final String cid = widget.productsController.selectedCustomerId.value;
  final double flatDisc =
      widget.productsController.flatDiscountByCustomer[cid] ?? 0.0;

  // 2. Combine flat discount with the locally calculated item-level discount state
  final double finalTotalDiscount = flatDisc + totalDiscount;

  return Container(
    height: 40,
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    child: Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            content: 'Discount',
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          CustomText(
            // Display the calculated total discount
            content: formatAmount(finalTotalDiscount),
            fontSize: 16,
            color: Colors.black, 
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    ),
  );
}),
//                     Obx(() {
//   // 1. Get the flat discount (if you still want to include it)
//   final String cid = widget.productsController.selectedCustomerId.value;
//   final double flatDisc =
//       widget.productsController.flatDiscountByCustomer[cid] ?? 0.0;

//   // 2. Calculate the sum of item-level discounts
//   double itemLevelDiscount = widget.productsController.orderItems.fold(
//     0.0,
//     (sum, item) {
//       // Skip unchecked items to match your subtotal logic
//       if (item.isChecked != true) return sum;
      
//       // Add the item's total discount amount (handling nulls)
//       return sum + (item.totalDiscountAmount ?? 0.0);
//     },
//   );

//   // 3. Combine them for the total discount to display
//   final double totalDiscount = flatDisc + itemLevelDiscount;

//   // Optional: If you want to hide the widget when there is no discount
//   // if (totalDiscount <= 0) return const SizedBox.shrink();

//   return Container(
//     height: 40,
//     width: double.infinity,
//     padding: const EdgeInsets.all(10),
//     child: Padding(
//       padding: const EdgeInsets.only(right: 10, left: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           CustomText(
//             content: 'Discount',
//             fontSize: 16,
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//           ),
//           CustomText(
//             // Display the calculated total discount
//             content: formatAmount(totalDiscount),
//             fontSize: 16,
//             color: Colors.black, // You might want Colors.red or green for discount
//             fontWeight: FontWeight.w600,
//           ),
//         ],
//       ),
//     ),
//   );
// }),

Obx(() {
                        
                        // ignore: unused_local_variable
                        final String trigger1 =
                            widget.productsController.selectedCustomerId.value;
                        // ignore: unused_local_variable
                        final int trigger2 =
                            widget.productsController.orderItems.length;

                        // 2. Calculate Subtotal (Active items only)
                        double taxableAmount =
                            widget.productsController.orderItems.fold(
                          0.0,
                          (sum, item) {
                            if (item.isChecked != true) return sum;
                            return sum +
                                (item.finalPrice ?? item.totalPrice ?? 0.0);
                          },
                        );

                        // 3. Calculate Tax (Example: 15% of subtotal)
                        // CHANGE 0.15 to your actual tax rate variable if you have one
                        double calculatedTax = taxableAmount * 0.15;
                        orderTaxe =
            Utils().calculateTotalTax(widget.productsController.orderItems);

                        return Container(
                          height: 40,
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  content: 'Tax'.tr,
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                CustomText(
                                  // Use the locally calculated tax, NOT the static 'orderTaxe' variable
                                  content: formatAmount(orderTaxe),
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),


                   
                    // Container(
                    //   height: 40,
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(10),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 10, left: 10),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         CustomText(
                    //           content: 'Tax',
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //         CustomText(
                    //           content: formatAmount(orderTaxx),
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                  

                    const Divider(),

                    Obx(() {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      var customerCredit =
                          _customercreditctrl.customerCredit.value ?? 0.0;
                      print('customer credit in my cart:$customerCredit');
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      print('flat discount:$flatDisc');
                      // final double baseAmount = orderSubtotal - flatDisc;
                      double baseAmount = widget.productsController.orderItems.fold(
    0.0,
    (sum, item) {
      if (!item.isChecked!) return sum;
      return sum + (item.finalPrice ?? item.totalPrice);
    },
  );

  // 👇 SUBTRACT THE CART-LEVEL FLAT DISCOUNT HERE 👇
  baseAmount = baseAmount - flatDisc;

  print('base amount:$baseAmount');
  final double finalBeforeCredit = baseAmount.clamp(0.0, double.infinity);
                      // double baseAmount =
                      //     widget.productsController.orderItems.fold(
                      //   0.0,
                      //   (sum, item) {
                      //     if (!item.isChecked!) return sum;
                      //     return sum + (item.finalPrice ?? item.totalPrice);
                      //   },
                      // );

                      // print('base amount:$baseAmount');
                      // final double finalBeforeCredit =
                      //     baseAmount.clamp(0.0, double.infinity);

                      print('final before credit:$finalBeforeCredit');
                      final double payableAmount = useCredit.value
                          ? (finalBeforeCredit - customerCredit)
                              .clamp(0.0, double.infinity)
                          : finalBeforeCredit;
                      print('payble amount:$payableAmount');
                      //thi is the portion of orders//
                      return CartTotalWidget(
                        title: 'Final Amount'.tr,
                        //  payableAmount <= 0 ? 'Amount Paid by Credit' : 'Final Payable Amount',
                        content: payableAmount,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color2:
                            payableAmount <= 0 ? Colors.green : primaryColor,
                      );
                    }),

                  
                  ],
                  if (!isOrder) ...[
                    (widget.productsController.preorderItems.isEmpty)
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: CustomText(
                                content: 'No bookings items available.',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                          )
                        : Flexible(
                            child: SizedBox(
                              height: dialogHeight * 0.5,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      controller: _scrollController4,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController1,
                                        child: SizedBox(
                                          // color: red,
                                          height: double.maxFinite,
                                          width: isPhonePortrait(context)
                                              ? fullScreenWidth(context) * 2
                                              : fullScreenWidth(context) * 1.15,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: widget
                                                      .productsController
                                                      .preorderItems
                                                      .where((item) =>
                                                          item.detail.stock ==
                                                              0 ||
                                                          item.detail.stock ==
                                                              null)
                                                      .map((item) =>
                                                          item.productName)
                                                      .toSet()
                                                      .toList()
                                                      .map((productName) {
                                                    List<CartItem>
                                                        groupedItems = widget
                                                            .productsController
                                                            .preorderItems
                                                            .where((item) =>
                                                                item.productName ==
                                                                productName)
                                                            .toList();
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child: _buildGroupedItems(
                                                        productName:
                                                            productName,
                                                        groupedItems:
                                                            groupedItems,
                                                        availableWidth:
                                                            availableWidth,
                                                        fontSize: fontSize,
                                                        rowHeight: rowHeight,
                                                        context: context,
                                                        productQuantityManager:
                                                            productQuantityManager,
                                                        deleteConfirmationDialogue:
                                                            deleteConfirmationDialogue,
                                                        isPreOrder: true,
                                                        calCulateAmount:
                                                            calculateAmounts,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0,
                                    child: ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thumbColor: WidgetStateProperty
                                              .resolveWith<Color>((states) {
                                            if (states.contains(
                                                WidgetState.dragged)) {
                                              return primaryColor
                                                  .withOpacity(0.5);
                                            }
                                            return primaryColor
                                                .withOpacity(0.5);
                                          }),
                                          trackColor: WidgetStateProperty.all(
                                              primaryColor.withOpacity(0.2)),
                                          trackBorderColor:
                                              WidgetStateProperty.all(
                                                  primaryColor
                                                      .withOpacity(0.2)),
                                          thickness:
                                              WidgetStateProperty.all(10),
                                          radius: const Radius.circular(10),
                                          minThumbLength: 50,
                                          thumbVisibility:
                                              WidgetStateProperty.all(true),
                                          trackVisibility:
                                              WidgetStateProperty.all(true),
                                        ),
                                        child: Scrollbar(
                                            thickness: 6,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            controller: _scrollController3,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              controller: _scrollController3,
                                              child: Column(
                                                children: widget
                                                    .productsController
                                                    .preorderItems
                                                    .where((item) =>
                                                        item.detail.stock ==
                                                            0 ||
                                                        item.detail.stock ==
                                                            null)
                                                    .map((item) =>
                                                        item.productName)
                                                    .toSet()
                                                    .toList()
                                                    .map((productName) {
                                                  List<CartItem> groupedItems =
                                                      widget.productsController
                                                          .preorderItems
                                                          .where((item) =>
                                                              item.productName ==
                                                              productName)
                                                          .toList();

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 20),
                                                    child: _buildGroupedItems(
                                                      productName: productName,
                                                      groupedItems:
                                                          groupedItems,
                                                      availableWidth:
                                                          availableWidth,
                                                      fontSize: fontSize,
                                                      rowHeight: rowHeight,
                                                      context: context,
                                                      productQuantityManager:
                                                          productQuantityManager,
                                                      deleteConfirmationDialogue:
                                                          deleteConfirmationDialogue,
                                                      isPreOrder: false,
                                                      calCulateAmount:
                                                          calculateAmounts,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.dragged)) {
                            return primaryColor.withOpacity(0.5);
                          }
                          return primaryColor.withOpacity(0.5);
                        }),
                        trackColor: WidgetStateProperty.all(
                            primaryColor.withOpacity(0.2)),
                        trackBorderColor: WidgetStateProperty.all(
                            primaryColor.withOpacity(0.2)),
                        thickness: WidgetStateProperty.all(6),
                        radius: const Radius.circular(10),
                        minThumbLength: 50,
                        thumbVisibility: WidgetStateProperty.all(true),
                        trackVisibility: WidgetStateProperty.all(true),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 6,
                        controller: _scrollController2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController2,
                          child: Container(
                            width: isPhonePortrait(context)
                                ? fullScreenWidth(context) * 2
                                : fullScreenWidth(context) * 1.15,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: lightPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Subtotal'.tr,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(preorderSubtotal),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    // Container(
                    //   height: 40,
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(10),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 10, left: 10),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         CustomText(
                    //           content: 'Discount',
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //         CustomText(
                    //           content: formatAmount(totalDiscountPreorder),
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Flat discount (cart-level)
                    Builder(builder: (context) {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      // if (flatDisc <= 0) return const SizedBox.shrink();
                      return Container(
                        height: 40,
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                content: 'Discount',
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              CustomText(
                                content: formatAmount(flatDisc),
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Tax'.tr,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(preorderTax),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Obx(() {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      var customerCredit =
                          _customercreditctrl.customerCredit.value ?? 0.0;
                      print('customer credit in my cart:$customerCredit');
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      print('flat discount:$flatDisc');
                      // final double baseAmount = orderSubtotal - flatDisc;
                      double baseAmount =
                          widget.productsController.orderItems.fold(
                        0.0,
                        (sum, item) {
                          if (!item.isChecked!) return sum;
                          return sum + (item.finalPrice ?? item.totalPrice);
                        },
                      );

                      print('base amount:$baseAmount');
                      final double finalBeforeCredit =
                          baseAmount.clamp(0.0, double.infinity);

                      print('final before credit:$finalBeforeCredit');
                      final double payableAmount = useCredit.value
                          ? (finalBeforeCredit - customerCredit)
                              .clamp(0.0, double.infinity)
                          : finalBeforeCredit;
                      print('payble amount:$payableAmount');
                      return CartTotalWidget(
                        title: 'Final Amount'.tr,

                        //  payableAmount <= 0 ? 'Amount Paid by Credit' : 'Final Payable Amount',
                        // this is the portion of preorder//
                        content: preorderSubtotal,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color2:
                            payableAmount <= 0 ? Colors.green : primaryColor,
                      );
                    }),
                  ],
                  SizedBox(
                    height: _selectedValue == "Quick Sale"
                        ? (_dropdownValue == "Cheque" ||
                                _dropdownValue == "Bank Transfer"
                            ? 210
                            : (_dropdownValue == null ||
                                    _dropdownValue == "Cash"
                                ? 140
                                : 60))
                        : 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: filteredOptions.map((option) {
                            totalQuickController.text = isOrder
                                ? '\$${orderSubtotal.toStringAsFixed(2)} '
                                : '\$${preorderSubtotal.toStringAsFixed(2)}';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    splashRadius: 20,
                                    activeColor: Colors.green,
                                    value: option,
                                    groupValue: _selectedValue,
                                    onChanged: (value) {
                                      if (value == _options[1]) {
                                        if (subscriptionController
                                                .appQuickSale.value ==
                                            "true") {
                                          setState(() {
                                            _selectedValue = value!;
                                            _dropdownValue = null;
                                            totalQuickController.clear();
                                          });
                                        } else {
                                          showUpgradePlanDialog(context);
                                        }
                                      } else {
                                        setState(() {
                                          _selectedValue = value!;
                                          _dropdownValue = null;
                                          totalQuickController.clear();
                                        });
                                      }
                                    },
                                  ),
                                  Text(option),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedValue == "Quick Sale")
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, left: 40, right: 40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 130,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  hint: const Text(
                                                      "Payment method"),
                                                  value: _dropdownValue,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _dropdownValue =
                                                          newValue!;
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
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please select a payment method';
                                                    }
                                                    return null;
                                                  },
                                                  decoration:
                                                      const InputDecoration
                                                          .collapsed(
                                                          hintText: ''),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 150,
                                        child: MyFormField(
                                          controller: totalQuickController,
                                          labelText: "Total Amount",
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 8),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.blue, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter the total amount';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_dropdownValue == "Cheque" ||
                                          _dropdownValue == "Bank Transfer")
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            controller:
                                                chequeOrTransactionNumberController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText:
                                                  _dropdownValue == "Cheque"
                                                      ? "Cheque Number"
                                                      : "Transaction Number",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter the number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      if (_dropdownValue == "Cash" ||
                                          _dropdownValue == null)
                                        SizedBox(
                                          width: 200,
                                          child: TextFormField(
                                            controller: remarkController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText: "Remark",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please provide a remark';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      if (_dropdownValue == "Cheque" ||
                                          _dropdownValue == "Bank Transfer")
                                        Expanded(
                                          child: TextFormField(
                                            controller: dateController,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText: "Date",
                                              suffixIcon: IconButton(
                                                icon: const Icon(
                                                    Icons.calendar_today),
                                                onPressed: () async {
                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (pickedDate != null) {
                                                    setState(() {
                                                      dateController
                                                          .text = DateFormat(
                                                              'dd/MM/yyyy')
                                                          .format(pickedDate);
                                                    });
                                                  }
                                                },
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select a date';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_dropdownValue == "Cheque" ||
                                      _dropdownValue == "Bank Transfer")
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: TextFormField(
                                            controller: remarkController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText: "Remark",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please provide a remark';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomCartButton(
                          text: 'Continue Shopping'.tr,
                          size: width > 1200 ? 14 : 10,
                          color: primaryColor,
                          onTap: () {
                            if (widget.isFromCustomerDach == true ||
                                widget.isDashboard == true) {
                              widget.onContinueShopping!();
                              Navigator.pop(context);
                              Navigator.of(context, rootNavigator: true).pop();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 30),
                        CustomCartButton(
                          text: 'Save & Send'.tr,
                          size: width > 1200 ? 14 : 10,
                          color: const Color(0xff5bc0de),

//

                          onTap: () async {
                            final cartProvider = Provider.of<CustomersProvider>(
                                context,
                                listen: false);
                            final hasCheckInOutPermission =
                                subscriptionController
                                        .customerCheckInOut.value ==
                                    "true";
                            final isCheckedIn = widget.active == true;

                            if (!(isCheckedIn || !hasCheckInOutPermission)) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Icon(Icons.warning_amber_rounded,
                                      color: Colors.red, size: 60),
                                  content: const Text(
                                      'Please check-in before processing the order'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            final sanitizedText = totalQuickController.text
                                .replaceAll(RegExp(r'[^\d.]'), '')
                                .trim();
                            if (sanitizedText.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Invalid amount entered'),
                                    backgroundColor: Colors.red),
                              );
                              return;
                            }

                            final double userEnteredAmount =
                                double.parse(sanitizedText);
                            final String customerId = widget.customerId ??
                                widget.productsController.selectedCustomerId
                                    .value;

                            // Calculate base amount after flat discount
                            final String cid = widget
                                .productsController.selectedCustomerId.value;
                            final double flatDisc = widget.productsController
                                    .flatDiscountByCustomer[cid] ??
                                0.0;
                            final double subtotal =
                                isOrder ? orderSubtotal : preorderSubtotal;
                            final double baseAmount = (subtotal - flatDisc)
                                .clamp(0.0, double.infinity);

                            // Use the correct total: prefer calculated baseAmount, but allow manual override in Quick Sale
                            final double originalTotal =
                                _selectedValue == "Quick Sale"
                                    ? userEnteredAmount
                                    : baseAmount;

                            final availableCredit =
                                _customercreditctrl.customerCredit.value ?? 0.0;

                            // Show Credit Popup Only If Needed
                            bool? useCreditResult = false;
                            if (availableCredit > 0 && originalTotal > 0) {
                              useCreditResult = await showCreditUsageDialog(
                                context: context,
                                availableCredit: availableCredit,
                                amountToPayBeforeCredit: originalTotal,
                              );

                              if (useCreditResult == null)
                                return; // User closed dialog → cancel order
                              // useCreditConfirmed = result;
                            }

                            // Get cart & draft IDs
                            final cartDetails = await CartDatabaseManager()
                                .getDraftAndCartIdsFromApi(customerId);
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            final firstOrder = cartDetails.isNotEmpty
                                ? cartDetails.last
                                : {'cart_id': '', 'draft_id': ''};
                            final cartIdPrefs = firstOrder['cart_id'] ?? '';
                            final draftIdPrefs = firstOrder['draft_id'] ?? '';

                            // Quick Sale form validation
                            if (_selectedValue == "Quick Sale") {
                              if (!(_formKey.currentState?.validate() ??
                                  false)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please fill all required fields'),
                                      backgroundColor: Colors.red),
                                );
                                return;
                              }
                            }

                            // Call processSaveAndSend with:
                            // - ORIGINAL total (before credit)
                            // - useCreditConfirmed from popup
                            if (widget.productsController.storedBulkList.isEmpty) {
  print('SaveAndSend: Bulk list is empty. Fetching API now...');
  await widget.productsController.fetchBulkData();
}
print('bulk list before saveAndSend: ${widget.productsController.storedBulkList.map((e) => 'ID: ${e.id}, BulkID: ${e.bulkId}, Price: ${e.volumePrice}').toList()}');
                            await processSaveAndSend(
                              context: context,
                              finalAmount:
                                  originalTotal, // ← Important: send original amount
                              useCreditConfirmed: useCreditResult ??
                                  false, // ← Decision from popup
                              paymentType: paymentType,
                              cartId: cartIdPrefs,
                              draftId: draftIdPrefs,
                              bulkDataList: widget.productsController.storedBulkList,
                            );

                            cartProvider.getCartItemCounts(customerId);
                          },
                          // onTap: () async {
                          //   final cartProvider = Provider.of<CustomersProvider>(
                          //       context,
                          //       listen: false);
                          //   final hasCheckInOutPermission =
                          //       subscriptionController
                          //               .customerCheckInOut.value ==
                          //           "true";
                          //   final isCheckedIn = widget.active == true;

                          //   if (isCheckedIn ||
                          //       (!isCheckedIn && !hasCheckInOutPermission)) {
                          //     final sanitizedText = totalQuickController.text
                          //         .replaceAll(RegExp(r'[^\d.]'), '')
                          //         .trim();
                          //     if (sanitizedText.isEmpty) {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         const SnackBar(
                          //           backgroundColor: Colors.red,
                          //           content: Text('Invalid amount entered'),
                          //           duration: Duration(seconds: 3),
                          //         ),
                          //       );
                          //       return;
                          //     }

                          //     final finalAmount = double.parse(sanitizedText);
                          //     final customerId = widget.customerId ??
                          //         widget.productsController.selectedCustomerId
                          //             .value;

                          //     num amountPaidByCredit = 0.0;
                          //     if (useCredit.value &&
                          //         _customercreditctrl.customerCredit.value >
                          //             0) {
                          //       final String cid = widget.productsController
                          //           .selectedCustomerId.value;
                          //       final flatDisc = widget.productsController
                          //               .flatDiscountByCustomer[cid] ??
                          //           0.0;
                          //       final baseAmount = (isOrder
                          //               ? orderSubtotal
                          //               : preorderSubtotal) -
                          //           flatDisc;
                          //       final finalBeforeCredit =
                          //           baseAmount.clamp(0.0, double.infinity);
                          //       final availableCredit =
                          //           _customercreditctrl.customerCredit.value ??
                          //               0.0;
                          //       amountPaidByCredit =
                          //           finalBeforeCredit > availableCredit
                          //               ? availableCredit
                          //               : finalBeforeCredit;
                          //       final newCreditBalance =
                          //           (availableCredit - amountPaidByCredit)
                          //               .clamp(0.0, double.infinity);

                          //       // === UPDATE CREDIT IN DATABASE / API ===
                          //       try {
                          //         final String currentCustomerId = widget
                          //             .productsController
                          //             .selectedCustomerId
                          //             .value;

                          //         await _customercreditctrl
                          //             .updateCustomerCreditLocally(
                          //           customerId: customerId,
                          //           newCreditAmount: newCreditBalance,
                          //         );

                          //         // Get.snackbar(
                          //         //   "Credit Updated",
                          //         //   "Used ${formatAmount(amountPaidByCredit)} credit. Remaining: ${formatAmount(newCreditBalance)}",
                          //         //   snackPosition: SnackPosition.BOTTOM,
                          //         //   backgroundColor:
                          //         //       Colors.green.withOpacity(0.8),
                          //         //   colorText: Colors.white,
                          //         // );
                          //       } catch (e) {
                          //         Get.snackbar(
                          //             "Error", "Failed to update credit: $e",
                          //             backgroundColor: Colors.red);
                          //         return; // Stop processing if credit update fails
                          //       }
                          //     }

                          //     final cartDetails = await CartDatabaseManager()
                          //         .getDraftAndCartIdsFromApi(customerId);
                          //     await Future.delayed(const Duration(seconds: 1));
                          //     final firstOrder = cartDetails.isNotEmpty
                          //         ? cartDetails.last
                          //         : {'cart_id': '', 'draft_id': ''};
                          //     final cartIdPrefs = firstOrder['cart_id'] ?? '';
                          //     final draftIdPrefs = firstOrder['draft_id'] ?? '';
                          //     // log('Existing cart ID $existingCartId');
                          //     // log('Existing Draft ID $existingDraftId');
                          //     if (_selectedValue == "Quick Sale") {
                          //       if (_formKey.currentState?.validate() ??
                          //           false) {
                          //         await processSaveAndSend(
                          //           finalAmount: finalAmount,
                          //           paymentType: paymentType,
                          //           context: context,
                          //           cartId: cartIdPrefs,
                          //           draftId: draftIdPrefs,
                          //         );
                          //         cartProvider.getCartItemCounts(customerId);
                          //       } else {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           const SnackBar(
                          //             backgroundColor: Colors.red,
                          //             content: Text(
                          //                 'Please fill all required fields'),
                          //             duration: Duration(seconds: 3),
                          //           ),
                          //         );
                          //       }
                          //     } else {
                          //       await processSaveAndSend(
                          //         finalAmount: finalAmount,
                          //         context: context,
                          //         cartId: cartIdPrefs,
                          //         draftId: draftIdPrefs,
                          //       );
                          //       cartProvider.getCartItemCounts(customerId);
                          //     }
                          //   } else {
                          //     showDialog(
                          //       context: context,
                          //       barrierDismissible: false,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //           title: const Center(
                          //             child: Icon(
                          //               Icons.warning_amber_rounded,
                          //               color: Colors.red,
                          //               size: 60,
                          //             ),
                          //           ),
                          //           content: CustomText(
                          //             content:
                          //                 'Please check-in before processing the order',
                          //             fontSize: 18,
                          //           ),
                          //           actions: [
                          //             TextButton(
                          //               onPressed: () {
                          //                 Navigator.pop(context);
                          //                 Navigator.of(context,
                          //                         rootNavigator: true)
                          //                     .pop();
                          //               },
                          //               child: const Text('OK'),
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     );
                          //   }
                          // },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Row(
              children: [
                CustomHeaderContainer(
                  text:
                      productName.startsWith('Bundle') ? "Bundle" : productName,
                  fontSize: isPhonePortrait(context) ? 14 : fontSize,
                ),
                const Spacer(),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        showVariantDeleteDialog(
                          context,
                          productName,
                          !isOrder,
                          false,
                        );
                      },
                      icon: const Icon(
                        EneftyIcons.trash_bold,
                        size: 28,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 3.5,
              color: lightPrimaryColor,
              width: double.infinity,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: DataTable(
                  headingRowHeight: 30,
                  dataRowHeight: rowHeight,
                  horizontalMargin: 5,
                  columnSpacing: 15,
                  columns: DataTableColumns.getColumns(
                      isPhonePortrait(context) ? 12 : fontSize,
                      isBundle: productName.startsWith('Bundle')),
                  rows: GroupedItemDataRows.getRows(
                    groupedItems: groupedItems,
                    fontSize:
                        isPhonePortrait(context) ? 12 : availableWidth / 55,
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
            ),
          ],
        ),
      ],
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
              title: const Text('Offline Mode'),
              content: const Text(
                  'The order will be placed automatically when connected to the internet.'),
              actions: [
                TextButton(
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
                  child: const Text('OK'),
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
              String displayPackType = (e.packtype == 'Pack' || item.isPack == true)
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
      idToSendToBackend = matchingBulk.id?.toString() ?? currentBulkId;
      
      // Update the price if a volume price exists
      if (matchingBulk.volumePrice != null && matchingBulk.volumePrice!.isNotEmpty) {
        finalPrice = matchingBulk.volumePrice!;
      }
    } catch (err) {
      print('Bulk ID $currentBulkId found but not matched in BulkData list: $err');
    }
  }
}

return SendCartData(
  productId: e.productId ?? '',
  variantId: e.variationId ?? '',
  pack: packValue,
  price: finalPrice, 
  packType: isBulkItem ? 'Bulk' : displayPackType,
  discount: combinedDiscount,
  quantity: e.count.toInt(),
  variantName: e.variationName ?? '',
  
  // Normal/Bulk Flags
  isPromo: false,
  isBundle: false,
  isBulk: isBulkItem,
  bulkId: idToSendToBackend, 

  customerDiscount: item.CustomerDiscount,
  promoDiscount: combinedPromoDiscount,
  unitPrice: e.sellPrice.toString(),
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
              paymentType: paymentType.toString(),
              companyId: companyId,
              paymentDetail: remarkController.text.trim(),
              transactionNumber:
                  chequeOrTransactionNumberController.text.trim(),
              transactionDate: dateController.text.trim(),
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
                        TextButton(
                          onPressed: () async {
                            final cartProvider = Provider.of<CustomersProvider>(
                                context,
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
                                  .fetchCustomerDashboardCountData(customerId);
                            }

                            setState(() {
                              Navigator.pop(context);
                              Navigator.of(context, rootNavigator: true).pop();
                            });
                            if (widget.onDraftUpdated != null) {
                              widget.onDraftUpdated!();
                            }
                          },
                          child: const Text('OK'),
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
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Your cart is empty.'),
            duration: Duration(seconds: 3),
          ),
        );
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
      'cart_list': processedItems
          .map((e) => {
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
                'price': e.detail.sellPrice.toString(),
                'discount': '0',
                'quantity': e.detail.count.toInt(),
                'tax': e.detail.tax?.toInt(),
                'unitTax': e.detail.unitTax?.toInt(),
                'inclTax': e.detail.inclTax,
                'totalTax': (e.detail.tax ?? 0) *
                    (e.isPack == true || e.detail.packtype == 'Pack'
                        ? (e.detail.pieces ?? 0) * e.detail.count
                        : 1),
                'discountPrice':
                    (((double.tryParse(e.detail.sellPrice?.toString() ?? '0') ??
                                0.0) *
                            ((double.tryParse(
                                        e.detail.discount?.toString() ?? '0') ??
                                    0.0) /
                                100)) *
                        ((e.isPack == true || e.detail.packtype == 'Pack')
                            ? (e.detail.pieces?.toDouble() ?? 1) *
                                e.detail.count.toDouble()
                            : e.detail.count.toDouble())),
                'totalPrice': e.detail.totalPrice,
                'isPack': e.isPack,
              })
          .toList(),
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
            detailsAfterProcessing.add({
              'product_id': detail.detail.productId ?? '',
              'variant_id': detail.detail.variationId ?? '',
              'pack': detail.detail.saleBy == 'Pack'
                  ? detail.detail.pieces.toString()
                  : detail.detail.count.toString(),
              'packType': detail.detail.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              'price': detail.detail.sellPrice.toString(),
              'discount': detail.detail.discount,
              'quantity': detail.detail.count.toInt(),
              'variant_name': detail.detail.variationName ?? '',
              'stock': detail.detail.stock ?? 0,
              'unitType': detail.detail.unitType,
              'product_name': detail.detail.productName,
              'tax': detail.detail.tax,
              'incl_tax': detail.detail.inclTax,
              'pieces': detail.detail.pieces,
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
          title: CustomText(
            content: 'Delete ${groupedItem.detail.variationName}..?',
            fontWeight: FontWeight.w700,
          ),
          actions: [
            Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  content: 'Are you sure you want to delete..?'.tr,
                  fontSize: 17,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  Text('No'.tr)),
                TextButton(
                    onPressed: () {
                      final provider = Provider.of<CustomersProvider>(context,
                          listen: false);
                      _deleteVariant(groupedItem, provider);
                      _loadCartItems();
                      widget.productsController.isCartModified.value = true;
                      Navigator.pop(context);
                    },
                    child:  Text('Yes'.tr))
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
    // widget.customerOrderController!.customerId.value.isNotEmpty
    //     ? widget.customerOrderController?.customerId.value ?? ''
    //     : widget.productsController.selectedCustomerId.value;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  content: 'Delete "$productName"?',
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
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: CustomText(
                content: 'Cancel',
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                final provider =
                    Provider.of<CustomersProvider>(context, listen: false);
                _deleteProduct(productName, isPreorder: isPreOrder);
                await provider.updateCartCount(customerId);
                _loadCartItems();
                Navigator.pop(context);
                widget.productsController.isCartModified.value = true;
                showCustomToastDisplay(
                  context,
                  'Item deleted successfully',
                  Colors.green,
                  Icons.check,
                );
              },
              child: CustomText(
                content: 'Confirm',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
  void _deleteVariant(CartItem variantToDelete, CustomersProvider provider) {
  final String customerId = widget.customerId ?? '';
  setState(() {
    // 1. Remove from local controller lists FIRST
    widget.productsController.cartItems.removeWhere((item) =>
        item.productName == variantToDelete.productName &&
        item.detail.variationName == variantToDelete.detail.variationName);
        
    // 2. Actually delete from the database (Do NOT update it to count = 0 first)
    CartDatabaseManager().deleteCartItem(variantToDelete);

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
    orderTaxe = Utils().calculateTotalTax(orderItems); // Note: Make sure you use orderTaxe consistently
    preorderSubtotal = Utils().calculateSubtotal(preorderItems);
    preorderTax = Utils().calculateTotalTax(preorderItems);
    
    provider.updateCartCount(customerId);
  });

  _maybeClearFlatDiscountForCustomer(customerId);
}

  // void _deleteVariant(CartItem variantToDelete, CustomersProvider provider) {
  //   final String customerId = widget.customerId ?? '';
  //   setState(() {
  //     variantToDelete.detail.count = 0;
  //     CartDatabaseManager().updateCart(variantToDelete);
  //     widget.productsController.cartItems.removeWhere((item) =>
  //         item.productName == variantToDelete.productName &&
  //         item.detail.variationName == variantToDelete.detail.variationName);
  //     CartDatabaseManager().deleteCartItem(variantToDelete);
  //     List<CartItem> orderItems = widget.productsController.cartItems
  //         .where((item) => (item.detail.stock ?? 0) > 0)
  //         .toList();
  //     List<CartItem> preorderItems = widget.productsController.cartItems
  //         .where((item) => item.detail.stock == 0)
  //         .toList();
  //     orderSubtotal = Utils().calculateSubtotal(orderItems);
  //     orderTax = Utils().calculateTotalTax(orderItems);
  //     preorderSubtotal = Utils().calculateSubtotal(preorderItems);
  //     preorderTax = Utils().calculateTotalTax(preorderItems);
  //     provider.updateCartCount(customerId);
  //   });

  //   // If no remaining items carry a flat discount promo, clear it
  //   _maybeClearFlatDiscountForCustomer(customerId);
  // }


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
      // 1. Calculate Base Amount (Price * Pack Pieces)
      double sellPriceVal =
          double.tryParse(cartItem.detail.sellPrice?.toString() ?? '0') ?? 0.0;
      int qtyFactor =
          (cartItem.detail.packtype == 'Pack' || cartItem.isPack == true)
              ? (cartItem.detail.pieces?.toInt() ?? 1)
              : 1;
      double baseSellAmount = sellPriceVal * qtyFactor;
      double productQuantity = cartItem.detail.count.toDouble();

      // 2. Calculate Discount
      double customerDisc =
          (cartItem.CustomerDiscount != null && cartItem.CustomerDiscount! > 0)
              ? cartItem.CustomerDiscount!
              : 0.0;
      num tieredDisc =
          (cartItem.tieredDiscount != null && cartItem.tieredDiscount! > 0)
              ? cartItem.tieredDiscount!
              : 0;
          //     num flatDisc = 
          // (cartItem.flatDiscount != null && cartItem.flatDiscount! > 0) 
          //     ? cartItem.flatDiscount! 
          //     : 0;
             
      double totalDiscountPercent = customerDisc + tieredDisc;
//       double percentageDiscountAmount = (baseSellAmount * productQuantity) * (totalDiscountPercent / 100.0);
// double blocks = productQuantity / tierStep;
// // 2. ✅ Add the fixed flat discount
// double totalDiscountAmount = percentageDiscountAmount + (flatDisc.toDouble() * blocks);
// double totalDiscountAmount = percentageDiscountAmount + flatDisc.toDouble();
    
      // Calculate Discount Amount
      double totalDiscountAmount =
          (baseSellAmount * productQuantity) * (totalDiscountPercent / 100.0) ;
          print('total discpunt amount in product quanity:$totalDiscountAmount');
      
      cartItem.totalDiscountAmount = totalDiscountAmount;

      // 3. Calculate Price After Discount
      double priceAfterDiscount =
          (baseSellAmount * productQuantity) - totalDiscountAmount;

      // 4. Calculate Tax
      double taxPercentage = (cartItem.catTax ?? 0).toDouble();

      double tax;
      if (taxPercentage > 0) {
        // Scenario A: We have the percentage, calculate normally
        tax = priceAfterDiscount * (taxPercentage / 100);
      } else {
        // Scenario B: Percentage is missing (reload/draft), use Unit Tax from details
        double unitTax = (cartItem.detail.tax ?? 0).toDouble();
        
        // Calculate total pieces (Quantity * Pieces per pack)
        double totalUnits = cartItem.detail.count.toDouble();
        if (cartItem.isPack == true || cartItem.detail.packtype == 'Pack') {
           totalUnits = totalUnits * (cartItem.detail.pieces ?? 1);
        }
        
        tax = unitTax * totalUnits;
      }
      
      cartItem.taxAmount = tax;

      // 5. Update Final Price
      if (cartItem.detail.inclTax == "incl_tax") {
        cartItem.finalPrice = priceAfterDiscount;
      } else {
        cartItem.finalPrice = priceAfterDiscount + tax;
      }
    }


    return Container(
      width: availableWidth > 400 ? 80 : 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 241, 240, 240),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isTieredDiscount) {
                      // Only subtract by tierStep if it is a Promo item
                      if (cartItem.detail.count > tierStep) {
                        cartItem.detail.count -= tierStep;
                      }
                    } else {
                      // Normal decrement by 1
                      if (cartItem.detail.count > 1) {
                        cartItem.detail.count--;
                      }
                    }

                    // 1. Update Total Price (Base logic)
                    cartItem.totalPrice = Utils().calculateTotalPrice(
                      cartItem,
                      cartItem.detail.count.toInt(),
                    );

                    // 2. MANUALLY UPDATE TAX & DISCOUNT MODELS HERE
                    updateItemCalculations();

                    // 3. Now Calculate Totals (Uses the updated taxAmount)
                    calculateAmounts();

                    CartDatabaseManager().updateCart(cartItem);
                    CartDatabaseManager()
                        .getCartItems(cartItem.customerId ?? '');
                    widget.productsController.isCartModified.value = true;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: CustomText(
                    color: Colors.white,
                    content: '-',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          CustomText(
            content: cartItem.detail.count.toStringAsFixed(0),
            fontSize: fontSize,
          ),
          Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isTieredDiscount) {
                      // Only add by tierStep if it is a Promo item
                      cartItem.detail.count += tierStep;
                    } else {
                      // Normal increment by 1
                      cartItem.detail.count++;
                    }

                    // 1. Update Total Price (Base logic)
                    cartItem.totalPrice = Utils().calculateTotalPrice(
                      cartItem,
                      cartItem.detail.count.toInt(),
                    );

                    // 2. MANUALLY UPDATE TAX & DISCOUNT MODELS HERE
                    updateItemCalculations();

                    // 3. Now Calculate Totals (Uses the updated taxAmount)
                    calculateAmounts();

                    CartDatabaseManager().updateCart(cartItem);
                    widget.productsController.isCartModified.value = true;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: CustomText(
                    color: Colors.white,
                    content: '+',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
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
        totalDiscount = widget.productsController.orderItems.fold(0.0, (sum, item) {
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
    final variantsToDelete = widget.productsController.cartItems.where((item) {
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
  required availableCredit,
  required double amountToPayBeforeCredit,
}) async {
  // Calculate how much credit would be used if applied
  final double creditToBeUsed = amountToPayBeforeCredit > availableCredit
      ? availableCredit
      : amountToPayBeforeCredit;

  final double amountAfterCredit =
      (amountToPayBeforeCredit - creditToBeUsed).clamp(0.0, double.infinity);

  return await showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Apply Customer Credit?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Credit
            Row(
              children: [
                const Text("Available Credit: ",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  formatAmount(availableCredit),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Order Total
            Row(
              children: [
                const Text("Order Total: ",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  formatAmount(amountToPayBeforeCredit),
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Visual Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  Text(
                  //   "If you apply credit:",
                  //   style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                  // ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   "• Deduct: ${formatAmount(creditToBeUsed)}",
                  //   style: const TextStyle(fontSize: 16),
                  // ),
                  Text(
                    "After applying the credit, your total payable amount will be: ${formatAmount(amountAfterCredit)}",
                    // "You pay: ${formatAmount(amountAfterCredit)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: amountAfterCredit == 0
                          ? Colors.green[800]
                          : Colors.blue[800],
                    ),
                  ),
                  // if (amountAfterCredit == 0)
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 8),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.celebration, color: Colors.green, size: 20),
                  //       SizedBox(width: 6),
                  //       Text(
                  //         "Full amount covered!",
                  //         style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () =>
                Navigator.pop(context, null), // null means cancelled
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),

          // Skip Credit Button
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Pay without Credit",
                style: TextStyle(fontSize: 16)),
          ),

          // Pay with Credit Button
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle, size: 20),
            label: Text(
              amountAfterCredit == 0 ? "Pay with Credit" : "Apply Credit",
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
