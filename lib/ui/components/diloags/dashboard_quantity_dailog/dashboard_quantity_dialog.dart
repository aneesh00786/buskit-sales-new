// ignore_for_file: use_build_context_synchronously


import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../product_details_diloag/model/staff_responce.dart';

class DashBoardQuantityDialog extends StatefulWidget {
  final List<QuantityList> quantityList;

  const DashBoardQuantityDialog({super.key, required this.quantityList});

  @override
  State<DashBoardQuantityDialog> createState() =>
      _DashBoardQuantityDialogState();
}

class _DashBoardQuantityDialogState extends State<DashBoardQuantityDialog> {
  List<Salesman> salesmanList = [];

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return MyCommnonContainer(
        margin: AppDimensions.instance.orientation == Orientation.landscape
            ? nkExtraLargePadding(
                right: AppDimensions.instance.width * .28,
                left: AppDimensions.instance.width * .28)
            : nkExtraLargePadding(),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Column(
            children: [
              DiloagAppBar(
                title: "Date",
              ),
              salesmanList.isEmpty
                  ? Flexible(
                      child: ListView.separated(
                          padding: nkRegularPadding(bottom: 0, top: 0),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: nkSmallPadding(left: 0, right: 0),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashFactory: NoSplash.splashFactory,
                                onTap: () {
                                  salesmanList.clear();
                                  setState(() {
                                    salesmanList;
                                  });
                                },
                                child: staffDetailsWidget(
                                    widget.quantityList[index]),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Container(
                              color: Colors.grey,
                              height: 0.4,
                            );
                          },
                          itemCount: widget.quantityList.length),
                    )
                  : const SizedBox(),
              salesmanList.isNotEmpty
                  ? Flexible(
                      child: ListView.separated(
                          padding: nkRegularPadding(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: nkSmallPadding(left: 0, right: 0),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashFactory: NoSplash.splashFactory,
                                onTap: () {
                                  navigateTo(25.022702, 45.052659, context);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    customerDetailsWidget(salesmanList[index]),
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
                          itemCount: salesmanList.length),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      );
    });
  }

  static void navigateTo(double lat, double lng, BuildContext context) async {
    bool isOnline = await ConnectivityService().isOnline();
    if (isOnline) {
      const String homeLat = "37.3230";
      const String homeLng = "-122.0312";
      const String googleMapslocationUrl =
          "https://www.google.com/maps/search/?api=1&query=$homeLat,$homeLng";
      final String encodedURl = Uri.encodeFull(googleMapslocationUrl);
      var uri = Uri.parse(encodedURl);
      await launchUrl(uri);
    } else {
      showCustomToastDisplay(context, "You are Offline!",red, Icons.warning);
    }
  }

  Widget staffDetailsWidget(QuantityList staffData) {
    return MyCommnonContainer(
      child: Padding(
        padding: nkMediumPadding(top: 0, bottom: 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              MyRegularText(
                label: DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(staffData.createdAt ?? '')),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              MyRegularText(
                label: '${staffData.quantity ?? 0}',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )
            ]),
      ),
    );
  }

  Widget customerDetailsWidget(Salesman customerData) {
    return MyCommnonContainer(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ClipOval(
          child: MyNetworkImage(
            imageUrl: customerData.imageUrl ?? '',
            height: AppDimensions.instance.height * 0.06,
            width: AppDimensions.instance.height * 0.06,
          ),
        ),
        nkSmallSizeBox(),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRegularText(
                label: customerData.fullname ?? '',
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
