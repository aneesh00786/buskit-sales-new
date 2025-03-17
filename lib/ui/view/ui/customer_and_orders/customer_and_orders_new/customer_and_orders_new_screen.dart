import 'dart:math';

import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/customer_and_orders_top_widgets.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerAndOrdersNewScreen extends StatefulWidget {
  const CustomerAndOrdersNewScreen();

  @override
  _CustomerAndOrdersNewScreenState createState() =>
      _CustomerAndOrdersNewScreenState();
}

class _CustomerAndOrdersNewScreenState
    extends State<CustomerAndOrdersNewScreen> {
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  StaffController staffController = Get.put(StaffController());

  LeadsController leadsController = Get.put(LeadsController());

  List<Choice> choices = <Choice>[
    Choice(
        title: 'Total Sales',
        icon: "assets/icons/barchart.png",
        subtext: "\$25500"),
    Choice(
        title: 'Sales-Orders',
        icon: "assets/icons/pricetag.png",
        subtext: "13-\$8500"),
    Choice(title: 'Delivery', icon: "assets/icons/delivery.png", subtext: "15"),
    Choice(title: 'Payment', icon: "assets/icons/dollar.png", subtext: "32"),
    Choice(
        title: 'Estimated',
        icon: "assets/icons/clock.png",
        subtext: "13-\$850"),
    Choice(
        title: 'Pre-Orders',
        icon: "assets/icons/preorder.png",
        subtext: "13-\$850"),
    Choice(title: 'Draft', icon: "assets/icons/draft.png", subtext: "09"),
    Choice(title: 'Cancelled', icon: "assets/icons/cancel.png", subtext: "10"),
    Choice(title: 'Visit', icon: "assets/icons/placeholder.png", subtext: "5"),
    Choice(
        title: 'Allocated Salesman',
        icon: "assets/icons/salesman.png",
        subtext: ""),
    Choice(title: 'Discount', icon: "assets/icons/discount.png", subtext: ""),
    Choice(
        title: 'Credit Period',
        icon: "assets/icons/creditcard.png",
        subtext: ""),
  ];

  @override
  void initState() {
    customerAndOrderController.loadCustomer;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return Scaffold(
        body: Padding(
          padding: nkRegularPadding(),
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              await customerAndOrderController.loadCustomer;
            },
            child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (PaginationModel.onScrollNotification(notification)) {
                    print("WORKINGGGGGGG ");
                    return false;
                  } else {
                    print("Not WORKINGGGGG");
                    return false;
                  }
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        width: (MediaQuery.of(context).orientation ==
                                Orientation.portrait)
                            ? AppDimensions.instance!.width / 5
                            : AppDimensions.instance!.width / 4,
                        height: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(6),
                                child: Container(
                                  height: ResponsiveInfo.isMobile() ? 50 : 70,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 2.0,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xff737cf6)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    child: Text(
                                                      "Customer",
                                                      style: TextStyle(
                                                          fontSize:
                                                              ResponsiveInfo
                                                                      .isMobile()
                                                                  ? 5
                                                                  : 10,
                                                          color: Colors.white),
                                                    ),
                                                    padding: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: 0,
                                                        right: 0,
                                                        left: ResponsiveInfo
                                                                .isMobile()
                                                            ? 4
                                                            : 5),
                                                  ),
                                                  flex: 1,
                                                ),
                                                Expanded(
                                                  child: Icon(Icons.add_circle,
                                                      size: ResponsiveInfo
                                                              .isMobile()
                                                          ? 20
                                                          : 23,
                                                      color: Colors.white),
                                                  flex: 1,
                                                )
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(5),
                                        ),
                                        flex: 1,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 2.0,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xffdddefc)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    child: Text(
                                                      "Leads",
                                                      style: TextStyle(
                                                          fontSize:
                                                              ResponsiveInfo
                                                                      .isMobile()
                                                                  ? 5
                                                                  : 10,
                                                          color: Color(
                                                              0xff737cf6)),
                                                    ),
                                                    padding: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: 0,
                                                        right: 0,
                                                        left: ResponsiveInfo
                                                                .isMobile()
                                                            ? 4
                                                            : 5),
                                                  ),
                                                  flex: 1,
                                                ),
                                                Expanded(
                                                  child: Icon(Icons.add_circle,
                                                      size: ResponsiveInfo
                                                              .isMobile()
                                                          ? 20
                                                          : 23,
                                                      color: Color(0xff737cf6)),
                                                  flex: 1,
                                                )
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(5),
                                        ),
                                        flex: 1,
                                      ),
                                    ],
                                  ),
                                )),
                            CustomerAndOrdersTopWidgets(
                              customerAndOrderController:
                                  customerAndOrderController,
                              staffDataList: staffController.staffDataList,
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 0.5,
                        height: double.infinity,
                        color: Colors.black26,
                      ),
                      Container(
                        width: (MediaQuery.of(context).orientation ==
                                Orientation.portrait)
                            ? AppDimensions.instance!.width / 2.5
                            : AppDimensions.instance!.width / 1.8,
                        height: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(6),
                                child: Container(
                                  height: ResponsiveInfo.isMobile() ? 45 : 65,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 2.0,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xffeef1f7)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    child: Text(
                                                      "2023",
                                                      style: TextStyle(
                                                          fontSize:
                                                              ResponsiveInfo
                                                                      .isMobile()
                                                                  ? 5
                                                                  : 10,
                                                          color: Colors.black87,
                                                          fontFamily:
                                                              'SIde_Bar_icon'),
                                                    ),
                                                    padding: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: 0,
                                                        right: 0,
                                                        left: ResponsiveInfo
                                                                .isMobile()
                                                            ? 4
                                                            : 5),
                                                  ),
                                                  flex: 1,
                                                ),
                                                Expanded(
                                                  child: Icon(Icons.date_range,
                                                      size: ResponsiveInfo
                                                              .isMobile()
                                                          ? 20
                                                          : 23,
                                                      color: Colors.black87),
                                                  flex: 1,
                                                )
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(5),
                                        ),
                                        flex: 1,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 2.0,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xffdddefc)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    child: Text(
                                                      "Range",
                                                      style: TextStyle(
                                                          fontSize:
                                                              ResponsiveInfo
                                                                      .isMobile()
                                                                  ? 5
                                                                  : 10,
                                                          color:
                                                              Color(0xff727cf5),
                                                          fontFamily:
                                                              'SIde_Bar_icon'),
                                                    ),
                                                    padding: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: 0,
                                                        right: 0,
                                                        left: ResponsiveInfo
                                                                .isMobile()
                                                            ? 4
                                                            : 5),
                                                  ),
                                                  flex: 1,
                                                ),
                                                Expanded(
                                                  child: SizedBox(
                                                    width: ResponsiveInfo
                                                            .isMobile()
                                                        ? 20
                                                        : 23,
                                                    height: ResponsiveInfo
                                                            .isMobile()
                                                        ? 20
                                                        : 23,
                                                  ),
                                                  flex: 1,
                                                )
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(5),
                                        ),
                                        flex: 1,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 0.0,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xffeef1f7)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  child: Text(
                                                    "31 Jan 2023",
                                                    style: TextStyle(
                                                        fontSize: ResponsiveInfo
                                                                .isMobile()
                                                            ? 5
                                                            : 9,
                                                        color: Colors.black87,
                                                        fontFamily:
                                                            'SIde_Bar_icon'),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      top: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5,
                                                      bottom: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5,
                                                      right: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5,
                                                      left: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5),
                                                )
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(5),
                                        ),
                                        flex: 1,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 0.0,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xffeef1f7)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  child: Text(
                                                    "1 Feb 2023",
                                                    style: TextStyle(
                                                        fontSize: ResponsiveInfo
                                                                .isMobile()
                                                            ? 5
                                                            : 10,
                                                        color: Colors.black87,
                                                        fontFamily:
                                                            'SIde_Bar_icon'),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      top: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5,
                                                      bottom: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5,
                                                      right: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5,
                                                      left: ResponsiveInfo
                                                              .isMobile()
                                                          ? 4
                                                          : 5),
                                                )
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(5),
                                        ),
                                        flex: 1,
                                      ),
                                    ],
                                  ),
                                )),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: FractionalOffset.centerRight,
                                    child: ElevatedButton(
                                      child: Text('    Go    ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'SIde_Bar_icon')),
                                      style: ElevatedButton.styleFrom(
                                          //   primary: Color(0xff727df5),
                                          ),
                                      onPressed: () {
                                        print('Pressed');
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                                child: Padding(
                              padding: EdgeInsets.all(
                                  ResponsiveInfo.isMobile() ? 5 : 8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: GridView.count(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 5.0,
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    primary: false,
                                    children:
                                        List.generate(choices.length, (index) {
                                      return Center(
                                        child: Container(
                                          width: (MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.portrait)
                                              ? (ResponsiveInfo.isMobile()
                                                  ? 120
                                                  : 150)
                                              : (ResponsiveInfo.isMobile()
                                                  ? 140
                                                  : 200),
                                          height: (MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.portrait)
                                              ? (ResponsiveInfo.isMobile()
                                                  ? 120
                                                  : 150)
                                              : (ResponsiveInfo.isMobile()
                                                  ? 140
                                                  : 200),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xff727df5),
                                                  width: 2.0,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.transparent),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: (MediaQuery.of(
                                                                  context)
                                                              .orientation ==
                                                          Orientation.portrait)
                                                      ? EdgeInsets.all(8)
                                                      : EdgeInsets.all(10),
                                                  child: ColorFiltered(
                                                      colorFilter: (index == 0)
                                                          ? ColorFilter.mode(
                                                              Color(0xffE87121)
                                                                  .withOpacity(
                                                                      0.7),
                                                              BlendMode.srcIn)
                                                          : ColorFilter.mode(
                                                              Color(0xff727df5)
                                                                  .withOpacity(
                                                                      0.7),
                                                              BlendMode.srcIn),
                                                      child: Image.asset(
                                                          choices[index].icon,
                                                          width: (MediaQuery.of(context).orientation ==
                                                                  Orientation
                                                                      .portrait)
                                                              ? (ResponsiveInfo.isMobile()
                                                                  ? 35
                                                                  : 55)
                                                              : (ResponsiveInfo.isMobile()
                                                                  ? 50
                                                                  : 65),
                                                          height: (MediaQuery.of(context).orientation ==
                                                                  Orientation.portrait)
                                                              ? (ResponsiveInfo.isMobile() ? 35 : 55)
                                                              : (ResponsiveInfo.isMobile() ? 50 : 65),
                                                          fit: BoxFit.fill)),
                                                ),
                                                Text(choices[index].title,
                                                    style: TextStyle(
                                                      fontSize: ResponsiveInfo
                                                              .isMobile()
                                                          ? 12
                                                          : 17,
                                                      fontFamily:
                                                          'SIde_Bar_icon',
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                Text(choices[index].subtext,
                                                    style: TextStyle(
                                                        fontSize: ResponsiveInfo
                                                                .isMobile()
                                                            ? 12
                                                            : 17,
                                                        fontFamily:
                                                            'SIde_Bar_icon',
                                                        color:
                                                            Color(0xff727df5),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                        ),
                                      );
                                    })),
                              ),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                )

                // Column(
                //     children: [
                //       Expanded(child: ,flex: 1)
                //
                //       ,
                //       nkMediumSizeBox(),
                //
                //       Expanded(child: CustomerAndOrdersMiddelWidget(
                //         custAndOrdController: customerAndOrderController,
                //         leadsController: leadsController,
                //       ),flex: 3,)
                //
                //
                //       ,
                //
                //     ],
                //   ),

                ),
          ),
        ),
      );
    });
  }
}

class Choice {
  String title;
  String icon;
  String subtext;
  Choice({required this.title, required this.icon, required this.subtext});
}
