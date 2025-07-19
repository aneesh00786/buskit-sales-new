import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_pagination/leads_bottom_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_bottom_screen/widgets/build_table_row.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_bottom_screen/widgets/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadBottomScreen extends StatefulWidget {
  final LeadsController leadsController;
  const LeadBottomScreen({super.key, required this.leadsController});
  @override
  State<LeadBottomScreen> createState() => _LeadBottomScreenState();
}

class _LeadBottomScreenState extends State<LeadBottomScreen> {
  final ScrollController vertical = ScrollController();
  final ScrollController vertical1 = ScrollController();
  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();
    vertical.addListener(() {
      if (vertical1.hasClients &&
          vertical.position.pixels != vertical1.position.pixels) {
        vertical1.jumpTo(vertical.position.pixels);
      }
    });

    vertical1.addListener(() {
      if (vertical.hasClients &&
          vertical1.position.pixels != vertical.position.pixels) {
        vertical.jumpTo(vertical1.position.pixels);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double fixedRowHeight = isLandscape
        ? MediaQuery.of(context).size.height / 10.09
        : MediaQuery.of(context).size.height / 10 -
            MediaQuery.of(context).size.height * 0.018;

    return MyCommnonContainer(
      padding: EdgeInsets.zero,
      child: Obx(() {
        return _buildTableLayout(context, fixedRowHeight);
      }),
    );
  }

  Widget _buildTableLayout(BuildContext context, double fixedRowHeight) {
    double totalTableWidth = 130 + 360 + 150 + 150 + 150 + 150 + 150 + 110;
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Column(
            children: [
              Row(
                children: [
                  buildTableHeader1(
                    Center(
                      child: CustomText(
                        content: "Sl.No.",
                        textAlign: TextAlign.center,
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    60,
                  ),
                  buildTableHeader1(
                    Center(
                      child: CustomText(
                        content: "Leads",
                        textAlign: TextAlign.center,
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    240,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: vertical,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: widget.leadsController.leadsCustomerDataList
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      LeadCustomerData leadCustomerData = entry.value;

                      return Container(
                        height: fixedRowHeight,
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.grey[50] : Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: CustomText(
                                  content:
                                      '   ${((widget.leadsController.currentPage.value - 1) * 10) + (index + 1)}.',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        color: Colors.grey[200],
                                        child: Image.network(
                                          '${ApiConstants.baseUrl}uploads/${leadCustomerData.imageUrl ?? ''}',
                                          fit: BoxFit.cover,
                                          width: 25,
                                          height: 25,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.blue,
                                                size: 34,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    CustomText(
                                      content:
                                          leadCustomerData.businessName ?? '',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (widget.leadsController.totalPages > 1)
                Container(
                  padding: const EdgeInsets.all(3),
                  height: 50,
                  color: Colors.grey[200],
                  child: Row(
                    children: [LeadsBottomPaginationWidget(), const Spacer()],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalTableWidth,
              child: Column(
                children: [
                  SizedBox(child: buildTableHeader()),
                  widget.leadsController.leadsCustomerDataList.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4)
                      : Container(),
                  widget.leadsController.leadsCustomerDataList.isEmpty
                      ? const Center(child: NodataWidget())
                      : Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics: const ClampingScrollPhysics(),
                            controller: vertical1,
                            child: Column(
                              children: widget
                                  .leadsController.leadsCustomerDataList
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                LeadCustomerData leadCustomerData = entry.value;
                                return buildTableRow(leadCustomerData, context,
                                    index, fixedRowHeight,widget.leadsController,subscriptionController);
                              }).toList(),
                            ),
                          ),
                        ),
                        if (widget.leadsController.totalPages > 1)
                    Container(
                      padding: const EdgeInsets.all(3),
                      height: 50,
                      color: Colors.grey[200],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


