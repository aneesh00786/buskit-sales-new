import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectCustomerDiloag extends StatefulWidget {
  final DateTime dateTime;

  // final List<CustomerDetails> customerDataList;
  final List<Customer> customerlist;

  const SelectCustomerDiloag(
      {super.key, required this.customerlist, required this.dateTime});

  @override
  State<SelectCustomerDiloag> createState() => _SelectCustomerDiloagState();
}
class _SelectCustomerDiloagState extends State<SelectCustomerDiloag> {
  @override
  Widget build(BuildContext context) {
    log('CustomerList Length : ${widget.customerlist.length}');
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
                title: "Customer Visit For Today",
              ),
              widget.customerlist.isNotEmpty
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
                                  navigateTo(25.022702, 45.052659);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    customerDetailsWidget(
                                        widget.customerlist[index]),
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
                          itemCount: widget.customerlist.length),
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
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // } else {
    //   throw 'Could not launch ${uri.toString()}';
    // }
  }

  /*Widget staffDetailsWidget(SalesmanCalenderEvent staffData) {
    return MyCommnonContainer(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ClipOval(
          child: MyNetworkImage(
            imageUrl: staffData.imagePath ?? '',
            height: AppDimensions.instance!.height * 0.06,
            width: AppDimensions.instance!.height * 0.06,
          ),
        ),
        nkSmallSizeBox(),
        SizedBox(
          width: AppDimensions.instance!.height * 0.4,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyRegularText(
                  label: staffData.fullname ?? '',
                ),
                MyRegularText(
                  label: staffData.mobileno ?? '',
                ),
                MyRegularText(
                  label: staffData.email ?? '',
                ),
              ]),
        ),
        MyRegularText(
          label: '${staffData.customer?.length ?? 0}',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        )
      ]),
    );
  }*/

  Widget customerDetailsWidget(Customer customerData) {
    return MyCommnonContainer(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ClipOval(
          child: MyNetworkImage(
            imageUrl: '',
            // imageUrl: customerData.imageUrl ?? '',
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
