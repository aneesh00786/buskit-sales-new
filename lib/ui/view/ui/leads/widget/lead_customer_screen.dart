import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';

class LeadCustomerScreen extends StatelessWidget {
  final CustomersController leadsCustomerController;

  const LeadCustomerScreen({super.key, required this.leadsCustomerController});

  @override
  Widget build(BuildContext context) {
    return MyCommnonContainer(
        padding: EdgeInsets.zero, child: _buildTableLayout(context));
  }

  Widget _buildTableLayout(BuildContext context) {
    return Column(
      children: [
        _buildTableHeader(),
        leadsCustomerController.customersDataList.isEmpty
            ? SizedBox(height: MediaQuery.of(context).size.height * 0.4)
            : Container(),
        leadsCustomerController.customersDataList.isEmpty
            ? Center(
                child: NodataWidget(),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: leadsCustomerController.customersDataList
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      LeadCustomerData leadCustomerData = entry.value;
                      return _buildTableRow(leadCustomerData, context, index);
                    }).toList(),
                  ),
                ),
              ),
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
          SizedBox(width: 10),
          Expanded(flex: 2, child: _buildHeaderText('Customers', 13)),
          Expanded(child: _buildHeaderText('Address', 13)),
          Expanded(child: _buildHeaderText('Mobile', 13)),
          Expanded(child: _buildHeaderText('Email', 13)),
          Expanded(child: _buildHeaderText('C. Person', 13)),
          Expanded(child: _buildHeaderText('C. Number', 13)),
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

  Widget _buildTableRow(
      LeadCustomerData leadCustomerData, BuildContext context, int index) {
    return Container(
      color: index.isEven ? Colors.grey[50] : Colors.white,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.grey[200],
                    child: Image.network(
                      'http://16.50.232.153:3000/uploads/${leadCustomerData.imageUrl}' ??
                          '',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.person,
                              color: Colors.blue, size: 34),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    content: leadCustomerData.businessName ?? '',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  content: leadCustomerData.address ?? '',
                  fontSize: 11,
                  maxLine: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  content: leadCustomerData.town ?? '',
                  fontSize: 11,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  content: leadCustomerData.state ?? '',
                  fontSize: 11,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  content: leadCustomerData.zipcode?.toString() ?? '',
                  fontSize: 11,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
                child: CustomText(
                    content: leadCustomerData.businessNo ?? '', fontSize: 11)),
          ),
          Expanded(
            child: Center(
                child: CustomText(
                    content: leadCustomerData.email ?? '', fontSize: 11)),
          ),
          Expanded(
            child: Center(
                child: CustomText(
                    content: leadCustomerData.fullname ?? '',
                    // 'Fullname',
                    fontSize: 11)),
          ),
          Expanded(
            child: Center(
                child: CustomText(
                    content: leadCustomerData.mobileno ?? '',
                    // 'Mobileno',
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
