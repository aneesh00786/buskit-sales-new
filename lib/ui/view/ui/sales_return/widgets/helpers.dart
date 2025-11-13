
import 'dart:math';

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/model/sales_return_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/return_screen.dart' hide CustomText;
import 'package:flutter/material.dart';


Widget buildSalesReturnTableHeader1(Widget child, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: child,
    );
  }

  Widget buildSalesReturnTableHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: buildSalesReturnHeaderText('Order Details', 14)),
          Expanded(child: buildSalesReturnHeaderText('Invoice', 14)),
          Expanded(child: buildSalesReturnHeaderText('Delivered Date', 14)),
          Expanded(child: buildSalesReturnHeaderText('Order Amount', 14)),
          Expanded(child: buildSalesReturnHeaderText('Payment Status', 14)),
          Expanded(child: buildSalesReturnHeaderText('Status', 14)),
          Expanded(child: buildSalesReturnHeaderText('Action', 14)),
          // const Expanded(child: Text('')),
        ],
      ),
    );
  }

  Widget buildSalesReturnHeaderText(String text, double fontSize) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }

  Widget buildTableRow(
  BuildContext context,
  int index,
  double fixedRowHeight,
  GetRecentOrderReturnData salesReturnData,
) {
  return Container(
    color: index.isEven ? Colors.grey[50] : Colors.white,
    height: fixedRowHeight,
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Expanded(child: buildOrderDetails(salesReturnData)),
         
          Expanded(child: buildInvoice(salesReturnData)),
          Expanded(child: buildDeleveredDate(salesReturnData)),
         
          Expanded(child: buildOrderAmout(salesReturnData)),
          
          Expanded(child: buildPaymentStatus(salesReturnData)),
        
          Expanded(child: buildStatus(salesReturnData)),
          
          Expanded(child: buildAction(context,salesReturnData)),

        ],
      ),
  );
}

Widget buildOrderDetails(GetRecentOrderReturnData data){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomText(content: data.orderId, fontWeight: FontWeight.bold, fontSize: 14,),
      SizedBox(height: 4),
      CustomText(content: NKDateUtils.commonFullDateTimeFormat2(data.orderCreatAt!), fontSize: 12, ),
      SizedBox(height: 4),
      CustomText(content: 'Admin', fontSize: 12,),
    ],
  );
}
Widget buildInvoice(GetRecentOrderReturnData buildInvoiceData){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomText(content: buildInvoiceData.invoice!.invoiceId,fontWeight: FontWeight.bold,),
      SizedBox(height: 4),
      CustomText(content:NKDateUtils.commonFullDateTimeFormat2(buildInvoiceData.invoice!.createdAt!),)
    ],

  );
}
Widget buildDeleveredDate(GetRecentOrderReturnData DeliveredDateData){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomText(content: NKDateUtils.commonDayFormat(DeliveredDateData.deliveryDatetime!),fontWeight: FontWeight.bold,),
      CustomText(content: NKDateUtils.commonTimeOnlyFormat(DeliveredDateData.deliveryDatetime!),),
      CustomText(content: 'Admin',)
    ],
  );
}
Widget buildOrderAmout(GetRecentOrderReturnData orderAmountData){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomText(content: formatAmount(orderAmountData.orderTotal.toString()), fontWeight: FontWeight.bold, fontSize: 14,),
    ],
  );
}
Widget buildPaymentStatus(GetRecentOrderReturnData paymentStatusData){
  

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      
      
       paymentStatus({
        'payment_status': paymentStatusData.paymentStatus, // from API
      }),
    ],
  );
}
Widget buildStatus(GetRecentOrderReturnData statusData){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        children: [
          SizedBox(width: 45),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green
            ),
            onPressed: (){}, 
          child: CustomText(content: getStatusName.call(statusData.orderStatus!), fontWeight: FontWeight.bold, fontSize: 14,color: Colors.white,),
          )
          // CustomText(content: getStatusName.call(2), fontWeight: FontWeight.bold, fontSize: 14,),
        ],
      ),
    ],
  );
}
Widget paymentStatus(Map<String, dynamic> order) {
  final int paymentStatus = order['payment_status'] ?? -1;

  Color statusColor;
  IconData icon;

  switch (paymentStatus) {
    case 1: // Paid
      statusColor = Colors.green;
      icon = Icons.check;
      break;
    case 0: // Unpaid
      statusColor = Colors.red;
      icon = Icons.close;
      break;
    case 3: // Pending or Partial
      statusColor = Colors.yellow;
      icon = Icons.check;
      break;
    default: // Unknown or missing status
      statusColor = Colors.grey;
      icon = Icons.help_outline;
  }

  return Center(
    child: CircleAvatar(
      backgroundColor: statusColor,
      radius: 12,
      child: Icon(
        icon,
        size: 20,
        color: Colors.white,
      ),
    ),
  );
}


  Widget buildAction(BuildContext context,GetRecentOrderReturnData salesReturnData){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

      InkWell(
        onTap: () {
          print('Opening ProductReturnDialogContent with orderId: ${salesReturnData.orderId}');
         showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    content: SizedBox(
       width: isPhonePortrait(context)
            ? fullScreenWidth(context) * 2.3
            : fullScreenWidth(context) > 640
                ? fullScreenWidth(context) * 1
                : fullScreenWidth(context) * 1.1,  // Set desired width
      height: isPhonePortrait(context)
            ? fullScreenHeight(context) * 2.3
            : fullScreenHeight(context) > 640
                ? fullScreenHeight(context) * 1
                : fullScreenHeight(context) * 1.1,  // Set desired height
      child: ProductReturnDialogContent(
        orderId: salesReturnData.orderId!,
      ),
    ),
    
  ),
  
);
        },
        child: Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 16,color: Colors.white,),
                SizedBox(width: 6),
                CustomText(content: 'Return', fontSize: 14,color: Colors.white,),
              ],
            ),
          ),
        ),
      )
  //    
    ],
  );
}

