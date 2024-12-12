import 'dart:developer';
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/components/file_picking/nk_file_picker_option_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
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
  File? photoId;
  File? photoBrowser;
  bool isIdNotSelected = false, isBrowserNotSelected = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final salesman = SessionHelper.loginSavedData;
  @override
  Widget build(BuildContext context) {
    log('Image URL : ${ApiConstants.imageBaseUrlss}${salesman?.imagePath ?? ''}');
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        actions: [_buildChangePasswordButton()],
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
                  Container(
                    width: 200,
                    child: idAndImagePicWidget(
                        file: photoId,
                        imageUrl:
                            '${ApiConstants.imageBaseUrlss}${salesman?.imagePath ?? ''}',
                        text: 'Profile Image'),
                  ),
                  nkSmallSizeBox(),
                  nkSmallSizeBox(),
                  nkSmallSizeBox(),
                  nkSmallSizeBox(),
                  Container(
                    width: 200,
                    child: idAndImagePicWidget(
                        file: photoId,
                        imageUrl: salesman?.idimagePath ?? '',
                        text: 'Image of ID Card'),
                  ),
                ],
              ),
              nkMediumSizeBox(),
              formFiled(
                label: salesman?.fullname ?? '',
                isReadOnly: true,
                borderColor: Colors.grey,
                prefixIcon: filedIcon(Assets.iconsIcAddLeadsSalesmanName),
              ),
              nkMediumSizeBox(),
              Row(
                children: [
                  Flexible(
                    child: formFiled(
                      label: salesman?.email ?? '',
                      isReadOnly: true,
                      borderColor: Colors.grey,
                      textInputType: TextInputType.emailAddress,
                      prefixIcon: filedIcon(Assets.iconsIcAddLeadsEmail),
                    ),
                  ),
                  nkSmallSizeBox(),
                  Flexible(
                    child: formFiled(
                      label: salesman?.mobileno ?? '',
                      isReadOnly: true,
                      borderColor: Colors.grey,
                      textInputType: TextInputType.phone,
                      prefixIcon: filedIcon(Assets.iconsIcAddLeadsMobile),
                    ),
                  ),
                ],
              ),
              nkMediumSizeBox(),
              Row(
                children: [
                  Flexible(
                    child: formFiled(
                      label: (salesman?.zipcode ?? '').toString(),
                      isReadOnly: true,
                      borderColor: Colors.grey,
                      prefixIcon: filedIcon(Assets.iconsIcAddLeadsRemark),
                    ),
                  ),
                  nkSmallSizeBox(),
                  Flexible(
                    child: formFiled(
                      label: salesman?.password ?? '',
                      isReadOnly: true,
                      borderColor: Colors.grey,
                      textInputType: TextInputType.visiblePassword,
                      maxLines: 1,
                      prefixIcon: filedIcon(Assets.iconsIcAddLeadsAddress),
                    ),
                  ),
                ],
              ),
              nkMediumSizeBox(),
              formFiled(
                label: salesman?.address ?? '',
                isReadOnly: true,
                borderColor: Colors.grey,
                textInputType: TextInputType.streetAddress,
                prefixIcon: filedIcon(Assets.iconsIcAddLeadsAddress),
              ),
              nkMediumSizeBox(),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: formFiled(
                        label: salesman?.address ?? '',
                        isReadOnly: true,
                        borderColor: Colors.grey,
                        textInputType: TextInputType.streetAddress,
                        prefixIcon: filedIcon(Assets.iconsIcAddLeadsCity),
                      ),
                    ),
                    nkSmallSizeBox(),
                    Flexible(
                      child: formFiled(
                        label: salesman?.state ?? '',
                        isReadOnly: true,
                        borderColor: Colors.grey,
                        textInputType: TextInputType.streetAddress,
                        prefixIcon: filedIcon(Assets.iconsIcAddLeadsState),
                      ),
                    ),
                  ],
                ),
              ),
              nkMediumSizeBox(),
              nkMediumSizeBox(),
              nkSmallSizeBox(),
            ],
          ),
        ),
      ),
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
      height: AppDimensions.instance!.height * 0.014,
      width: AppDimensions.instance!.width * 0.014,
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
      void Function(dynamic)? onChanged}) {
    return MyFormField(
      textAlign: textAlign ?? TextAlign.start,
      labelText: '',
      initialValue: label,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }

  Widget idAndImagePicWidget(
      {String? lable, String? imageUrl, File? file, String? text}) {
    Column imageTextCollumn = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Assets.iconsIcImagePic),
          nkSmallSizeBox(),
          RichText(
              text: TextSpan(
                  style: TextStyle(
                      fontWeight: NkGeneralSize.nkBoldFontWeight(),
                      color: primaryTextColor),
                  children: [
                TextSpan(
                  text: "$lable ",
                ),
              ])),
        ]);
    return Column(
      children: [
        MyCommnonContainer(
          border: Border.all(color: Colors.grey),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
                child: text == 'Image of ID Card'
                    ? Image.asset("assets/images/id_card.jpg")
                    : Image.network(imageUrl ?? '')
                // imageUrl != null
                //         ? MyNetworkImage(
                //             imageUrl: imageUrl,
                //             height: AppDimensions.instance.height * 0.2,
                //           )

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
