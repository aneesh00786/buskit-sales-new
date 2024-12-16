import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/option_list.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/options_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart'
    as model1;
import 'package:provider/provider.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool isActive = false;
  StaffController staffController = Get.put(StaffController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        actions: [
          profiloe(),
        ],
      ),
      body: Column(
        children: [
          OptionsWidget(options: defaultOption(context)),
          nkMediumSizeBox(),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.4,
                      ),
                    ),
                    child: Consumer<DashboardProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<model1.ResponseModell>(
                          future: provider.futureResponseModel,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SpinKitFadingCube(
                                  color: primaryColor,
                                  size: 20.0,
                                ),
                              );
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const Center(
                                child: NodataWidget(),
                                // child: Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Icon(Icons.error_outline,
                                //         size: 50, color: Colors.red),
                                //     Text(
                                //       "Our servers are currently down for maintenance. We’re working to resolve the issue as quickly as possible. Please check back soon, and thank you for your understanding.",
                                //     ),
                                //   ],
                                // ),
                              );
                            } else if (snapshot.hasData) {
                              final categories = snapshot.data!.allCategory;
                              final categoryPerformance =
                                  snapshot.data!.categoryPerformance;

                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                              255, 211, 211, 211)
                                          .withOpacity(0.2),
                                      blurRadius: 5,
                                      spreadRadius: 5,
                                      offset: Offset(4, 4),
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 205, 204, 204),
                                    width: 0.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomBarChart(
                                    categoryPerformance: categoryPerformance!,
                                    allCategory: categories!,
                                  ),
                                ),
                              );
                            } else {
                              return const NodataWidget();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
                nkMediumSizeBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 211, 211, 211)
                              .withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 5,
                          offset: Offset(4, 4),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color.fromARGB(255, 205, 204, 204),
                        width: 0.5,
                      ),
                    ),
                    child: StaffTargetDialog(
                      staffController: staffController,
                    ),
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
