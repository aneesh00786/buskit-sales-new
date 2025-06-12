  // ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSalesmanPopup(int cid, String category,BuildContext context,String staffProjection) async {
    bool isConnected = await ConnectivityService().isOnline();
    if (isConnected) {
      showDialog(
        context: context,
        builder: (context) {
          return Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              provider.fetchchartCategoryPerformmenc(cid);
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.zero,
                titlePadding: EdgeInsets.zero,
                content: FutureBuilder<ResponseModelCp>(
                  future: provider.responseModelCp,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      final categories = snapshot.data!.data;
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  dialogCloseButton1(context, red)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                headingRowHeight: 40,
                                dataRowHeight: 30,
                                columnSpacing: 40,
                                headingRowColor: WidgetStatePropertyAll(
                                    Colors.blueGrey.shade50),
                                border: TableBorder.all(
                                    color: Colors.grey, width: 1),
                                columns: [
                                  const DataColumn(
                                    label: DialogTableHeaderText(
                                      text: 'Name',
                                      fontSize: 13,
                                    ),
                                  ),
                                  // if (widget.targetType == "1")
                                  const DataColumn(
                                    label: DialogTableHeaderText(
                                      text: 'Target',
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (staffProjection == "1")
                                    const DataColumn(
                                      label: DialogTableHeaderText(
                                        text: 'Projection',
                                        fontSize: 13,
                                      ),
                                    ),
                                  const DataColumn(
                                    label: DialogTableHeaderText(
                                      text: 'Actual',
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                rows: categories!.map((s) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: Text(
                                            s.fullname,
                                            style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // if (widget.targetType == "1")
                                      DataCell(
                                        Center(
                                          child: Text(
                                            formatAmount(s.targetTotal),
                                            style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (staffProjection == "1")
                                        DataCell(
                                          Center(
                                            child: Text(
                                              formatAmount(s.projectionTotal),
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
                                            formatAmount(s.orderTotal),
                                            style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const NodataWidget();
                    }
                  },
                ),
              );
            },
          );
        },
      );
    } else {
      errorSnackbar("No internet connection . please check your network");
    }
  }
  
