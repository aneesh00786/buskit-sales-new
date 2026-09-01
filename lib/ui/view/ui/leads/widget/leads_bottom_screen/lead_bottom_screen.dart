import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_pagination/leads_bottom_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_bottom_screen/widgets/build_table_row.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_bottom_screen/widgets/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class LeadBottomScreen extends StatefulWidget {
  final LeadsController leadsController;
  const LeadBottomScreen({super.key, required this.leadsController});
  @override
  State<LeadBottomScreen> createState() => _LeadBottomScreenState();
}

class _LeadBottomScreenState extends State<LeadBottomScreen> {
  // LinkedScrollControllerGroup forwards the user's drag delta to every
  // linked controller directly, instead of reacting to a finished position
  // change with jumpTo() — the jumpTo-based approach could fight an in
  // -progress drag/fling on the other controller and made the table feel
  // like it randomly stopped responding to scroll input.
  late final LinkedScrollControllerGroup _verticalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController vertical = _verticalGroup.addAndGet();
  late final ScrollController vertical1 = _verticalGroup.addAndGet();

  // Keeps the scrollable header row (Address/Town/State/...) moving in sync
  // with the scrollable body rows underneath it, the same way Pending
  // Payments does — the header is drawn once as a single full-width
  // gradient bar overlaid on top of the body, instead of two separate
  // gradient boxes side by side (which produced a visible seam).
  late final LinkedScrollControllerGroup _horizontalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController headerHorizontal = _horizontalGroup.addAndGet();
  late final ScrollController bodyHorizontal = _horizontalGroup.addAndGet();

  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void dispose() {
    vertical.dispose();
    vertical1.dispose();
    headerHorizontal.dispose();
    bodyHorizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double fixedRowHeight = isLandscape
        ? isTablet(context)
            ? MediaQuery.of(context).size.height / 10.09
            : MediaQuery.of(context).size.height / 5.09
        : MediaQuery.of(context).size.height / 10 -
            MediaQuery.of(context).size.height * 0.024;

    return MyCommnonContainer(
      padding: EdgeInsets.zero,
      child: Obx(() {
        return Stack(
          children: [
            _buildHeader(context),
            _buildBody(context, fixedRowHeight),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    bool isArabic = Get.locale?.languageCode == 'ar';
    double slNoWidth = isArabic ? 70 : 50;
    double leadsWidth = isArabic ? 230 : 250;
    double totalTableWidth = 130 + 360 + 150 + 150 + 150 + 150 + 150 + 110;
    const double headerHeight = 44;

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
          children: [
            SizedBox(
              width: 300,
              child: Row(
                children: [
                  SizedBox(
                    width: slNoWidth,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          "Sl.No.".tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: leadsWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Leads".tr,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: headerHorizontal,
                primary: false,
                child: SizedBox(
                  width: totalTableWidth,
                  child: buildTableHeader(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double fixedRowHeight) {
    double totalTableWidth = 130 + 360 + 150 + 150 + 150 + 150 + 150 + 110;
    const double headerHeight = 44;

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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: vertical,
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: widget.leadsController.leadsCustomerDataList
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          LeadCustomerData leadCustomerData = entry.value;
                          bool isArabic =
                              Get.locale?.languageCode == 'ar';
                          double slNoWidth = isArabic ? 70 : 50;

                          return Container(
                            height: fixedRowHeight,
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white,
                              border: const Border(
                                bottom: BorderSide(
                                    color: Color(0xFFE2E8F0), width: 0.6),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: slNoWidth,
                                    child: CustomText(
                                      content:
                                          '   ${((widget.leadsController.currentPage.value - 1) * 10) + (index + 1)}.',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE2E8F0),
                                              border: Border.all(
                                                  color: primaryColor
                                                      .withOpacity(0.2)),
                                            ),
                                            child: Image.network(
                                              '${ApiConstants.baseUrl}uploads/${leadCustomerData.imageUrl ?? ''}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                  stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  color: Color(0xFF94A3B8),
                                                  size: 20,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: CustomText(
                                            content: leadCustomerData
                                                    .businessName ??
                                                '',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0F172A),
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                  if (widget.leadsController.totalPages > 1)
                    Container(
                      padding: const EdgeInsets.all(3),
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                            top: BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.6)),
                      ),
                      child: Row(
                        children: [
                          LeadsBottomPaginationWidget(),
                          const Spacer()
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  trackVisibility: const WidgetStatePropertyAll(true),
                  thumbVisibility: const WidgetStatePropertyAll(true),
                  thumbColor: WidgetStateProperty.all(primaryColor),
                  trackColor: WidgetStateProperty.all(Colors.grey[300]),
                  trackBorderColor: WidgetStateProperty.all(Colors.grey[400]),
                  thickness: WidgetStateProperty.all(5),
                  radius: const Radius.circular(10),
                ),
                child: Scrollbar(
                  controller: bodyHorizontal,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: bodyHorizontal,
                    primary: false,
                    child: SizedBox(
                      width: totalTableWidth,
                      child: widget.leadsController.leadsCustomerDataList
                              .isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: const Center(child: NodataWidget()),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    physics: const ClampingScrollPhysics(),
                                    controller: vertical1,
                                    child: Column(
                                      children: widget.leadsController
                                          .leadsCustomerDataList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        LeadCustomerData leadCustomerData =
                                            entry.value;
                                        return buildTableRow(
                                            leadCustomerData,
                                            context,
                                            index,
                                            fixedRowHeight,
                                            widget.leadsController,
                                            subscriptionController);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                if (widget.leadsController.totalPages > 1)
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF8FAFC),
                                      border: Border(
                                          top: BorderSide(
                                              color: Color(0xFFE2E8F0),
                                              width: 0.6)),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
