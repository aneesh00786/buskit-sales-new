import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadBottomScreen extends StatelessWidget {
  final LeadsController leadsController;

  const LeadBottomScreen({super.key, required this.leadsController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: MyCommnonContainer(
        child: Obx(() {
          return NkWidgetExceptionHandel(
              onRetryPressed: () => leadsController.loadLeadsCustomerData,
              data: leadsController.leadsCustomerDataList,
              child: leadBottomTabelWidget);
        }),
      ),
    );
  }

  Widget get leadBottomTabelWidget => SizedBox(
        width: AppDimensions.instance!.orientation == Orientation.landscape
            ? AppDimensions.instance!.width * 0.92
            : AppDimensions.instance!.width,
        child: DataTable(
            dataRowMaxHeight: 50,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => primaryColor),
            columns: leadBottomTabelColumnsWidget,
            rows: genratedRows),
      );

  List<DataColumn> get leadBottomTabelColumnsWidget =>
      leadsController.coustomerTabelsHeadersList
          .map((element) => DataColumn(
                  label: MyRegularText(
                label: element,
                color: buttonTextColor,
              )))
          .toList();

  List<DataRow> get genratedRows => leadsController.leadsCustomerDataList
      .map((e) => DataRow(
          cells: List.generate(
              rowsWidget(e).length, (index) => DataCell(rowsWidget(e)[index]))))
      .toList();

  List<Widget> rowsWidget(LeadCustomerData leadCustomerData) => [
        customerDetailsWidget(leadCustomerData),
        customerAddressWidget(leadCustomerData),
        customerTownWidget(leadCustomerData),
        customerZipWidget(leadCustomerData),
        leadsController.leadsCustomerStatus(
            leadsController.typeToConvertStatus(leadCustomerData.status!),
            assignedTo: leadCustomerData.salesmanName)
      ];

  Widget customerDetailsWidget(LeadCustomerData leadCustomerData) {
    return Row(children: [
      ClipOval(
        child: MyNetworkImage(
          imageUrl: leadCustomerData.imageUrl ?? '',
          height: AppDimensions.instance!.height * 0.09,
          width: AppDimensions.instance!.height * 0.09,
        ),
      ),
      nkSmallSizeBox(),
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            nkChildWrappedSizeBox(
              width: AppDimensions.instance!.width * 0.15,
              child: MyRegularText(
                align: TextAlign.start,
                label: leadCustomerData.fullname ?? '',
              ),
            ),
            MyRegularText(
              align: TextAlign.start,
              label: leadCustomerData.mobileno ?? '',
            ),
            MyRegularText(
              align: TextAlign.start,
              label: leadCustomerData.email ?? '',
            ),
          ])
    ]);
  }

  Widget customerAddressWidget(LeadCustomerData leadCustomerData) {
    return SizedBox(
      width: AppDimensions.instance!.width * 0.14,
      child: MyRegularText(
        align: TextAlign.start,
        label: leadCustomerData.address ?? '',
        maxlines: leadCustomerData.address?.length,
      ),
    );
  }

  Widget customerTownWidget(LeadCustomerData leadCustomerData) {
    return MyRegularText(
      label: leadCustomerData.town ?? '',
      maxlines: leadCustomerData.town?.length,
    );
  }

  Widget customerZipWidget(LeadCustomerData leadCustomerData) {
    return MyRegularText(
      label: leadCustomerData.zipcode?.toString() ?? '',
      maxlines: leadCustomerData.zipcode?.toString().length,
    );
  }
}
