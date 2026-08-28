import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_bar/diloag_app_bar.dart';

class OrderDetailsDiloag extends StatelessWidget {
  final OptionOrderData orderResponce;
  const OrderDetailsDiloag({super.key, required this.orderResponce});

  List<String> get headingColumns => [
        "Qty",
        "Product",
        "Price",
        "SubTotal",
      ];
  List<String> get headingColumnsTotalPayable => [
        "Payment Info",
        "Due By",
        "Total Amount",
      ];

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        minimum: nkSymmetricPadding(
            vertical: AppDimensions.instance.height * 0.08,
            horizontal:
                AppDimensions.instance.orientation == Orientation.landscape
                    ? AppDimensions.instance.width * 0.20
                    : AppDimensions.instance.width * 0.05),
        child: Card(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
            child: Scaffold(
              appBar: DiloagAppBar(
                title: "",
              ),
              body: SingleChildScrollView(
                padding: nkRegularPadding(),
                child: productMainWidget,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget get productMainWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            Assets.iconsIcLoginLogo,
            height: AppDimensions.instance.height * 0.12,
          ),
          topUserDetails(),
          nkMediumSizeBox(),
          ordersDetailsWidget(),
          totalPayableAmountWidget()
        ],
      );

  Widget totalPayableAmountWidget() {
    return nkChildWrappedSizeBox(
      width: AppDimensions.instance.width,
      child: DataTable(
          horizontalMargin: 0,
          dividerThickness: 5,
          columns: headingColumnsTotalPayable.map((e) {
            return DataColumn(
                label: MyRegularText(
              color: const Color(0xFF0F172A),
              label: e,
            ));
          }).toList(),
          rows: [
            DataRow(cells: [
              DataCell(nkChildWrappedSizeBox()),
              DataCell(nkChildWrappedSizeBox()),
              DataCell(MyRegularText(
                label: orderResponce.orderTotal
                    .toString()
                    .nkValueWithCurrencySymbol,
                fontSize: NkFontSize.largeFont(),
              )),
            ]),
          ]),
    );
  }

  Widget topUserDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyRegularText(
          label: orderResponce.customer?.first.fullname ?? '',
          fontSize: NkFontSize.largeFont(),
          fontWeight: NkGeneralSize.nkBoldFontWeight(),
        ),
        nkMediumSizeBox(),
        MyRegularText(
          label:
              "${orderResponce.customer?.first.email ?? ''}\n${orderResponce.customer?.first.mobileno ?? ''}",
        ),
        nkMediumSizeBox(),
        MyRegularText(
          label: "$invoice $dateStr : ${orderResponce.orderCreatAt ?? ''}",
        ),
        nkMediumSizeBox(),
        MyRegularText(
          label: "$invoice $numberStr : ${orderResponce.orderId ?? ''}",
        ),
      ],
    );
  }

  Widget ordersDetailsWidget() {
    return nkChildWrappedSizeBox(
      width: AppDimensions.instance.width,
      child: DataTable(
          border: const TableBorder(
              horizontalInside: BorderSide(color: dividerColor),
              bottom: BorderSide(
                color: Colors.black,
              )),
          horizontalMargin: 0,
          dividerThickness: 5,
          columns: headingColumns.map((e) {
            return DataColumn(
                label: MyRegularText(
              color: const Color(0xFF0F172A),
              label: e,
            ));
          }).toList(),
          rows: rowWidget()),
    );
  }

  List<DataRow> rowWidget() {
    return List.generate(orderResponce.cart!.length, (cartIndex) {
      return DataRow(
          cells: List.generate(
              rowCellItems(orderResponce.cart![cartIndex]).length,
              (index) => DataCell(
                  rowCellItems(orderResponce.cart![cartIndex])[index])));
    });
  }

  List<Widget> rowCellItems(CustomerCart cart) {
    return [
      itemWidget(cart.quantity.toString()),
      itemWidget(cart.variationName.toString()),
      itemWidget(cart.price.toString()),
      itemWidget(
          calculateSubTotalPrice(
                  num.parse(cart.price ?? "0").toInt(), cart.quantity ?? 0)
              .toString(),
          isBold: true),
    ];
  }

  int calculateSubTotalPrice(int productBAsePrice, int quantity) {
    return productBAsePrice * quantity;
  }

  Widget itemWidget(String itemName, {bool isBold = false}) {
    return MyRegularText(
      label: itemName,
      fontWeight: isBold
          ? NkGeneralSize.nkBoldFontWeight()
          : NkGeneralSize.nkGeneralFontWeight(),
    );
  }
}
