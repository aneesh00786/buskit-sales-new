import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
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
    bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ApiWorker().loadSwitchState().then((value) {
      if (mounted) {
        setState(() {
          _onSwitchSelected = value;
          _isLoading = false;
        });
      }
    });
    log('Switch state: $_onSwitchSelected');
  }

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
                        child: _isLoading
                            ? const CircularProgressIndicator(color: white)
                            : GestureDetector(
                                onTap: () => _handleSwitchToggle(context),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 100,
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: _onSwitchSelected
                                        ? const Color.fromARGB(
                                            255, 100, 224, 164)
                                        : const Color.fromARGB(
                                            255, 244, 152, 152),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Text(
                                            'Out',
                                            style: TextStyle(
                                              color: _onSwitchSelected
                                                  ? Colors.transparent
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                            'In',
                                            style: TextStyle(
                                              color: !_onSwitchSelected
                                                  ? Colors.transparent
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      AnimatedAlign(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        alignment: _onSwitchSelected
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.white,
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : Icon(
                                                  _onSwitchSelected
                                                      ? Icons.check
                                                      : Icons.close,
                                                  size: 20,
                                                  color: _onSwitchSelected
                                                      ? const Color.fromARGB(
                                                          255, 100, 224, 164)
                                                      : const Color.fromARGB(
                                                          255, 244, 152, 152),
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

  Future<bool> _handleLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      bool? openSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Location permission is permanently denied. Open settings to enable it.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
      return openSettings ?? false;
    }

    return true; // Already granted
  }

  void _handleSwitchToggle(BuildContext context) async {
    bool newState = !_onSwitchSelected;

    // Show confirmation dialog
    bool? confirmAction = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(newState ? 'Confirm Check-In' : 'Confirm Check-Out'),
          content: Text(
              'Are you sure you want to ${newState ? 'check in' : 'check out'}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmAction == true) {
      if (!await _handleLocationPermission(context)) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final response = await ApiWorker().updateAdminCheckInOut(
          date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          time: DateFormat('HH:mm').format(DateTime.now()),
          direction: newState ? "in" : "out",
          lat: position.latitude.toString(),
          long: position.longitude.toString(),
        );

        if (response.statusCode == 200) {
          await ApiWorker().saveSwitchState(newState);

          if (mounted) {
            setState(() {
              _onSwitchSelected = newState;
            });
          }
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
