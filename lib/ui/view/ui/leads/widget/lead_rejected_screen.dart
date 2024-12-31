import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_select_status.dart';
import 'package:flutter/material.dart';

class LeadRejectedScreen extends StatefulWidget {
  final RejectedLeadsController rejectedLeadsController;

  const LeadRejectedScreen({super.key, required this.rejectedLeadsController});

  @override
  State<LeadRejectedScreen> createState() => _LeadRejectedScreenState();
}

class _LeadRejectedScreenState extends State<LeadRejectedScreen> {
  final ScrollController vertical = ScrollController();
  final ScrollController vertical1 = ScrollController();

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
        ? MediaQuery.of(context).size.height / 7.09
        : MediaQuery.of(context).size.height / 7 -
            MediaQuery.of(context).size.height * 0.032;
    return MyCommnonContainer(
        padding: EdgeInsets.zero,
        child: _buildTableLayout(context, fixedRowHeight));
  }

  Widget _buildTableLayout(BuildContext context, double fixedRowHeight) {
    double totalTableWidth = 110 + 340 + 130 + 130 + 130 + 130 + 150 + 90;
    return Container(
      child: Row(
        children: [
          SizedBox(
            width: 270,
            child: Column(
              children: [
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
                  270,
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
                          color: index.isEven ? Colors.grey[50] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
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
                                            'http://16.50.232.153:3000/uploads/${leadCustomerData.imageUrl ?? ''}',
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
                        ? Center(
                            child: NodataWidget(),
                          )
                        : Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: const ClampingScrollPhysics(),
                              controller: vertical1,
                              child: Column(
                                children: widget.rejectedLeadsController
                                    .rejectedLeadsDataList
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  LeadCustomerData leadCustomerData =
                                      entry.value;
                                  return _buildTableRow(leadCustomerData,
                                      context, index, fixedRowHeight);
                                }).toList(),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Expanded(child: _buildHeaderText('Address', 13)),
          Expanded(child: _buildHeaderText('Mobile No.', 13)),
          Expanded(child: _buildHeaderText('Town', 12)),
          Expanded(child: _buildHeaderText('State', 12)),
          Expanded(child: _buildHeaderText('Zip Code', 12)),
          Expanded(child: _buildHeaderText('Email', 12)),
          Expanded(child: _buildHeaderText('Contact Person', 12)),
          Expanded(child: _buildHeaderText('Contact Number', 12)),
          Expanded(child: _buildHeaderText('Status', 12)),
          SizedBox(width: 10),
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
          Expanded(
            child: CustomText(
              content: leadCustomerData.address ?? '',
              fontSize: 12,
              maxLine: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
              child: Center(
                  child: CustomText(
                      content: leadCustomerData.town ?? '', fontSize: 12))),
          Expanded(
              child: Center(
                  child: CustomText(
                      content: leadCustomerData.state ?? '', fontSize: 12))),
          Expanded(
              child: Center(
                  child: CustomText(
                      content: leadCustomerData.zipcode.toString(),
                      fontSize: 12))),
          Expanded(
              child: Center(
                  child: CustomText(
                      content: leadCustomerData.businessNo ?? '',
                      fontSize: 12))),
          SizedBox(width: 10),
          Expanded(
              child: Center(
                  child: CustomText(
                      content: leadCustomerData.email ?? '', fontSize: 12))),
          Expanded(
              child: Center(
                  child: CustomText(
                      content: leadCustomerData.fullname ?? '', fontSize: 12))),
          Expanded(
              child: Center(
                  child: CustomText(
                      content: leadCustomerData.mobileno ?? '', fontSize: 12))),
          Expanded(
            child:
                LeadsRejectedStatusSelect(customerId: leadCustomerData.id ?? 0),
          ),
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
