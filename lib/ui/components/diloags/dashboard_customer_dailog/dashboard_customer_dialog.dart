
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../product_details_diloag/model/staff_responce.dart';

class DashBoardCustomerDialog extends StatefulWidget {
  final List<Customer> customerList;

  const DashBoardCustomerDialog({
    super.key,
    required this.customerList,
  });

  @override
  State<DashBoardCustomerDialog> createState() =>
      _DashBoardCustomerDialogState();
}

class _DashBoardCustomerDialogState extends State<DashBoardCustomerDialog> {
  List<Salesman> salesmanList = [];
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return MyCommnonContainer(
        margin: AppDimensions.instance!.orientation == Orientation.landscape
            ? nkExtraLargePadding(
                right: AppDimensions.instance!.width * .28,
                left: AppDimensions.instance!.width * .28)
            : nkExtraLargePadding(),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Column(
            children: [
              DiloagAppBar(
                title: "Customer List",
              ),
              widget.customerList.isNotEmpty
                  ?
                  //widget.staffController.customerAndOrderList.isNotEmpty?
                  Flexible(
                      child: ListView.separated(
                          padding: nkRegularPadding(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: nkSmallPadding(left: 0, right: 0),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashFactory: NoSplash.splashFactory,
                                onTap: () {
                                  //navigateTo(25.022702, 45.052659);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    customerDetailsWidget(
                                        widget.customerList[index]),
                                    //  widget.staffController.customerAndOrderList[index]),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Container(
                              color: Colors.grey,
                              height: 0.4,
                            );
                          },
                          itemCount: widget.customerList.length),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      );
    });
  }

  static void navigateTo(double lat, double lng) async {
    const String homeLat = "37.3230";
    const String homeLng = "-122.0312";
    const String googleMapslocationUrl =
        "https://www.google.com/maps/search/?api=1&query=${homeLat},${homeLng}";
    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);
    var uri = Uri.parse(encodedURl);
    await launchUrl(uri);
  }

  Widget customerDetailsWidget(Customer customerData) {
    return MyCommnonContainer(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ClipOval(
          child: MyNetworkImage(
            imageUrl: customerData.imageUrl ?? '',
            height: AppDimensions.instance!.height * 0.06,
            width: AppDimensions.instance!.height * 0.06,
          ),
        ),
        nkSmallSizeBox(),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRegularText(
                label: customerData.fullname.toString(),
              ),
              MyRegularText(
                label: customerData.mobileno ?? '',
              ),
              MyRegularText(
                label: customerData.email ?? '',
              ),
            ])
      ]),
    );
  }
}
