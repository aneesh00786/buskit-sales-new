// ignore_for_file: use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/offline_order_details_dialog.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../orders/order_controller.dart';

class OfflineOrderBottomWidget extends StatefulWidget {
  final OrderController orderController;
  const OfflineOrderBottomWidget({super.key, required this.orderController});

  @override
  State<OfflineOrderBottomWidget> createState() =>
      _OfflineOrderBottomWidgetState();
}

class _OfflineOrderBottomWidgetState extends State<OfflineOrderBottomWidget> {
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController1 = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.orderController.loadOfflineOrders();

    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
    });
    _scrollController2.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (widget.orderController.isOfflineOrderLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (widget.orderController.offlineOrders.isEmpty) {
          return const Center(child: Text('No Offline Orders'));
        }

        return Row(
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 50,
                    color: primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 5),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: CustomText(
                                  content: 'SI No.',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            flex: 8,
                            child: Center(
                              child: CustomText(
                                  content: 'Offline Orders',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ),
                  ...[
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const ClampingScrollPhysics(),
                        controller: _scrollController1,
                        itemCount: widget.orderController.offlineOrders.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final order = Map<String, dynamic>.from(widget
                              .orderController.offlineOrders[index] as Map);

                          return Container(
                            color:
                                index.isEven ? Colors.white : Colors.grey[50],
                            height: (MediaQuery.of(context).orientation ==
                                    Orientation.portrait)
                                ? (fullScreenHeight(context) - 250) / 10
                                : 70,
                            child: Row(
                              children: [
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: CustomText(
                                      content:
                                          '${((widget.orderController.currentPage.value - 1) * 10) + (index + 1)}.',
                                      maxLine: 1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 8,
                                  child: customerDetailsWidget(order),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 300,
                      padding: const EdgeInsets.all(3),
                      height: 50,
                      color: Colors.grey[200],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: isTabletOrPhoneLandscape(context)
                      ? MediaQuery.of(context).size.width
                      : fullScreenWidth(context) * 2,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: CustomText(
                                      content: 'Order NO',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: CustomText(
                                      content: 'Created',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: CustomText(
                                      content: 'Created By',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: CustomText(
                                      content: 'Order Amount',
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 12,
                                      textAlign: TextAlign.center,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: CustomText(
                                      content: 'Payment Status',
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: CustomText(
                                      content: 'Status',
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    ' ',
                                    style: TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              // const SizedBox(width: 5),
                              const Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    ' ',
                                    style: TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                        ),
                      ),
                      ...[
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: const ClampingScrollPhysics(),
                            controller: _scrollController2,
                            itemCount:
                                widget.orderController.offlineOrders.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final order = Map<String, dynamic>.from(widget
                                  .orderController.offlineOrders[index] as Map);
                              return Container(
                                color: index.isEven
                                    ? Colors.white
                                    : Colors.grey[50],
                                height: (MediaQuery.of(context).orientation ==
                                        Orientation.portrait)
                                    ? (fullScreenHeight(context) - 250) / 10
                                    : 70,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 4,
                                      child: orderNumberWidget(order),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 4,
                                      child: orderCreatedDateWidget(order),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 4,
                                      child: orderCreatedByWidget(order),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 5,
                                      child: orderPrice(order),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 4,
                                      child: paymentStatus(order),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 4,
                                      child: orderStatus(order),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                        flex: 2, child: deleteOrder(order)),
                                    Expanded(flex: 2, child: viewOrder(order)),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          height: 50,
                          color: Colors.grey[200],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget placeholderWidget() {
    return const Center(
      child: MyRegularText(
        label: 'N/A',
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    );
  }

  Widget customerDetailsWidget(Map<String, dynamic> order) {
    final businessName = order['businessName'] ?? 'Unknown';
    final mobileNo = order['mobileNo'] ?? 'Unknown';
    final email = order['email'] ?? 'Unknown';
    final imageUrl = order['imageUrl'];
    return GestureDetector(
      onTap: () => {},
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(width: 8),
        ClipOval(
          child: Container(
            height: 34,
            width: 34,
            color: Colors.grey[200],
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    '${ApiConstants.imageBaseUrl}$imageUrl',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  content: businessName,
                  maxLine: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  content: mobileNo,
                  maxLine: 2,
                  fontSize: 10,
                ),
                MyRegularText(
                  align: TextAlign.start,
                  label: email,
                  maxlines: 1,
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
        )
      ]),
    );
  }

  Widget orderNumberWidget(Map<String, dynamic> order) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyRegularText(
            label: "",
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget orderCreatedDateWidget(Map<String, dynamic> order) {
    final createdAt = DateTime.parse(order['createdAt'].toString()).toString();
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyRegularText(
          label: createdAt.isEmpty
              ? "N/A"
              : NKDateUtils.commonDayFormat2(
                  NKDateUtils.formatStringUTCDateTime(createdAt)),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        MyRegularText(
          label: createdAt.isEmpty
              ? "N/A"
              : NKDateUtils.commonTimeOnlyFormat(
                  NKDateUtils.formatStringUTCDateTime(createdAt)),
          fontSize: 12,
        ),
      ],
    ));
  }

  Widget orderCreatedByWidget(Map<String, dynamic> order) {
    final firstName = order['first_name'] ??
        "${SessionHelper.loginSavedData?.fullname?.nkStringCapitalizeFirstCaracter} ${SessionHelper.loginSavedData?.lastname?.nkStringCapitalizeFirstCaracter}";
    final lastName = order['last_name'] ?? '';
    return Center(
      child: MyRegularText(
        label: '$firstName $lastName',
        fontWeight: FontWeight.w600,
        fontSize: 11,
        maxlines: 2,
      ),
    );
  }

  Widget orderPrice(Map<String, dynamic> order) {
    final orderTotal = order['order_price']?.toString() ?? 'N/A';
    return Center(
      child: MyRegularText(
        label: formatAmount(orderTotal),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        maxlines: 1,
      ),
    );
  }

  Widget paymentStatus(Map<String, dynamic> order) {
    final paymentType = order['paymentType']?.toString() ?? '';
    Color statusColor =
        paymentType.toLowerCase() == 'paid' ? Colors.green : Colors.red;
    IconData icon =
        paymentType.toLowerCase() == 'paid' ? Icons.check : Icons.close;
    return Center(
      child: CircleAvatar(
        backgroundColor: statusColor,
        radius: 12,
        child: Icon(
          icon,
          size: 20,
          color: white,
        ),
      ),
    );
  }

  Widget orderStatus(Map<String, dynamic> order) {
    final status = order['order_status'] ?? -1;
    Color statusColor;

    switch (status) {
      case -1:
        statusColor = const Color.fromARGB(255, 255, 183, 134);
        break;
      case 0:
        statusColor = const Color.fromARGB(255, 255, 183, 134);
        break;
      case 11:
        statusColor = const Color.fromARGB(255, 225, 250, 191);
        break;
      case 12:
        statusColor = const Color.fromARGB(255, 255, 222, 168);
        break;
      case 14:
        statusColor = const Color.fromARGB(255, 190, 253, 247);
        break;
      case 5:
        statusColor = const Color.fromARGB(255, 190, 253, 247);
        break;
      case 7:
        statusColor = const Color.fromARGB(255, 222, 199, 246);
        break;
      case 1:
        statusColor = const Color.fromARGB(255, 245, 195, 254);
        break;
      case 2:
        statusColor = const Color.fromARGB(255, 222, 199, 246);
        break;
      case 13:
        statusColor = const Color.fromARGB(255, 246, 199, 199);
        break;
      default:
        statusColor = Colors.grey;
    }

    // return Center(
    //   child: Padding(
    //     padding: const EdgeInsets.all(0),
    //     child: IntrinsicHeight(
    //       child: Container(
    //         clipBehavior: Clip.antiAlias,
    //         padding: const EdgeInsets.symmetric(vertical: 5),
    //         decoration: BoxDecoration(
    //           color: statusColor,
    //           borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    //         ),
    //         child: Center(
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               CustomText(
    //                 content: status,
    //                 fontSize: 11.0,
    //                 fontWeight: FontWeight.w600,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return status == 14
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: IntrinsicHeight(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          content: status != null
                              ? OrderHandlingClass.fromType(status).name
                              : 'Unknown',
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                        if (status == 14) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                    color: Colors.blue,
                                    child: const Center(
                                      child: Text(
                                        'Quick Sale',
                                        style: TextStyle(
                                            color: white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                      ),
                                    )),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: status != null ? statusColor : Colors.grey,
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Center(
                    child: CustomText(
                      content: status != null
                          ? OrderHandlingClass.fromType(status).name
                          : 'Unknown',
                      fontSize: 11,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget viewOrder(Map<String, dynamic> order) {
    return Center(
      child: IconButton(
        onPressed: () async {
          Get.dialog(
            OfflineOrderDetailsDialog(
              orderData: order,
            ),
            barrierDismissible: true,
          );
        },
        icon: const Icon(Icons.visibility, size: 16),
      ),
    );
  }

  Widget deleteOrder(Map<String, dynamic> order) {
    return Center(
      child: IconButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title:  Text('Delete Order'.tr),
              content:  Text(
                  'Are you sure you want to delete this offline order?'.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child:  Text('Cancel'.tr),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:  Text('Delete'.tr),
                ),
              ],
            ),
          );
          if (confirm == true) {
            final orderId = order['order_id']?.toString();
            if (orderId != null && orderId.isNotEmpty) {
              await widget.orderController.deleteOfflineOrder(orderId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline order deleted.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order ID not found.')),
              );
            }
          }
        },
        icon: const Icon(
          EneftyIcons.trash_bold,
          size: 16,
          color: red,
        ),
      ),
    );
  }
}
