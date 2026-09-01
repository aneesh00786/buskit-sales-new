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
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import '../../orders/order_controller.dart';

class OfflineOrderBottomWidget extends StatefulWidget {
  final OrderController orderController;
  const OfflineOrderBottomWidget({super.key, required this.orderController});

  @override
  State<OfflineOrderBottomWidget> createState() =>
      _OfflineOrderBottomWidgetState();
}

class _OfflineOrderBottomWidgetState extends State<OfflineOrderBottomWidget> {
  // LinkedScrollControllerGroup forwards the user's drag delta to every
  // linked controller directly, instead of reacting to a finished position
  // change with jumpTo() — mirrors the fix applied to lead_bottom_screen.dart
  // and sales_return.dart, keeping the frozen (Sl.No/Offline Orders) column's
  // list in sync with the scrollable columns' list.
  late final LinkedScrollControllerGroup _verticalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _scrollController1 = _verticalGroup.addAndGet();
  late final ScrollController _scrollController2 = _verticalGroup.addAndGet();

  // Keeps the scrollable columns' header row moving in sync with the
  // scrollable columns' body rows underneath it — the header is drawn once
  // as a single full-width gradient bar overlaid on top of the body (see
  // _buildHeader/_buildBody below), instead of two separate gradient boxes
  // side by side, which produced a visible seam.
  late final LinkedScrollControllerGroup _horizontalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _headerHorizontalController =
      _horizontalGroup.addAndGet();
  late final ScrollController _bodyHorizontalController =
      _horizontalGroup.addAndGet();

  @override
  void initState() {
    super.initState();
    widget.orderController.loadOfflineOrders();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  double _tableWidth(BuildContext context) => isTabletOrPhoneLandscape(context)
      ? MediaQuery.of(context).size.width
      : fullScreenWidth(context) * 2;

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

        return Stack(
          children: [
            _buildBody(context),
            _buildHeader(context),
          ],
        );
      },
    );
  }

  // Single continuous gradient bar spanning the frozen (Sl.No/Offline
  // Orders) column and the horizontally-scrollable columns, overlaid on top
  // of the body via a Stack — avoids the visible seam that two side-by-side
  // gradient containers produced. Mirrors order_bottom_widget.dart /
  // lead_bottom_screen.dart's _buildHeader.
  Widget _buildHeader(BuildContext context) {
    const double headerHeight = 50;

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Container(
        width: double.infinity,
        height: headerHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Color(0xFF2D3748)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: CustomText(
                          content: 'Sl No.'.tr,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins_Regular'),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: CustomText(
                          content: 'Offline Orders'.tr,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins_Regular'),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _headerHorizontalController,
                primary: false,
                child: SizedBox(
                  width: _tableWidth(context),
                  child: _buildHeaderCells(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCells() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 5),
        _headerCell('Order NO'.tr, 4),
        const SizedBox(width: 5),
        _headerCell('Created'.tr, 4),
        const SizedBox(width: 5),
        _headerCell('Created By'.tr, 4),
        const SizedBox(width: 5),
        _headerCell('Order Amount'.tr, 5, textAlign: TextAlign.center),
        const SizedBox(width: 5),
        _headerCell('Payment Status'.tr, 4),
        const SizedBox(width: 5),
        _headerCell('Status'.tr, 4),
        const SizedBox(width: 15),
        const Expanded(flex: 2, child: SizedBox()),
        const Expanded(flex: 2, child: SizedBox()),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _headerCell(String text, int flex, {TextAlign? textAlign}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: CustomText(
          content: text,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins_Regular',
          fontSize: 12,
          textAlign: textAlign,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    const double headerHeight = 50;

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: headerHeight),
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const ClampingScrollPhysics(),
                      controller: _scrollController1,
                      itemCount: widget.orderController.offlineOrders.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final order = Map<String, dynamic>.from(
                            widget.orderController.offlineOrders[index] as Map);

                        return Container(
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFF8FAFC),
                            border: const Border(
                              bottom: BorderSide(
                                  color: Color(0xFFE2E8F0), width: 0.6),
                            ),
                          ),
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
                                    color: const Color(0xFF0F172A),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0), width: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _bodyHorizontalController,
                primary: false,
                child: SizedBox(
                  width: _tableWidth(context),
                  child: Column(
                    children: [
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
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF8FAFC),
                                border: const Border(
                                  bottom: BorderSide(
                                      color: Color(0xFFE2E8F0), width: 0.6),
                                ),
                              ),
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
                                  Expanded(flex: 2, child: deleteOrder(order)),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        color: const Color(0xFF0F172A),
      ),
    );
  }

  // NOTE: offline orders track payment via a raw 'paid'/'not paid' string,
  // a different concept from OrderStatus's type codes, so this keeps its own
  // paid/not-paid check — only the chrome changes, to the same soft rounded
  // -pill treatment (and matching color tokens) used by the online table's
  // paymentStatus() in orders_bottom_widget/widgets/helpers.dart.
  Widget paymentStatus(Map<String, dynamic> order) {
    final paymentType = order['paymentType']?.toString() ?? '';
    final bool isPaid = paymentType.toLowerCase() == 'paid';
    final Color bgColor =
        isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final Color iconColor =
        isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final IconData icon = isPaid ? Icons.check : Icons.close;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget orderStatus(Map<String, dynamic> order) {
    final status = order['order_status'] ?? -1;
    final bool hasStatus = status != null && status != -1;
    final orderStatusEnum =
        OrderHandlingClass.fromType(hasStatus ? status as int : 0);
    final Color statusColor =
        hasStatus ? orderStatusEnum.statusBgColor : Colors.grey;
    final Color statusTextColor =
        hasStatus ? orderStatusEnum.statusTextColor : Colors.black;
    final String statusLabel = hasStatus ? orderStatusEnum.name.tr : 'Unknown';

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
                          content: statusLabel,
                          color: statusTextColor,
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
                                    child: Center(
                                      child: Text(
                                        'Quick Sale'.tr,
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
                    color: statusColor,
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Center(
                    child: CustomText(
                      content: statusLabel,
                      color: statusTextColor,
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
        icon: const Icon(Icons.visibility, size: 16, color: Color(0xFF64748B)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Delete Order'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
              content: Text(
                'Are you sure you want to delete this offline order?'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel'.tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Delete'.tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7F1D1D),
                    ),
                  ),
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
