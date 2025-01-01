import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<dynamic> showDashTimesDialogue(BuildContext context, BoxConstraints constraints, TopSellingProductA product) {
  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.zero,
                        titlePadding: EdgeInsets.zero,
                        content: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: constraints.maxWidth,
                                    child: MyRegularText(
                                      label:
                                          '${product.productName} - ${product.variationName}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxlines: 5,
                                    ),
                                  ),
                                  dialogCloseButton1(context, red),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                dataRowHeight: 30,
                                headingRowHeight: 35,
                                columnSpacing: 30,
                                columns: const [
                                  DataColumn(
                                    label: DialogTableHeaderText(
                                      text: 'Price',
                                      fontSize: 13,
                                    ),
                                  ),
                                  DataColumn(
                                    label: DialogTableHeaderText(
                                      text: 'Quantity',
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
                                      text: 'Purchased At',
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                rows: product.getTimesData!.map(
                                  (timesData) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Center(
                                          child: Text(
                                            formatAmount(timesData.price),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                            timesData.quantity.toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        )),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              timesData.totalPrice != null
                                                  ? formatAmount(
                                                      timesData.totalPrice)
                                                  : 'N/A',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              DateFormat('dd-MM-yyyy')
                                                  .format(
                                                      timesData.createdAt!)
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
}