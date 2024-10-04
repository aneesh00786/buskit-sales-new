import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_bubble_information.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_increment_decrement.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CartDiloagScreen extends StatefulWidget {
  final ProductsController productsController;

  const CartDiloagScreen({super.key, required this.productsController});

  @override
  State<CartDiloagScreen> createState() => _CartDiloagScreenState();
}

class _CartDiloagScreenState extends State<CartDiloagScreen> {
  CustomerCartData customerCartData = CustomerCartData();
  TextEditingController reasonController = TextEditingController();
  String? existProductId;
  num? totalPayable;
  List<String> productDataCollumList = [
    "Varient",
    "Pack",
    "Price",
    "Discount",
    "Quntity",
    "Total"
  ];

  @override
  void initState() {
    loadDataForServer();
    super.initState();
  }

  /*  get loadDataForLocal async => {
        cartDataList =
            await widget.productsController.loadDataForOfflineDataBase,
        setState(() {
          cartDataList;
        })
      }; */

  loadDataForServer() async {
    await widget.productsController
        .getCustomerCartData(
            widget.productsController.customerAndOrderData.value.customerId!)
        .then((value) async {
      if (value != null) {
        setState(() {
          customerCartData = value;
        });
      }
      await widget.productsController
          .getSingleCustomerOrderHistory(
              widget.productsController.customerAndOrderData.value.customerId!)
          .then((value) {
        if (value != null && value.data != null) {
          setState(() {
            existProductId = value.data!
                .firstWhere(
                    (element) => element.cartId == customerCartData.cartId,
                    orElse: () => OrderData())
                .orderId;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        minimum: nkSymmetricPadding(
            vertical: AppDimensions.instance!.height * 0.08,
            horizontal:
                AppDimensions.instance!.orientation == Orientation.landscape
                    ? AppDimensions.instance!.width * 0.20
                    : AppDimensions.instance!.width * 0.05),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Scaffold(
            appBar: DiloagAppBar(
              title: myCart,
            ),
            body: SingleChildScrollView(
              padding: nkRegularPadding(),
              physics: NkGeneralSize.commonPysics(),
              child: Center(
                child: NkWidgetExceptionHandel(
                    errorCustomWidgets: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.vertical,
                      children: [
                        MyNetworkImage(
                          withoutBaseUrl: true,
                          imageUrl:
                              "https://i.ibb.co/r5kZLkw/bpnlauwze4-79c04e73-online-video-cutter-com-1-Adobe-Express.gif",
                          height: AppDimensions.instance.height * 0.5,
                          width: AppDimensions.instance.height * 0.5,
                        ),
                        MyRegularText(
                          align: TextAlign.center,
                          label: productNotAvailable,
                          fontSize: NkFontSize.largeFont() + 5,
                        )
                      ],
                    ),
                    data: customerCartData.cart,
                    child: Column(
                      children: [
                        cartItem,
                        nkMediumSizeBox(),
                        subTotalWidget(
                            tax: taxCalculation(customerCartData.cart).$2,
                            total: taxCalculation(customerCartData.cart).$1),
                        nkMediumSizeBox(),
                        purhaseBtnWidget
                      ],
                    )),
              ),
            ),
          ),
        ),
      );
    });
  }

  (num total, num tax) taxCalculation(List<CustomerCart>? cartDataList) {
    if (cartDataList == null) {
      return (0, 0);
    }
    num tax = 0;
    num total = 0;
    num? totalDiscount;
    for (var element in cartDataList) {
      tax += num.parse(element.tax ?? "0");
      total += num.parse(element.price ?? "0");
      totalDiscount =
          element.discount != null && num.parse(element.discount!) > 0
              ? calculateAmountWithDiscount(
                  total: total,
                  tax: tax,
                  discount: num.parse(element.discount ?? "0"))
              : null;
      totalPayable = total;
    }
    return (totalDiscount ?? total, tax);
  }

  Widget get cartItem {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        return cartDataWidget(customerCartData.cart![index], index);
      },
      itemCount: customerCartData.cart?.length ?? 0,
      separatorBuilder: (BuildContext context, int index) {
        return nkMediumSizeBox();
      },
    );
  }

  Widget cartDataWidget(CustomerCart cartData, int index) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: nkRegularPadding(),
            child: MyRegularText(
                label: cartData.productName!,
                fontWeight: NkGeneralSize.nkBoldFontWeight()),
          ),
          Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(NkGeneralSize.nkCommonBorderRadius()),
                  bottomRight:
                      Radius.circular(NkGeneralSize.nkCommonBorderRadius())),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: tableWidget(cartData)),
                nkSmallSizeBox(),
                InkResponse(
                    onTap: () {
                      setState(() {
                        customerCartData.cart!.removeAt(index);
                      });
                      widget.productsController
                          .deleteCartItem(customerCartData.customerId!,
                              cartData.cartId!, cartData.variationId!)
                          .then((value) {
                        /*setState(() {
                          customerCartData = CustomerCartData();
                        });*/

                        loadDataForServer();
                      });
                      // deleteTap(cartData);
                    },
                    child: SvgPicture.asset(Assets.iconsIcDelete)),
                nkSmallSizeBox()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget priceWidget(CustomerCart data) {
    return Row(
      children: [
        MyRegularText(
          label: "${data.price ?? 0}"
              .nkValueWithCurrencySymbol
              .removeAllWhitespace,
        ),
        nkSmallSizeBox(),
        data.salesmanReason != null
            ? Padding(
                padding: nkSymmetricPadding(
                  vertical: 0,
                  horizontal: AppDimensions.instance!.width * 0.01,
                ),
                child: Tooltip(
                  // Provide a global key with the "TooltipState" type to show
                  // the tooltip manually when trigger mode is set to manual.
                  key: widget.productsController.tooltipkey,
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(minutes: 3),
                  verticalOffset: -70,
                  onTriggered: () {
                    //productsController.getSalesmanData(data.reasonBySalesman!);
                  },
                  richMessage: WidgetSpan(
                      child: Column(
                    children: [
                      const MyRegularText(
                        label: priceChanged,
                      ),
                      nkSmallSizeBox(),
                      MyRegularText(
                        label: data.salesmanReason ?? '',
                      )
                    ],
                  )),
                  decoration: const ShapeDecoration(
                      shape: ToolTipCustomShape(), color: secondaryIconColor),
                  child: const Icon(
                    Icons.info_outline,
                    size: 26,
                    color: primaryColor,
                  ),
                ),
              )
            : const SizedBox(),
        InkResponse(
            onTap: () {
              Get.defaultDialog(
                  title: "$edit $price",
                  content: Form(
                    key: widget.productsController.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyRegularText(
                          label: "$add $price",
                          fontWeight: NkGeneralSize.nkBoldFontWeight(),
                        ),
                        nkSmallSizeBox(),
                        MyFormField(
                          controller: TextEditingController(
                              text: data.price?.toString() ?? '0'),
                          labelText: "$add $price",
                          isShowDefaultValidator: true,
                        ),
                        nkMediumSizeBox(),
                        nkSmallSizeBox(),
                        MyRegularText(
                          label: "$add $reason",
                          fontWeight: NkGeneralSize.nkBoldFontWeight(),
                        ),
                        nkSmallSizeBox(),
                        MyFormField(
                          controller: reasonController,
                          labelText: reason,
                          isShowDefaultValidator: true,
                        ),
                      ],
                    ),
                  ),
                  cancel: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const MyRegularText(
                      label: "cancel",
                      color: errorColor,
                    ),
                  ),
                  confirm: TextButton(
                    onPressed: () {
                      if (widget.productsController.formKey.currentState!
                          .validate()) {
                        Get.back();
                        widget.productsController.setUpdatePruductPrise(
                            productId: data.productId ?? '',
                            variationId: data.variationId!,
                            cartId: data.cartId!,
                            price: data.price!,
                            reason: reasonController.text);
                      }
                    },
                    child: const MyRegularText(
                      label: "Submit",
                      color: Colors.green,
                    ),
                  ));
            },
            child: SvgPicture.asset(Assets.iconsIcEdit))
      ],
    );
  }

  /* deleteTap(ProductBuyData cartData) async {
    if (await DatabaseHelper.deleteItem(cartData.id!,
        collumName: SqlDatabaseKey.buyProduct)) {
      setState(() {
        cartDataList.remove(cartData);
      });
    }
  }*/

  Widget tableWidget(CustomerCart cartData) {
    return nkChildWrappedSizeBox(
      width: double.maxFinite,
      child: DataTable(
          headingRowHeight: AppDimensions.instance!.height * 0.05,
          columns: productDataCollumList
              .map((e) => DataColumn(
                      label: MyRegularText(
                    label: e,
                    color: secondaryTextColor,
                  )))
              .toList(),
          rows: [
            DataRow(cells: [
              DataCell(MyRegularText(
                label: cartData.variationName!,
              )),
              DataCell(MyRegularText(
                label: cartData.packtype!,
              )),
              DataCell(priceWidget(cartData)),
              DataCell(MyRegularText(
                label:
                    cartData.discount!.toString().nkValueWithPercentageSymbol,
              )),
              DataCell(quntityWidget(cartData)),
              DataCell(cartData.discount != null &&
                      (num.parse(cartData.discount!) > 0)
                  ? MyRegularText(
                      label: calculateAmountWithDiscount(
                              total: cartData.total!,
                              tax: num.parse(cartData.tax!),
                              discount: num.parse(cartData.discount!))
                          .toStringAsFixed(2)
                          .nkValueWithCurrencySymbol
                          .removeAllWhitespace,
                    )
                  : MyRegularText(
                      label: cartData.total!
                          .toString()
                          .nkValueWithCurrencySymbol
                          .removeAllWhitespace,
                    )),
            ])
          ]),
    );
  }

  Widget quntityWidget(CustomerCart cartData) {
    return nkChildWrappedSizeBox(
      height: AppDimensions.instance!.height * 0.03,
      child: NkIncrementDecrement(
        isSmallSizeBtn: true,
        addBtnColor: primaryColor,
        removeBtnColor: primaryColor,
        initialCount: cartData.quantity,
        onValueChange: (value) {
          setState(() {
            cartData.quantity = value;
            cartData.total = (value * num.parse(cartData.price!)).toInt();
          });
        },
      ),
    );
  }

  Widget subTotalWidget({required num total, required num tax}) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: nkRegularPadding(),
            child: MyRegularText(
                label: subtotal, fontWeight: NkGeneralSize.nkBoldFontWeight()),
          ),
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(NkGeneralSize.nkCommonBorderRadius()),
                  bottomRight:
                      Radius.circular(NkGeneralSize.nkCommonBorderRadius())),
            ),
            child: Padding(
              padding: nkRegularPadding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyRegularText(
                      label:
                          "$totalString:-    ${total.toStringAsFixed(2).nkValueWithCurrencySymbol.removeAllWhitespace}"),
                  MyRegularText(
                      label:
                          "$taxString:-   ${tax.toStringAsFixed(2).nkValueWithCurrencySymbol.removeAllWhitespace}"),
                  /*   if (discount != 0) ...[
                    MyRegularText(
                      label:
                      "$finalAmountString:-   ${calculateAmountWithDiscount(total: total, tax: tax, discount: discount).toString().nkValueWithCurrencySymbol.removeAllWhitespace}",
                      fontWeight: NkGeneralSize.nkBoldFontWeight(),
                    ),
                    MyRegularText(
                      label:
                          "$finalAmountString:-   ${calculateAmountWithDiscount(total: total, tax: tax, discount: discount).toString().nkValueWithCurrencySymbol.removeAllWhitespace}",
                      fontWeight: NkGeneralSize.nkBoldFontWeight(),
                    ),
                  ] else ...[
                    MyRegularText(
                      label:
                          "$finalAmountString:-   ${((total + tax)).toString().nkValueWithCurrencySymbol.removeAllWhitespace}",
                      fontWeight: NkGeneralSize.nkBoldFontWeight(),
                    )
                  ]*/
                  MyRegularText(
                    label:
                        "$finalAmountString:-   ${((total + tax)).toStringAsFixed(2).nkValueWithCurrencySymbol.removeAllWhitespace}",
                    fontWeight: NkGeneralSize.nkBoldFontWeight(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  double calculateAmountWithDiscount(
      {required num total, required num tax, required num discount}) {
    var discountAmount = ((total + tax) * discount) / 100;

    return total - discountAmount;
  }

  Widget get purhaseBtnWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: MyThemeButton(
              width: double.maxFinite,
              buttonText: saveAsdraft,
              onPressed: () {
                widget.productsController.sendDraftPruduct(BuyProductResponce(
                    customerId: widget.productsController.customerAndOrderData
                        .value.customerId!,
                    salesmanId:
                        SessionHelper.loginSavedData!.salesmanId!.toString(),
                    paymentStatus: 0,
                    orderStatus: OrderStatus.draft.type,
                    cartId: customerCartData.cartId!,
                    orderPrice:
                        taxCalculation(customerCartData.cart).$1.toString(),
                    orderId: ""));
              },
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      NkGeneralSize.nkCommonBorderRadius()),
                  side: const BorderSide(color: primaryTextFieldColor)),
              fontColor: primaryTextColor),
        ),
        nkMediumSizeBox(),
        Flexible(
          child: MyThemeButton(
              width: double.maxFinite,
              buttonText: saveAsSend,
              onPressed: () {
                /*widget.productsController.purchasePruduct(
                    widget.productsController.customerAndOrderData.value
                        .customerId!,
                    SessionHelper.loginSavedData!.salesmanId!.toString(),
                    (taxCalculation(cartDataList).$2 +
                            taxCalculation(cartDataList).$1)
                        .toString(),
                    listCartData);*/
                // widget.productsController.purchasePruduct(BuyProductResponce(
                //     customerId: widget.productsController.customerAndOrderData
                //         .value.customerId!,
                //     salesmanId:
                //         SessionHelper.loginSavedData!.salesmanId!.toString(),
                //     paymentStatus: 0,
                //     orderStatus: OrderStatus.preOrder.type,
                //     cartId: customerCartData.cartId!,
                //     orderPrice:
                //         taxCalculation(customerCartData.cart).$1.toString(),
                //     orderId: existProductId ?? ''));
              },
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      NkGeneralSize.nkCommonBorderRadius()),
                  side: const BorderSide(color: primaryTextFieldColor)),
              fontColor: primaryTextColor),
        ),
        nkMediumSizeBox(),
        Flexible(
            child: MyThemeButton(
                width: double.maxFinite,
                buttonText: continueShopping,
                onPressed: () async {
                  /*   await widget.productsController.addProductToCart(
                      cartDataList, widget.productsController);*/

                  /* Future.forEach(cartDataList, (element) async {
                    await DatabaseHelper.updateItem(element.toJson(),
                        collumName: SqlDatabaseKey.buyProduct);
                  })*/
                })),
      ],
    );
  }
}
