import 'dart:developer';
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatefulWidget {
  final StaffController? staffController;
  final StaffData? staffData;
  const SettingsScreen({super.key, this.staffController, this.staffData});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? photoId;
  File? photoBrowser;
  bool isIdNotSelected = false, isBrowserNotSelected = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
  }

  Future<void> _checkConnectivity() async {
    bool onlineStatus = await _connectivityService.isOnline();
    if (mounted) {
      setState(() {
        _isOnline = onlineStatus;
      });

      if (!_isOnline) {
        showNoInternetSnackBar(context);
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
      debugPrint('Error fetching admin data: $e');
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
          showNoInternetSnackBar(context);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
        showNoInternetSnackBar(context);
      }
    }
  }

  final salesman = SessionHelper.loginSavedData;
  @override
  Widget build(BuildContext context) {
    log('Image URL : ${ApiConstants.imageBaseUrlss}${salesman?.imagePath ?? ''}');
    log('Image URL ID: ${ApiConstants.imageBaseUrlss}${salesman?.idimagePath ?? ''}');
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _adminData == null
            ? const Center(child: Text('Failed to load data'))
            : Scaffold(
                appBar: AppBar(
                  title: CustomText(
                    content: "Settings",
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: _buildChangePasswordButton(),
                    )
                  ],
                ),
                body: SingleChildScrollView(
                    physics: NkGeneralSize.commonPysics(),
                    padding: nkRegularPadding(),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: idAndImagePicWidget(
                                  file: photoId,
                                  imageUrl:
                                      '${ApiConstants.imageBaseUrlss}${_adminData?.imagePath ?? ''}',
                                  text: 'Profile Image',
                                ),
                              ),
                              nkSmallSizeBox(),
                              nkSmallSizeBox(),
                              nkSmallSizeBox(),
                              nkSmallSizeBox(),
                              SizedBox(
                                width: 200,
                                child: idAndImagePicWidget(
                                  file: photoId,
                                  imageUrl:
                                      '${ApiConstants.imageBaseUrlss}${_adminData?.idImagePath ?? ''}',
                                  text: 'Image of ID Card',
                                ),
                              ),
                            ],
                          ),
                          nkMediumSizeBox(),
                          Row(
                            children: [
                              Flexible(
                                child: formFiled(
                                  label: _adminData?.fullname ?? '',
                                  isReadOnly: false,
                                  borderColor: Colors.grey,
                                  prefixIcon: Icon(EneftyIcons.user_outline),
                                  labelText: "First Name",
                                ),
                              ),
                              nkMediumSizeBox(),
                              Flexible(
                                child: formFiled(
                                  label: _adminData?.lastname ?? '',
                                  isReadOnly: false,
                                  borderColor: Colors.grey,
                                  prefixIcon: Icon(EneftyIcons.user_outline),
                                  labelText: "Last Name",
                                ),
                              ),
                            ],
                          ),
                          nkMediumSizeBox(),
                          Row(
                            children: [
                              Flexible(
                                child: formFiled(
                                  label: _adminData?.email ?? '',
                                  isReadOnly: true,
                                  borderColor: Colors.grey,
                                  textInputType: TextInputType.emailAddress,
                                  labelText: "Email",
                                  prefixIcon:
                                      filedIcon(Assets.iconsIcAddLeadsEmail),
                                ),
                              ),
                              nkSmallSizeBox(),
                              Flexible(
                                child: formFiled(
                                  label: _adminData?.mobileno ?? '',
                                  isReadOnly: true,
                                  borderColor: Colors.grey,
                                  textInputType: TextInputType.phone,
                                  labelText: "Mobile No:",
                                  prefixIcon:
                                      filedIcon(Assets.iconsIcAddLeadsMobile),
                                ),
                              ),
                            ],
                          ),
                          nkMediumSizeBox(),
                          Row(
                            children: [
                              Flexible(
                                child: formFiled(
                                  label: (_adminData?.zipcode ?? '').toString(),
                                  isReadOnly: true,
                                  borderColor: Colors.grey,
                                  labelText: 'Zip Code',
                                  prefixIcon:
                                      filedIcon(Assets.iconsIcAddLeadsRemark),
                                ),
                              ),
                              nkSmallSizeBox(),
                              Flexible(
                                child: formFiled(
                                  label: _adminData?.town ?? '',
                                  labelText: 'Town',
                                  isReadOnly: true,
                                  borderColor: Colors.grey,
                                  textInputType: TextInputType.visiblePassword,
                                  maxLines: 1,
                                  prefixIcon:
                                      filedIcon(Assets.iconsIcAddLeadsAddress),
                                ),
                              ),
                              nkSmallSizeBox(),
                              Flexible(
                                child: formFiled(
                                  label: _adminData?.state ?? '',
                                  isReadOnly: true,
                                  labelText: "State",
                                  borderColor: Colors.grey,
                                  textInputType: TextInputType.streetAddress,
                                  prefixIcon:
                                      filedIcon(Assets.iconsIcAddLeadsState),
                                ),
                              ),
                            ],
                          ),
                          nkMediumSizeBox(),
                          formFiled(
                            label: _adminData?.address ?? '',
                            isReadOnly: true,
                            borderColor: Colors.grey,
                            labelText: "Address",
                            textInputType: TextInputType.streetAddress,
                            prefixIcon:
                                filedIcon(Assets.iconsIcAddLeadsAddress),
                          ),
                        ],
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
    return MyFormField(
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
    );
  }

  Widget _buildChangePasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                final password = SessionHelper.loginSavedData?.password ?? '';
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double dialogWidth = constraints.maxWidth * 0.9;
                          double maxDialogHeight = constraints.maxHeight * 0.95;

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: dialogWidth,
                              maxHeight: maxDialogHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Change Password',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      PasswordField(
                                        controller: _oldPasswordController,
                                        label: 'Old Password',
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
                                        label: 'New Password',
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
                                        label: 'Confirm Password',
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
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          foregroundColor: WidgetStatePropertyAll(white),
                                          backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            ApiWorker().changePassword(
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
                                        child: Text('Submit'),
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }

  Widget idAndImagePicWidget(
      {String? lable, String? imageUrl, File? file, String? text}) {
    return Column(
      children: [
        MyCommnonContainer(
          border: Border.all(color: Colors.grey),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    EneftyIcons.profile_circle_bold,
                    color: Colors.grey,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
        ),
        CustomText(
          content: text,
        )
      ],
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final FormFieldValidator<String>? validator;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.toggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey)
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator,
    );
  }
}
