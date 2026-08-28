import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
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
            CustomText(
              content: 'Leads'.tr,
              fontWeight: FontWeight.bold,
            ),
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
                          const SizedBox(width: 8),
                          const NotificationWidget(
                            startDate: '',
                            endDate: '',
                          ),
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
              size: 20.0,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final admin = snapshot.data!.data.first;
          print(
              'image URL: ${ApiConstants.imageBaseUrl}${homeController.userDetails?.imagePath}');
          return SizedBox(
            width: 130,
            child: SizedBox(
              height: 44,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(width: 5),
                    CircleAvatar(
                      backgroundColor: const Color(0xffe6ecff),
                      radius: 15,
                      child: admin.imagePath != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl:
                                    '${ApiConstants.imageBaseUrl}${homeController.userDetails?.imagePath}',
                                placeholder: (context, url) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, size: 16),
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.person, size: 16),
                    ),
                    const SizedBox(
                      width: 4.5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyRegularText(
                              label:
                                  "${homeController.userDetails?.fullname ?? ''} ${homeController.userDetails?.lastname ?? ''}",
                              fontSize: 10.5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: MyRegularText(
                              label: homeController.userDetails?.designation ?? "",
                              fontSize: 8.5,
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return const NodataWidget();
        }
      },
    );
  });
}
