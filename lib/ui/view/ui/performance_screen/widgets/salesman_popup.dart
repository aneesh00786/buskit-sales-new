// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSalesmanPopup(int cid, String category, BuildContext context,
    String staffProjection) async {
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
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.zero,
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: FutureBuilder<ResponseModelCp>(
                  future: provider.responseModelCp,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final categories = snapshot.data!.data;
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, Color(0xFF2D3748)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
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
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  InkResponse(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Icon(Icons.close,
                                          color: Colors.white, size: 22),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: DataTable(
                                  headingRowHeight: 42,
                                  dataRowHeight: 34,
                                  columnSpacing: 40,
                                  headingRowColor: const WidgetStatePropertyAll(
                                      primaryColor),
                                  dataRowColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.white),
                                  border: TableBorder.all(
                                      color: const Color(0xFFE2E8F0), width: 1),
                                  columns: [
                                    const DataColumn(
                                      label: _HeaderLabel('Name'),
                                    ),
                                    // if (widget.targetType == "1")
                                    const DataColumn(
                                      label: _HeaderLabel('Target'),
                                    ),
                                    if (staffProjection == "1")
                                      const DataColumn(
                                        label: _HeaderLabel('Projection'),
                                      ),
                                    const DataColumn(
                                      label: _HeaderLabel('Actual'),
                                    ),
                                  ],
                                  rows:
                                      categories!.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final s = entry.value;
                                    return DataRow(
                                      color: WidgetStatePropertyAll(
                                        index.isOdd
                                            ? const Color(0xFFF8FAFC)
                                            : Colors.white,
                                      ),
                                      cells: [
                                        DataCell(
                                          Center(
                                            child: Text(
                                              s.fullname,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins_Regular',
                                                color: Color(0xFF0F172A),
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
                                                fontFamily: 'Poppins_Regular',
                                                color: Color(0xFF0F172A),
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
                                                  fontFamily: 'Poppins_Regular',
                                                  color: Color(0xFF0F172A),
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
                                                fontFamily: 'Poppins_Regular',
                                                color: Color(0xFF0F172A),
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
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const NodataWidget();
                    }
                  },
                ),
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

class _HeaderLabel extends StatelessWidget {
  final String text;
  const _HeaderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins_Regular',
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}
