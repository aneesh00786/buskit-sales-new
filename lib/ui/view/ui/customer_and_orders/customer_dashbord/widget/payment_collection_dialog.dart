  // ignore_for_file: deprecated_member_use

  import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/editabledatacell_new.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';

void paymentCollectionDialog(
      BuildContext context, List<RecentOrder> selectedOrders) {
    List<num?> newOrderTotal =
        selectedOrders.map((order) => order.orderTotal).toList();

    // List<int?> _newOrderTotal = [];

    // // Populate _newOrderTotal with orderTotal values
    // for (var order in selectedOrders) {
    //   _newOrderTotal[selectedOrders.indexOf(order)] = order.orderTotal;
    // }

    // Function to calculate the total balance amount from _newOrderTotal
    double calculateTotalBalanceAmount() {
      return newOrderTotal.fold(0, (sum, value) => sum + (value ?? 0));
    }

    // Calculate the initial total balance amount
    double totalBalanceAmount = calculateTotalBalanceAmount();

    final balanceAmountController = TextEditingController(
      text: totalBalanceAmount.toStringAsFixed(2),
    );

    String selectedPaymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 45,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    //Color(0xff008000),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      dialogCloseButton1(context, red),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DataTable(
                          dataRowHeight: 30,
                          headingRowHeight: 40,
                          columnSpacing: 30,
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns: const [
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Date',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Invoice',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Amount',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Status',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Receivable',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Payment',
                                fontSize: 13,
                              ),
                            ),
                          ],
                          rows: selectedOrders.asMap().entries.map((entry) {
                            int index = entry.key;
                            RecentOrder order = entry.value;
                            return DataRow(cells: [
                              DataCell(Center(
                                  child: Text(getFormattedOrderCreatAt(
                                      order.orderCreatAt)))),
                              DataCell(Center(
                                child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InvoicePreview(
                                      orderId: order.orderId,
                                    );
                                  },
                                );
                              },
                              child: Text(
                                order.invoiceId,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                              ),
                            ))),
                              DataCell(Center(
                                  child: Text(formatAmount(order.orderTotal)))),
                              DataCell(Center(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    //Color(0xff008000),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      getStatusName(order.orderStatus),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3.0),
                                  child: EditableDataCell(
                                    initialValue: order.orderTotal.toString(),
                                    index: index, // Pass index
                                    orderId: order.orderId,
                                    orderTotal: order.orderTotal,
                                    onValueChanged: (newValue, index) {
                                     // setState(() {
                                        newOrderTotal[index] =
                                            int.tryParse(newValue);
                                        totalBalanceAmount =
                                            calculateTotalBalanceAmount();
                                        balanceAmountController.text =
                                            totalBalanceAmount
                                                .toStringAsFixed(2);
                                    //  });
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: order.paymentStatus == 0
                                          ? Colors.red
                                          : Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: order.paymentStatus == 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Icon(
                                        order.paymentStatus == 0
                                            ? Icons.close
                                            : Icons.done,
                                        color: Colors.white,
                                        size: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DataTable(
                          dataRowHeight: 35,
                          headingRowHeight: 30,
                          columns: const [
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Payment Method',
                                fontSize: 11,
                                align: TextAlign.start,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Balance Amount',
                                fontSize: 11,
                                align: TextAlign.start,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Received Amount',
                                fontSize: 11,
                                align: TextAlign.start,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Remarks',
                                fontSize: 11,
                                align: TextAlign.start,
                              ),
                            ),
                            DataColumn(label: IntrinsicWidth(child: Text(''))),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    height: 35,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: DropdownButtonFormField<String>(
                                      value: selectedPaymentMethod,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                      ),
                                      dropdownColor: Colors.white,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Cash',
                                            child: Text('Cash')),
                                        DropdownMenuItem(
                                            value: 'Cheque',
                                            child: Text('Cheque')),
                                        DropdownMenuItem(
                                            value: 'Bank Transfer',
                                            child: Text('Bank Transfer')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          //setState(() {
                                            selectedPaymentMethod = value;
                                          //});
                                        }
                                      },
                                      hint: const Text('Select'),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          size: 24.0, color: Colors.black),
                                      iconSize: 24.0,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: TextField(
                                      readOnly: true,
                                      controller: balanceAmountController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        hintText: 'Balance Amount',
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                        contentPadding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 10.0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        hintText: 'Received Amount',
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                        contentPadding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 10.0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        hintText: 'Remarks',
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                        contentPadding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 10.0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Save or submit action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor:
                                            primaryColor.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Submit',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
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
              ],
            ),
          ),
        );
      },
    );
  }