import 'dart:developer';
import 'dart:io';

// import 'package:address_search_field/address_search_field.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/file_picking/nk_file_picker_option_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AddLeadsDiloag extends StatefulWidget {
  final bool isUpdate;
  final LeadsController leadsController;
  final LeadCustomerData? leadCustomerData;
  const AddLeadsDiloag(
      {super.key,
      required this.leadsController,
      this.leadCustomerData,
      this.isUpdate = false});

  @override
  State<AddLeadsDiloag> createState() => _AddLeadsDiloagState();
}

class _AddLeadsDiloagState extends State<AddLeadsDiloag> {
  File? photoBrowser;
  bool isBrowserNotSelected = false, isEditableFiled = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    loadAllFillData(widget.leadCustomerData);
    super.initState();
  }

  @override
  void dispose() {
    widget.leadsController.clearAllFileds;

    super.dispose();
  }

  loadAllFillData(LeadCustomerData? leadCustomerData) {
    if (leadCustomerData != null) {
      if (widget.isUpdate) {
        isEditableFiled = true;
      } else {
        isEditableFiled = false;
      }
      widget.leadsController.customerNameTextController.text =
          leadCustomerData.fullname!;
      widget.leadsController.emailTextController.text = leadCustomerData.email!;
      widget.leadsController.mobileNumberTextController.text =
          leadCustomerData.mobileno!;
      widget.leadsController.zipCodeTextController.text =
          leadCustomerData.zipcode!.toString();
      widget.leadsController.remarkTextController.text =
          leadCustomerData.remark!;
      widget.leadsController.addressTextController.text =
          leadCustomerData.address!;
      widget.leadsController.cityTextController.text = leadCustomerData.town!;
      widget.leadsController.stateTextController.text = leadCustomerData.state!;
      widget.leadsController.businessNameTextEditingController.text =
          leadCustomerData.businessName!;
      widget.leadsController.businessContactTextEditingController.text =
          leadCustomerData.businessNo!;
    }
  }

  updateCustomerData(LeadCustomerData? leadCustomerData) {
    leadCustomerData!.customerId = widget.leadCustomerData!.customerId;
    leadCustomerData.status = widget.leadCustomerData!.status;
    leadCustomerData.imageUrl =
        photoBrowser?.path ?? widget.leadCustomerData!.imageUrl;
    leadCustomerData.fullname =
        widget.leadsController.customerNameTextController.text.trim();
    leadCustomerData.mobileno =
        widget.leadsController.mobileNumberTextController.text.trim();
    leadCustomerData.email =
        widget.leadsController.emailTextController.text.trim();
    leadCustomerData.town =
        widget.leadsController.cityTextController.text.trim();
    leadCustomerData.address =
        widget.leadsController.addressTextController.text.trim();
    leadCustomerData.state =
        widget.leadsController.stateTextController.text.trim();
    leadCustomerData.zipcode =
        int.parse(widget.leadsController.zipCodeTextController.text.trim());
    leadCustomerData.businessName =
        widget.leadsController.businessNameTextEditingController.text.trim();
    leadCustomerData.businessNo =
        widget.leadsController.businessContactTextEditingController.text.trim();
    leadCustomerData.remark =
        widget.leadsController.remarkTextController.text.trim();

    widget.leadsController.updateLeads(leadCustomerData);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        minimum: ore == Orientation.landscape
            ? nkLargePadding(
                right: AppDimensions.instance!.width * 0.12,
                left: AppDimensions.instance!.width * 0.12,
                top: AppDimensions.instance!.height * 0.04,
                bottom: AppDimensions.instance!.height * 0.04)
            : nkLargePadding(
                right: AppDimensions.instance!.width * 0.08,
                left: AppDimensions.instance!.width * 0.08,
                top: AppDimensions.instance!.height * 0.04,
                bottom: AppDimensions.instance!.height * 0.04),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Scaffold(
            backgroundColor: secondaryColor,
            appBar: widget.leadCustomerData != null
                ? widget.isUpdate
                    ? DiloagAppBar(title: "$update $customer")
                    : DiloagAppBar(title: "$leads")
                : DiloagAppBar(title: "$add $leads"),
            body: SingleChildScrollView(
              physics: NkGeneralSize.commonPysics(),
              padding: nkRegularPadding(),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    nkMediumSizeBox(),

                    /// Full Name
                    formFiled(fullName,
                        widget.leadsController.customerNameTextController,
                        prefixIcon:
                            filedIcon(Assets.iconsIcAddLeadsSalesmanName)),
                    nkMediumSizeBox(),

                    /// Email & Mobile number
                    Row(
                      children: [
                        Flexible(
                            child: formFiled(email,
                                widget.leadsController.emailTextController,
                                textInputType: TextInputType.emailAddress,
                                validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return 'Please insert $email';
                          } else if (!NkCommonFunction.chckEmailValidation(
                              widget
                                  .leadsController.emailTextController.text)) {
                            return 'Please enter valid $email';
                          }
                          return null;
                        }, prefixIcon: filedIcon(Assets.iconsIcAddLeadsEmail))),
                        nkSmallSizeBox(),
                        Flexible(
                          child: formFiled(
                              mobileNumber,
                              autofillHints: [],
                              maxLength: 10,
                              textInputType: TextInputType.number,
                              widget.leadsController.mobileNumberTextController,
                              prefixIcon:
                                  filedIcon(Assets.iconsIcAddLeadsMobile)),
                        )
                      ],
                    ),
                    nkMediumSizeBox(),

                    /// Address & City

                    Row(
                      children: [
                        Flexible(
                          child: formFiled(address,
                              widget.leadsController.addressTextController,
                              textInputType: TextInputType.streetAddress,
                              prefixIcon:
                                  filedIcon(Assets.iconsIcView)),
                        ),
                        nkSmallSizeBox(),
                        Flexible(
                            child: formFiled(
                                city, widget.leadsController.cityTextController,
                                textInputType: TextInputType.streetAddress,
                                prefixIcon:
                                    filedIcon(Assets.iconsIcAddLeadsCity))),
                      ],
                    ),
                    nkMediumSizeBox(),

                    /// State & Zip Code
                    Row(
                      children: [
                        Flexible(
                            child: formFiled(state,
                                widget.leadsController.stateTextController,
                                textInputType: TextInputType.streetAddress,
                                prefixIcon:
                                    filedIcon(Assets.iconsIcAddLeadsState))),
                        nkSmallSizeBox(),
                        Flexible(
                            child: formFiled(zipCode,
                                widget.leadsController.zipCodeTextController,
                                textInputType: TextInputType.number,
                                maxLength: 6,
                                prefixIcon:
                                    filedIcon(Assets.iconsIcAddLeadsLocation))),
                      ],
                    ),

                    nkMediumSizeBox(),

                    /// Business name & Business contact number
                    Row(
                      children: [
                        Flexible(
                            child: formFiled(
                                businessName,
                                widget.leadsController
                                    .businessNameTextEditingController,
                                textInputType: TextInputType.streetAddress,
                                prefixIcon: filedIcon(
                                    Assets.iconsIcAddLeadsBusinessName))),
                        nkSmallSizeBox(),
                        Flexible(
                            child: formFiled(
                                autofillHints: [],
                                textInputType: TextInputType.number,
                                maxLength: 10,
                                businessContact,
                                widget.leadsController
                                    .businessContactTextEditingController,
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: primaryIconColor,
                                ))),
                      ],
                    ),

                    nkMediumSizeBox(),

                    /// Remark & Image
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child: formFiled(remark,
                                widget.leadsController.remarkTextController,
                                minLine: 4,
                                prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: AppDimensions.instance!.height *
                                            0.02),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        widthFactor: 1.0,
                                        heightFactor: 3.6,
                                        child: SvgPicture.asset(
                                          Assets.iconsIcAddLeadsRemark,
                                        ),
                                      ),
                                    )))),
                        nkSmallSizeBox(),
                        Flexible(
                          child: idAndImagePicWidget(
                              isShowError: isBrowserNotSelected,
                              "$capture $or",
                              browser,
                              formatSupports,
                              photoBrowser ?? File(''), onTap: () {
                            Get.defaultDialog(
                              backgroundColor: backgroundColor,
                              title: "Pick Image",
                              content: Flexible(
                                  child: AnimatedSize(
                                      duration:
                                          NkCommonFunction.shortDuration(),
                                      child: const NkFilePickerOptionWidget())),
                            ).then((value) {
                              setState(() {
                                photoBrowser = value;
                                isBrowserNotSelected = false;
                              });
                              log(value.toString());
                            });
                          }),
                        ),
                      ],
                    ),
                    nkMediumSizeBox(),
                    nkSmallSizeBox(),
                    widget.leadCustomerData != null
                        ? widget.isUpdate
                            ? FittedBox(child: updateCustomerButton)
                            : const SizedBox()
                        : addLeadsButton
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget get addLeadsButton => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: MyThemeButton(
              buttonText: add,
              onPressed: () {
                if (formKey.currentState!.validate() && checkDataEmptyOrNot) {
                  final salesmanId = SessionHelper.loginSavedData?.salesmanId??'';
                  widget.leadsController.addLeads(
                    assignId: salesmanId,
                    browserPath: photoBrowser!.path,
                  );
                }
              },
              width:
                  AppDimensions.instance!.orientation == Orientation.landscape
                      ? AppDimensions.instance!.width * 0.08
                      : null,
            ),
          ),
        ],
      );

  Widget get updateCustomerButton => NkLoadingButton(
      buttonText: update,
      width: AppDimensions.instance!.width * 0.15,
      onPressed: () {
        if (formKey.currentState!.validate() && checkDataEmptyOrNot) {
          updateCustomerData(widget.leadCustomerData);
        }
      },
      //btnController: widget.leadsController.btnController
      );

  bool get checkDataEmptyOrNot {
    if (photoBrowser == null && widget.leadCustomerData == null) {
      setState(() {
        isBrowserNotSelected = !isBrowserNotSelected;
      });

      NkCommonFunction.showErrorSnakBar(pleaseSelectPhoto);
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

  Widget formFiled(String lable, TextEditingController textEditingController,
      {int minLine = 1,
      Widget? prefixIcon,
      Widget? suffixIcon,
      Color? borderColor,
      int? maxLength,
      TextAlign? textAlign,
      TextInputType? textInputType,
      Iterable<String>? autofillHints,
      bool isReadOnly = false,
      bool isVisible = false,
      String? Function(dynamic)? validator,
      bool isRequired = true,
      int? maxLines,
      void Function(dynamic)? onChanged}) {
    return MyFormField(
      textAlign: textAlign ?? TextAlign.start,
      controller: textEditingController,
      labelText: lable,
      minLines: minLine,
      maxLines: maxLines,
      isRequire: isRequired,
      autofillHints: autofillHints,
      isShowDefaultValidator: true,
      obscureText: isVisible,
      contentPadding: const EdgeInsets.all(16.0),
      validator: validator,
      isReadOnly: !isEditableFiled,
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

  Widget idAndImagePicWidget(
      String lable, String highlightLatter, String formatSupport, File file,
      {void Function()? onTap, bool isShowError = false}) {
    Column imageTextCollumn = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Assets.iconsIcImagePic),
          nkSmallSizeBox(),
          RichText(
              text: TextSpan(
                  style: TextStyle(
                      fontWeight: NkGeneralSize.nkGeneralFontWeight(),
                      color: primaryTextColor),
                  children: [
                TextSpan(
                  text: "$lable ",
                ),
                TextSpan(
                    style: const TextStyle(color: skyBlueColor),
                    text: highlightLatter)
              ])),
          MyRegularText(
            label: formatSupport,
            color: secondaryTextColor,
            fontSize: NkFontSize.smallFont(),
          )
        ]);
    return MyCommnonContainer(
      isShowError: isShowError,
      padding: nkSymmetricPadding(horizontal: 0),
      height: AppDimensions.instance!.height * 0.18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkResponse(onTap: onTap, child: imageTextCollumn),
          nkSmallSizeBox(),
          Flexible(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
              child: file.path.isNotEmpty
                  ? Image.file(
                      file,
                      height: AppDimensions.instance!.height * 0.2,
                    )
                  : widget.leadCustomerData?.imageUrl != null
                      ? MyNetworkImage(
                          imageUrl: widget.leadCustomerData?.imageUrl ?? '',
                          height: AppDimensions.instance!.height * 0.2,
                        )
                      : nkSmallSizeBox(),
            ),
          )
        ],
      ),
    );
  }
}
