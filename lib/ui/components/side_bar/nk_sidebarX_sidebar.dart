import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/icons/slide_bar_icons.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../database/session/sessionmanager.dart';

class NkSidebarXSideBar extends StatefulWidget {
  const NkSidebarXSideBar({
    Key? key,
    required List<SidebarXItem> itemList,
    required SidebarXController controller,
    required this.userDetails,
  })  : _controller = controller,
        _itemList = itemList,
        super(key: key);

  final SidebarXController _controller;
  final List<SidebarXItem> _itemList;
  final LoginData userDetails;

  @override
  State<NkSidebarXSideBar> createState() => _NkSidebarXSideBarState();
}

class _NkSidebarXSideBarState extends State<NkSidebarXSideBar> {
  bool _onSwitchSelected = false;

  @override
  Widget build(BuildContext context) {
    log('ImagePath Side : ${widget.userDetails.imagePath}');
    return OrientationBuilder(builder: (context, orientation) {
      return SidebarX(
        controller: widget._controller,
        headerDivider: Container(
          color: primaryColor,
        ),
        theme: SidebarXTheme(
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.zero,
          ),
          textStyle: TextStyle(color: primaryTextColor),
          selectedTextStyle: const TextStyle(color: primaryColor),
          selectedItemDecoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            border: const Border(
              left: BorderSide(
                color: primaryColor,
                width: 5.0,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.black.withOpacity(0.4),
            size: 24,
          ),
          selectedIconTheme: const IconThemeData(
            color: primaryColor,
            size: 24,
          ),
        ),
        showToggleButton: false,
        headerBuilder: (context, extended) {
          return Container(
            color: primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkResponse(
                      onTap: () => {
                            HomeController.homeScaffoldKey.currentState
                                ?.closeDrawer(),
                          },
                      child: Icon(
                        EneftyIcons.menu_outline,
                        size: ResponsiveInfo.isMobile() ? 24 : 32,
                        color: white,
                      )),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Container(
                    height: ResponsiveInfo.isMobile() ? 70 : 100,
                    width: ResponsiveInfo.isMobile() ? 70 : 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 164, 236, 247),
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.userDetails.imagePath ?? '',
                        height: ResponsiveInfo.isMobile() ? 50 : 75,
                        width: ResponsiveInfo.isMobile() ? 50 : 75,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            content:
                                widget.userDetails.fullname?.toUpperCase() ??
                                    'No Data',
                            fontSize: ResponsiveInfo.isMobile() ? 15 : 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          CustomText(
                            content: widget.userDetails.email ?? 'No Data',
                            fontSize: ResponsiveInfo.isMobile() ? 8 : 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 35,
                        child: LiteRollingSwitch(
                          width: 80,
                          onSwipe: (value) {
                            setState(() {
                              _onSwitchSelected = value;
                            });
                          },
                          onTap: (value) {
                            setState(() {
                              _onSwitchSelected = value;
                            });
                          },
                          onDoubleTap: () {},
                          value: _onSwitchSelected,
                          textOn: 'In',
                          textOff: 'Out',
                          textOnColor: white,
                          textOffColor: white,
                          colorOn: const Color.fromARGB(255, 100, 224, 164),
                          colorOff: const Color.fromARGB(255, 244, 152, 152),
                          iconOn: Icons.done,
                          iconOff: Icons.close,
                          textSize: 16.0,
                          onChanged: (bool state) {
                            print('Current State of SWITCH IS: $state');
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
        extendedTheme: SidebarXTheme(
          width: AppDimensions.instance.width * 0.7,
          decoration: const BoxDecoration(
            color: backgroundColor,
          ),
        ),
        items: widget._itemList,
      );
    });
  }
}
