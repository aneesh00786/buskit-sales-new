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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return OrientationBuilder(builder: (context, orientation) {
      return SidebarX(
        controller: widget._controller,
        theme: SidebarXTheme(
          decoration: const BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.zero,
          ),
          itemMargin: EdgeInsets.zero,
          selectedItemMargin: EdgeInsets.zero,
          itemTextPadding: const EdgeInsets.only(left: 16.0),
          selectedItemTextPadding: const EdgeInsets.only(left: 16.0),
          textStyle:  TextStyle(color: primaryTextColor),
          selectedTextStyle: const TextStyle(color: primaryColor),
          /* itemTextPadding: const EdgeInsets.only(left: 30),
            selectedItemTextPadding: const EdgeInsets.only(left: 30), */
          selectedItemDecoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            border: const Border(
              left: BorderSide(
                //                  <--- left side
                color: primaryColor,
                width: 3.0,
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
          return  Padding(
              padding: nkMediumPadding(right: 0, left: 0, top: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: extended
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  Center(
                    child: InkResponse(
                        onTap: () => {
                          HomeController.homeScaffoldKey.currentState
                              ?.closeDrawer(),
                        },
                        child:  Icon(
                          Icons.menu_outlined,
                          size:ResponsiveInfo.isMobile()? 24:32,
                        )),
                  ),
                  ClipOval(
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.userDetails.imagePath ?? '',
                        height:ResponsiveInfo.isMobile()? 25:40,
                        width:ResponsiveInfo.isMobile()? 25:40,
                      )),


                   MyRegularText(
                    label: widget.userDetails.fullname ?? 'No Data',
                    fontSize: ResponsiveInfo.isMobile()?13:16,
                  ),


                   SizedBox(
                      height: 25,
                       width: 40,
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Transform.scale(

                            child: CupertinoSwitch(
                                value: _onSwitchSelected,
                                onChanged: (value) {
                                  setState(() {
                                    _onSwitchSelected = value;
                                    /*   widget.onTopToggleSwitch != null
                                      ? (value)
                                      : null;*/
                                  });
                                }),
                            scale: 1.2,


                          )



                      ))

                ],
              ),
            );
        },
        extendedTheme: SidebarXTheme(
          width: AppDimensions.instance.width * 0.7,
          margin: nkRegularPadding(bottom: 0, right: 0, top: 0),
          decoration: const BoxDecoration(
            color: backgroundColor,
          ),
        ),
        footerDivider: const Divider(),
        footerBuilder: (context, extended) {
          return extended
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buttonWithIcon(
                      setting,
                      SIdeBarIcon.ic_setting,
                    ),
                    nkSmallSizeBox(),
                    buttonWithIcon(
                      logOut,
                      SIdeBarIcon.ic_log_out,
                      onPressed: () async {
                        await SessionManager.clearData();
                        Get.offAllNamed(AppRoutes.login);
                      },
                    ),
                    nkMediumSizeBox(
                        height: AppDimensions.instance.height * 0.08),
                  ],
                )
              : const SizedBox();
        },
        items: widget._itemList,
      );
    });
  }

  Widget buttonWithIcon(String name, IconData iconData,
      {void Function()? onPressed}) {
    return Padding(
      padding: nkSymmetricPadding(
          vertical: 0,
          horizontal: MediaQuery.of(context).orientation == Orientation.portrait
              ? AppDimensions.instance.width * 0.05
              : AppDimensions.instance.width * 0.02),
      child: MyThemeButton(
        width: Get.size.width * 0.4,
        buttonText: setting,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: secondaryIconColor,
              size: 26,
            ),
            nkSmallSizeBox(height: 0),
            MyRegularText(
              color: buttonTextColor,
              label: name,
              fontSize: ResponsiveInfo.isMobile()?14:18,
            )
          ],
        ),
      ),
    );
  }
}
