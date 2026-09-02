import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/chatbot/chatbot_top_bar_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LeadTopScreen extends StatefulWidget {
  final LeadsController leadsController;
  const LeadTopScreen({super.key, required this.leadsController});

  @override
  State<LeadTopScreen> createState() => _LeadTopScreenState();
}

class _LeadTopScreenState extends State<LeadTopScreen> {
  bool showChatbotMobile = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Leads'.tr, style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              )),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AddLeadsScreen(
                            leadsController: widget.leadsController,
                          ),
                          const SizedBox(width: 8),
                          if (!isMobile) const ChatbotTopBarButton(routeName: '/leads'),
                          if (isMobile)
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: primaryColor),
                              onPressed: () {
                                setState(() {
                                  showChatbotMobile = !showChatbotMobile;
                                });
                              },
                            ),
                          const SizedBox(width: 10),
                          const NotificationWidget(
                            startDate: '',
                            endDate: '',
                          ),
                          const SizedBox(width: 10),
                          profiloe(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        if (isMobile && showChatbotMobile)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: const ChatbotTopBarButton(routeName: "/leads"),
            ),
          ),
      ],
    );
  }
}

Widget profiloe() {
  return Consumer<DashboardProvider>(builder: (context, provider, child) {
    HomeController homeController = Get.put(HomeController());

    return FutureBuilder<SalesmanResponse>(
      future: provider.adminResponse,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitFadingCube(
              color: primaryColor,
              size: 18.0,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final String firstName = homeController.userDetails?.fullname ?? '';
          final String lastName = homeController.userDetails?.lastname ?? '';
          final String fullName = '$firstName $lastName'.trim();
          final String designation =
              homeController.userDetails?.designation ?? 'Sales Executive';

          return SizedBox(
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: homeController.userDetails?.imagePath != null &&
                            homeController.userDetails!.imagePath!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl:
                                '${ApiConstants.imageBaseUrl}${homeController.userDetails?.imagePath}',
                            placeholder: (context, url) => const SizedBox(
                              width: 14,
                              height: 14,
                              child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fullName.isNotEmpty ? fullName : 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        designation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const NodataWidget();
        }
      },
    );
  });
}
