import 'dart:async';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService extends GetxService {
  final RxBool isUpdateAvailable = false.obs;
  String latestVersion = '';
  String updateUrl = '';

  late StreamSubscription _connectivitySubscription;
  bool _isChecking = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
    // Delay initial check to ensure navigator context and connectivity are fully ready
    Future.delayed(const Duration(seconds: 3), () {
      checkForUpdates();
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  void _initConnectivityListener() {
    _connectivitySubscription =
        ConnectivityService().onOnlineStatusChanged.listen((isOnline) {
      if (isOnline) {
        checkForUpdates();
      }
    });
  }

  Future<void> checkForUpdates() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final isConnected = await ConnectivityService().isOnline();
      print('AppUpdateService: Connectivity status online = $isConnected');
      if (!isConnected) {
        _isChecking = false;
        return;
      }

      // Get current local version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion =
          "${packageInfo.version}+${packageInfo.buildNumber}";
      print('AppUpdateService: Local App Version = $currentVersion');

      final targetUrl =
          "${ApiConstants.baseUrl}${ApiConstants.appVersion}?app=sales";
      print('AppUpdateService: Sending request to server: $targetUrl');

      // Fetch version details from backend (appType: 'sales')
      final apiWorker = Get.find<ApiWorker>();
      final versionData = await apiWorker.fetchAppVersion('sales');
      print(
          'AppUpdateService: Received version data from server = $versionData');
      if (versionData == null) {
        _isChecking = false;
        return;
      }

      final serverVersion = versionData['latest_version']?.toString() ?? '';
      final appStoreUrl = versionData['ios_app_store_url']?.toString() ?? '';
      final playStoreUrl =
          versionData['android_play_store_url']?.toString() ?? '';

      if (serverVersion.isEmpty) {
        _isChecking = false;
        return;
      }

      latestVersion = serverVersion;
      updateUrl = GetPlatform.isIOS ? appStoreUrl : playStoreUrl;

      final hasUpdate = _isNewVersionAvailable(currentVersion, serverVersion);
      print(
          'AppUpdateService: Comparison hasUpdate = $hasUpdate (Server: $serverVersion, Local: $currentVersion)');
      isUpdateAvailable.value = hasUpdate;

      if (hasUpdate) {
        // Save flag in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_update_available', true);

        // Check local time (Auto-update redirect prompt ideally after 10 PM)
        final localHour = DateTime.now().hour;
        if (localHour >= 22) {
          // Automatic/Immediate update redirect after 10 PM
          _showUpdatePrompt(force: true);
        } else {
          // Standard check on launch/connect
          _showUpdatePrompt(force: false);
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('is_update_available');
      }
    } catch (e) {
      print('Error in checkForUpdates: $e');
    } finally {
      _isChecking = false;
    }
  }

  bool _isNewVersionAvailable(String currentVersion, String latestVersion) {
    try {
      final currentParts = currentVersion.split('+');
      final latestParts = latestVersion.split('+');

      final currentVerStr = currentParts[0];
      final latestVerStr = latestParts[0];

      final currentNums = currentVerStr.split('.').map(int.parse).toList();
      final latestNums = latestVerStr.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final currentVal = i < currentNums.length ? currentNums[i] : 0;
        final latestVal = i < latestNums.length ? latestNums[i] : 0;
        if (latestVal > currentVal) return true;
        if (currentVal > latestVal) return false;
      }

      if (currentParts.length > 1 && latestParts.length > 1) {
        final currentBuild = int.tryParse(currentParts[1]) ?? 0;
        final latestBuild = int.tryParse(latestParts[1]) ?? 0;
        return latestBuild > currentBuild;
      }
    } catch (e) {
      print('Version comparison error: $e');
    }
    return false;
  }

  Future<void> _showUpdatePrompt({required bool force}) async {
    // Avoid opening multiple dialogs
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => !force,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon badge
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: force
                            ? [const Color(0xFFEF5350), const Color(0xFFD32F2F)]
                            : [
                                const Color(0xFF727CF5),
                                const Color(0xFF5C6BC0)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (force
                                  ? const Color(0xFFEF5350)
                                  : const Color(0xFF727CF5))
                              .withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_update_alt,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    force ? "Mandatory Update" : "Update Available",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Version badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF727CF5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version $latestVersion',
                      style: const TextStyle(
                        color: Color(0xFF727CF5),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    force
                        ? "A new version is required to continue. Please update the application now to enjoy the latest features and improvements."
                        : "A new version of the app is now available. Update now to get the latest features, improvements, and bug fixes.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!force) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey.shade700,
                            ),
                            child: const Text(
                              "Later",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: force
                                  ? [
                                      const Color(0xFFEF5350),
                                      const Color(0xFFD32F2F)
                                    ]
                                  : [
                                      const Color(0xFF727CF5),
                                      const Color(0xFF5C6BC0)
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (force
                                        ? const Color(0xFFEF5350)
                                        : const Color(0xFF727CF5))
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _launchUpdateUrl();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.download_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Update Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: !force,
    );
  }

  Future<void> _launchUpdateUrl() async {
    if (updateUrl.isEmpty) return;
    final uri = Uri.parse(updateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not launch app update page.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
