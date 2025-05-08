import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_pagination/leads_reject_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_select_status.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_table_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class LeadRejectedScreen extends StatefulWidget {
  final RejectedLeadsController rejectedLeadsController;

  const LeadRejectedScreen({super.key, required this.rejectedLeadsController});

  @override
  State<LeadRejectedScreen> createState() => _LeadRejectedScreenState();
}

class _LeadRejectedScreenState extends State<LeadRejectedScreen> {
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
      borderRadius: 0,
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
          width: 270,
          child: Column(
            children: [
              Row(
                children: [
                  _buildTableHeader1(
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
                  _buildTableHeader1(
                    Center(
                      child: CustomText(
                        content: "Customers",
                        textAlign: TextAlign.center,
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    210,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: vertical,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: widget
                        .rejectedLeadsController.rejectedLeadsDataList
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
                                      '   ${((widget.rejectedLeadsController.currentPage.value - 1) * 10) + (index + 1)}.',
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
              if (widget.rejectedLeadsController.totalPages.value > 1)
                Container(
                  padding: const EdgeInsets.all(3),
                  height: 50,
                  color: Colors.grey[200],
                  child: Row(
                    children: [LeadsRejectedPaginationWidget(), const Spacer()],
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
                  SizedBox(child: _buildTableHeader()),
                  widget.rejectedLeadsController.rejectedLeadsDataList.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4)
                      : Container(),
                  widget.rejectedLeadsController.rejectedLeadsDataList.isEmpty
                      ? const Center(
                          child: NodataWidget(),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics: const ClampingScrollPhysics(),
                            controller: vertical1,
                            child: Column(
                              children: widget
                                  .rejectedLeadsController.rejectedLeadsDataList
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                LeadCustomerData leadCustomerData = entry.value;
                                return _buildTableRow(leadCustomerData, context,
                                    index, fixedRowHeight);
                              }).toList(),
                            ),
                          ),
                        ),
                  if (widget.rejectedLeadsController.totalPages.value > 1)
                    Container(
                      padding: const EdgeInsets.all(3),
                      height: 50,
                      color: Colors.grey[200],
                    ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          Expanded(child: _buildHeaderText('Address', 13)),
          Expanded(child: _buildHeaderText('Mobile No.', 13)),
          Expanded(child: _buildHeaderText('Town', 12)),
          Expanded(child: _buildHeaderText('State', 12)),
          Expanded(child: _buildHeaderText('Zip Code', 12)),
          Expanded(child: _buildHeaderText('Email', 12)),
          Expanded(child: _buildHeaderText('Contact Person', 12)),
          Expanded(child: _buildHeaderText('Contact Number', 12)),
          Expanded(child: _buildHeaderText('Status', 13)),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, double fontSize) {
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

  Widget _buildTableRow(LeadCustomerData leadCustomerData, BuildContext context,
      int index, double fixedRowHeight) {
    return Container(
      color: index.isEven ? Colors.grey[50] : Colors.white,
      height: fixedRowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.address ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.town ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.state ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.zipcode.toString(),
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.businessNo ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.email ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.fullname ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.mobileno ?? '',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Stack(
                children: [
                  AbsorbPointer(
                    absorbing:
                        subscriptionController.leadConversion.value != "true",
                    child: LeadsRejectedStatusSelect(
                      customerId: leadCustomerData.id!.toInt(),
                    ),
                  ),
                  if (subscriptionController.leadConversion.value != "true")
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showUpgradePlanDialog(context);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableHeader1(Widget child, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: child,
    );
  }
}
