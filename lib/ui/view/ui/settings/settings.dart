// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/localization_service.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/settings/widget/password_textfield.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  final StaffController? staffController;
  final StaffData? staffData;
  const SettingsScreen({super.key, this.staffController, this.staffData});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguageCode;
  bool _isTranslating = false;

  static const List<List<String>> ALL_LANGUAGES = [
    ['en', 'English (Default)'],
    ['hi', 'Hindi - हिन्दी'],
    ['ar', 'Arabic - العربية'],
    ['zh-CN', 'Chinese Simplified - 简体中文'],
    ['fr', 'French - Français'],
    ['de', 'German - Deutsch'],
    ['es', 'Spanish - Español'],
    ['pt', 'Portuguese - Português'],
    ['ru', 'Russian - Русский'],
    ['ja', 'Japanese - 日本語'],
    ['it', 'Italian - Italiano'],
    ['nl', 'Dutch - Nederlands'],
    ['tr', 'Turkish - Türkçe'],
    ['vi', 'Vietnamese - Tiếng Việt'],
    ['th', 'Thai - ภาษาไทย'],
    ['ur', 'Urdu - اردو'],
    ['bn', 'Bengali - বাংলা'],
    ['ms', 'Malay - Bahasa Melayu'],
    ['id', 'Indonesian - Bahasa Indonesia'],
  ];
  File? photoId;
  File? photoBrowser;
  bool isIdNotSelected = false, isBrowserNotSelected = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StaffController staffController = Get.put(StaffController());
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = false;
  SalesmanData? _adminData;
  bool _isLoading = true;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivityService.connectivityStream.listen(_updateConnectivityStatus);
    _loadAdminDetails();
    final activeLocale = Get.locale ?? const Locale('en'); 
    _selectedLanguageCode = activeLocale.countryCode != null 
        ? '${activeLocale.languageCode}-${activeLocale.countryCode}' 
        : activeLocale.languageCode;
  }

  Future<void> _checkConnectivity() async {
    bool onlineStatus = await _connectivityService.isOnline();
    if (mounted) {
      setState(() {
        _isOnline = onlineStatus;
      });

      if (!_isOnline) {
        errorSnackbar("No internet connection . please check your network");
      }
    }
  }

  Future<void> _loadAdminDetails() async {
    try {
      final response = await ApiService().fetchSalesmanDetails(
        token: SessionHelper.loginSavedData?.token ?? '',
      );
      if (mounted) {
        setState(() {
          _adminData = response.data.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateConnectivityStatus(List<ConnectivityResult> result) async {
    if (result != ConnectivityResult.none) {
      bool hasInternet = await _connectivityService.hasInternet();
      if (mounted) {
        setState(() {
          _isOnline = hasInternet;
        });
        if (!_isOnline) {
          errorSnackbar("No internet connection . please check your network");
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
        errorSnackbar("No internet connection . please check your network");
      }
    }
  }

  final salesman = SessionHelper.loginSavedData;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _adminData == null
            ? const Center(child: Text('Failed to load data'))
            : Scaffold(
                backgroundColor: const Color(0xFFF5F7FA),
                appBar: AppBar(
                  centerTitle: false,
                  toolbarHeight: 70,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  title:  Text(
                    'Settings'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: _buildChangePasswordButton(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: _buildCancelPlanButton(),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                    physics: NkGeneralSize.commonPysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Identity Images Section
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200)),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: idAndImagePicWidget(
                                              file: photoId,
                                              imageUrl:
                                                  '${ApiConstants.imageBaseUrlss}${_adminData?.imagePath ?? ''}',
                                              text: 'Profile Image'.tr,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            child: idAndImagePicWidget(
                                              file: photoId,
                                              imageUrl:
                                                  '${ApiConstants.imageBaseUrlss}${_adminData?.idImagePath ?? ''}',
                                              text: 'ID Card Image'.tr,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Personal Information Section
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200)),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader('Personal Information'.tr,
                                          EneftyIcons.profile_circle_outline),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: formFiled(
                                              label: _adminData?.fullname ?? '',
                                              isReadOnly: true,
                                              borderColor: Colors.grey.shade300,
                                              prefixIcon: Icon(EneftyIcons.user_outline,
                                                  color: Colors.grey.shade600),
                                              labelText: "First Name".tr,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: formFiled(
                                              label: _adminData?.lastname ?? '',
                                              isReadOnly: true,
                                              borderColor: Colors.grey.shade300,
                                              prefixIcon: Icon(EneftyIcons.user_outline,
                                                  color: Colors.grey.shade600),
                                              labelText: "Last Name".tr,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: formFiled(
                                              label: _adminData?.email ?? '',
                                              isReadOnly: true,
                                              borderColor: Colors.grey.shade300,
                                              textInputType: TextInputType.emailAddress,
                                              labelText: "Email Address".tr,
                                              prefixIcon: Icon(EneftyIcons.sms_outline,
                                                  color: Colors.grey.shade600),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: formFiled(
                                              label: _adminData?.mobileno ?? '',
                                              isReadOnly: true,
                                              borderColor: Colors.grey.shade300,
                                              textInputType: TextInputType.phone,
                                              labelText: "Mobile No".tr,
                                              prefixIcon: Icon(EneftyIcons.call_outline,
                                                  color: Colors.grey.shade600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Address Details Section
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200)),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader('Address Details'.tr,
                                          EneftyIcons.location_outline),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: formFiled(
                                              label: (_adminData?.zipcode ?? '').toString(),
                                              isReadOnly: true,
                                              borderColor: Colors.grey.shade300,
                                              labelText: 'Zip / Postal Code'.tr,
                                              prefixIcon: Icon(EneftyIcons.routing_2_outline,
                                                  color: Colors.grey.shade600),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 3,
                                            child: formFiled(
                                              label: _adminData?.town ?? '',
                                              labelText: 'City / Suburb'.tr,
                                              isReadOnly: true,
                                              borderColor: Colors.grey.shade300,
                                              maxLines: 1,
                                              prefixIcon: Icon(EneftyIcons.buildings_outline,
                                                  color: Colors.grey.shade600),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 2,
                                            child: formFiled(
                                              label: _adminData?.state ?? '',
                                              isReadOnly: true,
                                              labelText: "State".tr,
                                              borderColor: Colors.grey.shade300,
                                              prefixIcon: Icon(EneftyIcons.map_outline,
                                                  color: Colors.grey.shade600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      formFiled(
                                        label: _adminData?.address ?? '',
                                        isReadOnly: true,
                                        borderColor: Colors.grey.shade300,
                                        labelText: "Full Address".tr,
                                        prefixIcon: Icon(EneftyIcons.house_2_outline,
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200)),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader('Language Settings'.tr,
                                          EneftyIcons.global_outline), // Ensure EneftyIcons is imported
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _selectedLanguageCode,
                                              decoration: InputDecoration(
                                                labelText: 'Language'.tr,
                                                labelStyle: const TextStyle(color: Colors.black),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(color: Colors.black, width: 1),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: Colors.blue, width: 1),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                              ),
                                              isExpanded: true,
                                              menuMaxHeight: 300.0,
                                              items: ALL_LANGUAGES.map((lang) {
                                                return DropdownMenuItem(
                                                  value: lang[0],
                                                  child: Text(lang[1]),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    _selectedLanguageCode = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          SizedBox(
                                            height: 52, // Matches the height of the dropdown
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                elevation: 0,
                                              ),
                                              onPressed: _isTranslating ? null : () async {
                                                bool isOnline = await ConnectivityService().isOnline();
                                                if (!isOnline && _selectedLanguageCode != 'en') {
                                                  showCustomToastDisplay(context, "You are Offline! Cannot download translation.".tr, Colors.red, Icons.wifi_off);
                                                  return;
                                                }

                                                setState(() {
                                                  _isTranslating = true;
                                                });
                                                
                                                try {
                                                  
                                                  final locService = Get.find<LocalizationService>();
                                                  
                                                  // 1. Fetch missing translations from Google API if needed
                                                  await locService.fetchAndSaveTranslations(_selectedLanguageCode);
                                                  
                                                  // 2. Change the locale locally & save to SharedPreferences
                                                  locService.changeLocale(_selectedLanguageCode);
                                                  
                                                  showCustomToastDisplay(context, 'Language saved successfully'.tr, Colors.green, Icons.check);
                                                } catch (e) {
                                                  showCustomToastDisplay(context, 'Failed to update language'.tr, Colors.red, Icons.close);
                                                } finally {
                                                  if (mounted) {
                                                    setState(() {
                                                      _isTranslating = false;
                                                    });
                                                  }
                                                }
                                              },
                                              child: _isTranslating
                                                  ? const SizedBox(
                                                      width: 20, 
                                                      height: 20, 
                                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                                    )
                                                  : Text(
                                                      'Save'.tr,
                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    )),
              );
  }

  bool get checkDataEmptyOrNot {
    if (photoId == null) {
      setState(() {
        isIdNotSelected = !isIdNotSelected;
      });
      return false;
    } else if (photoBrowser == null) {
      setState(() {
        isBrowserNotSelected = !isBrowserNotSelected;
      });
      return false;
    }
    return true;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget filedIcon(String svgIconPath) {
    return SvgPicture.asset(
      svgIconPath,
      fit: BoxFit.scaleDown,
      height: AppDimensions.instance.height * 0.014,
      width: AppDimensions.instance.width * 0.014,
    );
  }

  Widget formFiled(
      {required String label,
      int minLine = 1,
      Widget? prefixIcon,
      Widget? suffixIcon,
      Color? borderColor,
      int? maxLength,
      TextAlign? textAlign,
      TextInputType? textInputType,
      bool isReadOnly = false,
      bool isVisible = false,
      String? Function(dynamic)? validator,
      bool isRequired = true,
      int? maxLines,
      String? labelText,
      void Function(dynamic)? onChanged}) {
    return IgnorePointer(
      ignoring: isReadOnly,
      child: MyFormField(
        textAlign: textAlign ?? TextAlign.start,
        labelText: labelText ?? '',
        initialValue: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        minLines: minLine,
        maxLines: maxLines,
        isRequire: isRequired,
        isShowDefaultValidator: true,
        obscureText: isVisible,
        contentPadding: const EdgeInsets.all(16.0),
        validator: validator,
        isReadOnly: isReadOnly,
        onChanged: onChanged,
        maxLength: maxLength,
        textInputType: textInputType ?? TextInputType.text,
        alignLabelWithHint: true,
        enableColor: borderColor,
        disabledColor: borderColor,
        focusedColor: borderColor,
        borderRadius: BorderRadius.circular(
            NkGeneralSize.nkCommonBorderRadius(borderRadius: 10)),
        prefixIconUnderLine: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                final password = SessionHelper.loginSavedData?.password ?? '';
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      backgroundColor: Colors.white,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double dialogWidth = constraints.maxWidth > 500 ? 500 : constraints.maxWidth * 0.9;
                          double maxDialogHeight = constraints.maxHeight * 0.95;

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: dialogWidth,
                              maxHeight: maxDialogHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          EneftyIcons.lock_outline,
                                          color: Colors.blue,
                                          size: 36,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                       Text(
                                        'Change Password'.tr,
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Secure your account with a new password.'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      PasswordField(
                                        controller: _oldPasswordController,
                                        label: 'Old Password'.tr,
                                        obscureText: _obscureOld,
                                        toggleVisibility: () => setState(
                                            () => _obscureOld = !_obscureOld),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Old password is required';
                                          }
                                          if (value != password) {
                                            return 'Old password is incorrect';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      PasswordField(
                                        controller: _newPasswordController,
                                        label: 'New Password'.tr,
                                        obscureText: _obscureNew,
                                        toggleVisibility: () => setState(
                                            () => _obscureNew = !_obscureNew),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'New password is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      PasswordField(
                                        controller: _confirmPasswordController,
                                        label: 'Confirm Password'.tr,
                                        obscureText: _obscureConfirm,
                                        toggleVisibility: () => setState(() =>
                                            _obscureConfirm = !_obscureConfirm),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Confirm password is required';
                                          }
                                          if (value !=
                                              _newPasswordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                side: BorderSide(color: Colors.grey.shade300),
                                              ),
                                              onPressed: () {
                                                _newPasswordController.clear();
                                                _oldPasswordController.clear();
                                                _confirmPasswordController.clear();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Cancel'.tr,
                                                style: TextStyle(
                                                  color: Colors.grey.shade800,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                              ),
                                              onPressed: () async {
                                                bool isOnline =
                                                    await ConnectivityService()
                                                        .isOnline();
                                                if (!isOnline) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      "You are Offline!".tr,
                                                      red,
                                                      Icons.close);
                                                  return;
                                                }
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  staffController.changePassword(
                                                      currentPassword:
                                                          _oldPasswordController.text,
                                                      newPassword:
                                                          _newPasswordController.text,
                                                      confirmPassword:
                                                          _confirmPasswordController
                                                              .text);
                                                  _newPasswordController.clear();
                                                  _oldPasswordController.clear();
                                                  _confirmPasswordController.clear();
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child:  Text(
                                                'Submit'.tr,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
        },
        icon: const Icon(EneftyIcons.lock_outline, size: 18),
        label:  Text(
          'Change Password'.tr,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCancelPlanButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  backgroundColor: Colors.white,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              EneftyIcons.trash_outline,
                              color: Colors.red.shade600,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                           Text(
                            'Delete Account'.tr,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Once deleted, your account and all associated data will be permanently removed.\n\nDo you wish to proceed?'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(
                                    'Cancel'.tr,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    showCancelPlanDialog(context);
                                  },
                                  child:  Text(
                                    'Delete'.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                );
              },
            );
        },
        icon: const Icon(EneftyIcons.trash_outline, size: 18),
        label:  Text(
          'Delete Account'.tr,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget idAndImagePicWidget(
      {String? lable, String? imageUrl, File? file, String? text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(EneftyIcons.image_outline, color: Colors.grey.shade400, size: 40),
                  const SizedBox(height: 8),
                  Text('No Image Available'.tr, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
