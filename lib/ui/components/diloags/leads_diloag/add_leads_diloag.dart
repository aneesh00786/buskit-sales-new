import 'dart:developer';
import 'dart:io';

// import 'package:address_search_field/address_search_field.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
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
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// class AddLeadsDiloag extends StatefulWidget {
//   final bool isUpdate;
//   final LeadsController leadsController;
//   final LeadCustomerData? leadCustomerData;
//   const AddLeadsDiloag(
//       {super.key,
//       required this.leadsController,
//       this.leadCustomerData,
//       this.isUpdate = false});

//   @override
//   State<AddLeadsDiloag> createState() => _AddLeadsDiloagState();
// }

// class _AddLeadsDiloagState extends State<AddLeadsDiloag> {
//   File? photoBrowser;
//   bool isBrowserNotSelected = false, isEditableFiled = true;
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     loadAllFillData(widget.leadCustomerData);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     widget.leadsController.clearAllFileds;

//     super.dispose();
//   }

//   loadAllFillData(LeadCustomerData? leadCustomerData) {
//     if (leadCustomerData != null) {
//       if (widget.isUpdate) {
//         isEditableFiled = true;
//       } else {
//         isEditableFiled = false;
//       }
//       widget.leadsController.customerNameTextController.text =
//           leadCustomerData.fullname!;
//       widget.leadsController.emailTextController.text = leadCustomerData.email!;
//       widget.leadsController.mobileNumberTextController.text =
//           leadCustomerData.mobileno!;
//       widget.leadsController.zipCodeTextController.text =
//           leadCustomerData.zipcode!.toString();
//       widget.leadsController.remarkTextController.text =
//           leadCustomerData.remark!;
//       widget.leadsController.addressTextController.text =
//           leadCustomerData.address!;
//       widget.leadsController.cityTextController.text = leadCustomerData.town!;
//       widget.leadsController.stateTextController.text = leadCustomerData.state!;
//       widget.leadsController.businessNameTextEditingController.text =
//           leadCustomerData.businessName!;
//       widget.leadsController.businessContactTextEditingController.text =
//           leadCustomerData.businessNo!;
//     }
//   }

//   updateCustomerData(LeadCustomerData? leadCustomerData) {
//     leadCustomerData!.customerId = widget.leadCustomerData!.customerId;
//     leadCustomerData.status = widget.leadCustomerData!.status;
//     leadCustomerData.imageUrl =
//         photoBrowser?.path ?? widget.leadCustomerData!.imageUrl;
//     leadCustomerData.fullname =
//         widget.leadsController.customerNameTextController.text.trim();
//     leadCustomerData.mobileno =
//         widget.leadsController.mobileNumberTextController.text.trim();
//     leadCustomerData.email =
//         widget.leadsController.emailTextController.text.trim();
//     leadCustomerData.town =
//         widget.leadsController.cityTextController.text.trim();
//     leadCustomerData.address =
//         widget.leadsController.addressTextController.text.trim();
//     leadCustomerData.state =
//         widget.leadsController.stateTextController.text.trim();
//     leadCustomerData.zipcode =
//         int.parse(widget.leadsController.zipCodeTextController.text.trim());
//     leadCustomerData.businessName =
//         widget.leadsController.businessNameTextEditingController.text.trim();
//     leadCustomerData.businessNo =
//         widget.leadsController.businessContactTextEditingController.text.trim();
//     leadCustomerData.remark =
//         widget.leadsController.remarkTextController.text.trim();

//     widget.leadsController.updateLeads(leadCustomerData);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return OrientationBuilder(builder: (context, ore) {
//       return SafeArea(
//         minimum: ore == Orientation.landscape
//             ? nkLargePadding(
//                 right: AppDimensions.instance!.width * 0.12,
//                 left: AppDimensions.instance!.width * 0.12,
//                 top: AppDimensions.instance!.height * 0.04,
//                 bottom: AppDimensions.instance!.height * 0.04)
//             : nkLargePadding(
//                 right: AppDimensions.instance!.width * 0.08,
//                 left: AppDimensions.instance!.width * 0.08,
//                 top: AppDimensions.instance!.height * 0.04,
//                 bottom: AppDimensions.instance!.height * 0.04),
//         child: ClipRRect(
//           borderRadius:
//               BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
//           child: Scaffold(
//             backgroundColor: secondaryColor,
//             appBar: widget.leadCustomerData != null
//                 ? widget.isUpdate
//                     ? DiloagAppBar(title: "$update $customer")
//                     : DiloagAppBar(title: "$leads")
//                 : DiloagAppBar(title: "$add $leads"),
//             body: SingleChildScrollView(
//               physics: NkGeneralSize.commonPysics(),
//               padding: nkRegularPadding(),
//               child: Form(
//                 key: formKey,
//                 child: Column(
//                   children: [
//                     nkMediumSizeBox(),

//                     /// Full Name
//                     formFiled(fullName,
//                         widget.leadsController.customerNameTextController,
//                         prefixIcon:
//                             filedIcon(Assets.iconsIcAddLeadsSalesmanName)),
//                     nkMediumSizeBox(),

//                     /// Email & Mobile number
//                     Row(
//                       children: [
//                         Flexible(
//                             child: formFiled(email,
//                                 widget.leadsController.emailTextController,
//                                 textInputType: TextInputType.emailAddress,
//                                 validator: (p0) {
//                           if (p0 == null || p0.isEmpty) {
//                             return 'Please insert $email';
//                           } else if (!NkCommonFunction.chckEmailValidation(
//                               widget
//                                   .leadsController.emailTextController.text)) {
//                             return 'Please enter valid $email';
//                           }
//                           return null;
//                         }, prefixIcon: filedIcon(Assets.iconsIcAddLeadsEmail))),
//                         nkSmallSizeBox(),
//                         Flexible(
//                           child: formFiled(
//                               mobileNumber,
//                               autofillHints: [],
//                               maxLength: 10,
//                               textInputType: TextInputType.number,
//                               widget.leadsController.mobileNumberTextController,
//                               prefixIcon:
//                                   filedIcon(Assets.iconsIcAddLeadsMobile)),
//                         )
//                       ],
//                     ),
//                     nkMediumSizeBox(),

//                     /// Address & City

//                     Row(
//                       children: [
//                         Flexible(
//                           child: formFiled(address,
//                               widget.leadsController.addressTextController,
//                               textInputType: TextInputType.streetAddress,
//                               prefixIcon:
//                                   filedIcon(Assets.iconsIcView)),
//                         ),
//                         nkSmallSizeBox(),
//                         Flexible(
//                             child: formFiled(
//                                 city, widget.leadsController.cityTextController,
//                                 textInputType: TextInputType.streetAddress,
//                                 prefixIcon:
//                                     filedIcon(Assets.iconsIcAddLeadsCity))),
//                       ],
//                     ),
//                     nkMediumSizeBox(),

//                     /// State & Zip Code
//                     Row(
//                       children: [
//                         Flexible(
//                             child: formFiled(state,
//                                 widget.leadsController.stateTextController,
//                                 textInputType: TextInputType.streetAddress,
//                                 prefixIcon:
//                                     filedIcon(Assets.iconsIcAddLeadsState))),
//                         nkSmallSizeBox(),
//                         Flexible(
//                             child: formFiled(zipCode,
//                                 widget.leadsController.zipCodeTextController,
//                                 textInputType: TextInputType.number,
//                                 maxLength: 6,
//                                 prefixIcon:
//                                     filedIcon(Assets.iconsIcAddLeadsLocation))),
//                       ],
//                     ),

//                     nkMediumSizeBox(),

//                     /// Business name & Business contact number
//                     Row(
//                       children: [
//                         Flexible(
//                             child: formFiled(
//                                 businessName,
//                                 widget.leadsController
//                                     .businessNameTextEditingController,
//                                 textInputType: TextInputType.streetAddress,
//                                 prefixIcon: filedIcon(
//                                     Assets.iconsIcAddLeadsBusinessName))),
//                         nkSmallSizeBox(),
//                         Flexible(
//                             child: formFiled(
//                                 autofillHints: [],
//                                 textInputType: TextInputType.number,
//                                 maxLength: 10,
//                                 businessContact,
//                                 widget.leadsController
//                                     .businessContactTextEditingController,
//                                 prefixIcon: const Icon(
//                                   Icons.phone,
//                                   color: primaryIconColor,
//                                 ))),
//                       ],
//                     ),

//                     nkMediumSizeBox(),

//                     /// Remark & Image
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Flexible(
//                             child: formFiled(remark,
//                                 widget.leadsController.remarkTextController,
//                                 minLine: 4,
//                                 prefixIcon: Padding(
//                                     padding: EdgeInsets.only(
//                                         bottom: AppDimensions.instance!.height *
//                                             0.02),
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(top: 15),
//                                       child: Align(
//                                         alignment: Alignment.topCenter,
//                                         widthFactor: 1.0,
//                                         heightFactor: 3.6,
//                                         child: SvgPicture.asset(
//                                           Assets.iconsIcAddLeadsRemark,
//                                         ),
//                                       ),
//                                     )))),
//                         nkSmallSizeBox(),
//                         Flexible(
//                           child: idAndImagePicWidget(
//                               isShowError: isBrowserNotSelected,
//                               "$capture $or",
//                               browser,
//                               formatSupports,
//                               photoBrowser ?? File(''), onTap: () {
//                             Get.defaultDialog(
//                               backgroundColor: backgroundColor,
//                               title: "Pick Image",
//                               content: Flexible(
//                                   child: AnimatedSize(
//                                       duration:
//                                           NkCommonFunction.shortDuration(),
//                                       child: const NkFilePickerOptionWidget())),
//                             ).then((value) {
//                               setState(() {
//                                 photoBrowser = value;
//                                 isBrowserNotSelected = false;
//                               });
//                               log(value.toString());
//                             });
//                           }),
//                         ),
//                       ],
//                     ),
//                     nkMediumSizeBox(),
//                     nkSmallSizeBox(),
//                     widget.leadCustomerData != null
//                         ? widget.isUpdate
//                             ? FittedBox(child: updateCustomerButton)
//                             : const SizedBox()
//                         : addLeadsButton
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Widget get addLeadsButton => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Flexible(
//             child: MyThemeButton(
//               buttonText: add,
//               onPressed: () {
//                 if (formKey.currentState!.validate() && checkDataEmptyOrNot) {
//                   final salesmanId = SessionHelper.loginSavedData?.salesmanId??'';
//                   widget.leadsController.addLeads(
//                     assignId: salesmanId,
//                     browserPath: photoBrowser!.path,
//                   );
//                 }
//               },
//               width:
//                   AppDimensions.instance!.orientation == Orientation.landscape
//                       ? AppDimensions.instance!.width * 0.08
//                       : null,
//             ),
//           ),
//         ],
//       );

//   Widget get updateCustomerButton => NkLoadingButton(
//       buttonText: update,
//       width: AppDimensions.instance!.width * 0.15,
//       onPressed: () {
//         if (formKey.currentState!.validate() && checkDataEmptyOrNot) {
//           updateCustomerData(widget.leadCustomerData);
//         }
//       },
//       //btnController: widget.leadsController.btnController
//       );

//   bool get checkDataEmptyOrNot {
//     if (photoBrowser == null && widget.leadCustomerData == null) {
//       setState(() {
//         isBrowserNotSelected = !isBrowserNotSelected;
//       });

//       NkCommonFunction.showErrorSnakBar(pleaseSelectPhoto);
//       return false;
//     }
//     return true;
//   }

//   Widget filedIcon(String svgIconPath) {
//     return SvgPicture.asset(
//       svgIconPath,
//       fit: BoxFit.scaleDown,
//       height: AppDimensions.instance!.height * 0.014,
//       width: AppDimensions.instance!.width * 0.014,
//     );
//   }

//   Widget formFiled(String lable, TextEditingController textEditingController,
//       {int minLine = 1,
//       Widget? prefixIcon,
//       Widget? suffixIcon,
//       Color? borderColor,
//       int? maxLength,
//       TextAlign? textAlign,
//       TextInputType? textInputType,
//       Iterable<String>? autofillHints,
//       bool isReadOnly = false,
//       bool isVisible = false,
//       String? Function(dynamic)? validator,
//       bool isRequired = true,
//       int? maxLines,
//       void Function(dynamic)? onChanged}) {
//     return MyFormField(
//       textAlign: textAlign ?? TextAlign.start,
//       controller: textEditingController,
//       labelText: lable,
//       minLines: minLine,
//       maxLines: maxLines,
//       isRequire: isRequired,
//       autofillHints: autofillHints,
//       isShowDefaultValidator: true,
//       obscureText: isVisible,
//       contentPadding: const EdgeInsets.all(16.0),
//       validator: validator,
//       isReadOnly: !isEditableFiled,
//       onChanged: onChanged,
//       maxLength: maxLength,
//       textInputType: textInputType ?? TextInputType.text,
//       alignLabelWithHint: true,
//       enableColor: borderColor,
//       disabledColor: borderColor,
//       focusedColor: borderColor,
//       borderRadius: BorderRadius.circular(
//           NkGeneralSize.nkCommonBorderRadius(borderRadius: 10)),
//       prefixIconUnderLine: prefixIcon,
//       suffixIcon: suffixIcon,
//     );
//   }

//   Widget idAndImagePicWidget(
//       String lable, String highlightLatter, String formatSupport, File file,
//       {void Function()? onTap, bool isShowError = false}) {
//     Column imageTextCollumn = Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset(Assets.iconsIcImagePic),
//           nkSmallSizeBox(),
//           RichText(
//               text: TextSpan(
//                   style: TextStyle(
//                       fontWeight: NkGeneralSize.nkGeneralFontWeight(),
//                       color: primaryTextColor),
//                   children: [
//                 TextSpan(
//                   text: "$lable ",
//                 ),
//                 TextSpan(
//                     style: const TextStyle(color: skyBlueColor),
//                     text: highlightLatter)
//               ])),
//           MyRegularText(
//             label: formatSupport,
//             color: secondaryTextColor,
//             fontSize: NkFontSize.smallFont(),
//           )
//         ]);
//     return MyCommnonContainer(
//       isShowError: isShowError,
//       padding: nkSymmetricPadding(horizontal: 0),
//       height: AppDimensions.instance!.height * 0.18,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkResponse(onTap: onTap, child: imageTextCollumn),
//           nkSmallSizeBox(),
//           Flexible(
//             child: ClipRRect(
//               borderRadius:
//                   BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
//               child: file.path.isNotEmpty
//                   ? Image.file(
//                       file,
//                       height: AppDimensions.instance!.height * 0.2,
//                     )
//                   : widget.leadCustomerData?.imageUrl != null
//                       ? MyNetworkImage(
//                           imageUrl: widget.leadCustomerData?.imageUrl ?? '',
//                           height: AppDimensions.instance!.height * 0.2,
//                         )
//                       : nkSmallSizeBox(),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

Consumer<CustomersProvider> addLeads(BuildContext context) {
  bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
  return Consumer<CustomersProvider>(builder: (context, provider, child) {
    return FutureBuilder<CustomerResponse>(
      future: provider.customerResponse,
      builder: (context, snapshot) {
        final customer = snapshot.data?.data.first;

        TextEditingController nameController = TextEditingController();
        TextEditingController phoneController = TextEditingController();
        TextEditingController emailController = TextEditingController();
        TextEditingController telephoneController = TextEditingController();
        TextEditingController townController = TextEditingController();
        TextEditingController stateController = TextEditingController();
        TextEditingController zipcodeController = TextEditingController();
        TextEditingController addressController = TextEditingController();

        TextEditingController bsNameController = TextEditingController();
        TextEditingController bsNumController = TextEditingController();

        TextEditingController contactPersonNameController =
            TextEditingController();
        TextEditingController contactNumController = TextEditingController();

        TextEditingController deliveryAddressController =
            TextEditingController();
        TextEditingController deliveryTownController = TextEditingController();
        TextEditingController deliveryStateController = TextEditingController();
        TextEditingController deliveryZipcodeController =
            TextEditingController();

        TextEditingController remarkController = TextEditingController();

        bool sameAsAbove = false;

        return SizedBox(
          height: isSmallScreen ? 29 : 38,
          width: isSmallScreen ? 87 : 100,
          child: CustomButtonLeads(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Dialog(
                        insetPadding: EdgeInsets.zero,
                        backgroundColor:
                            const Color.fromARGB(255, 237, 238, 243),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          side: BorderSide.none,
                        ),
                        elevation: 24.0,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4.8),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Add Leads',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                      ),
                                    ),
                                    dialogCloseButton1(context, Colors.red),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 16.0),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    buildInputField(bsNameController,
                                        'Business Name', Icons.business),
                                    buildInputField(addressController,
                                        'Address', Icons.home),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(townController,
                                              'Town', Icons.location_city),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              stateController,
                                              'State',
                                              Icons.map),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              zipcodeController,
                                              'Zip Code',
                                              Icons.pin_drop),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(
                                              phoneController,
                                              'Mobile Number',
                                              Icons.phone),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              emailController,
                                              'Email',
                                              Icons.email),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              telephoneController,
                                              'Telephone',
                                              Icons.phone_in_talk),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 6.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Contact Details',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(
                                              contactPersonNameController,
                                              'Contact Person',
                                              Icons.person),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              contactNumController,
                                              'Contact Number',
                                              Icons.phone),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Delivery Address    ',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Checkbox(
                                            value: sameAsAbove,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                sameAsAbove = value ?? false;
                                                if (sameAsAbove) {
                                                  deliveryAddressController
                                                          .text =
                                                      addressController.text;
                                                  deliveryTownController.text =
                                                      townController.text;
                                                  deliveryStateController.text =
                                                      stateController.text;
                                                  deliveryZipcodeController
                                                          .text =
                                                      zipcodeController.text;
                                                } else {
                                                  deliveryAddressController
                                                      .clear();
                                                  deliveryTownController
                                                      .clear();
                                                  deliveryStateController
                                                      .clear();
                                                  deliveryZipcodeController
                                                      .clear();
                                                }
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 5),
                                          const Text('Same as Above'),
                                        ],
                                      ),
                                    ),
                                    buildInputField(deliveryAddressController,
                                        'Delivery Address', Icons.location_on),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(
                                              deliveryTownController,
                                              'Delivery Town',
                                              Icons.location_city),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              deliveryStateController,
                                              'Delivery State',
                                              Icons.map),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              deliveryZipcodeController,
                                              'Delivery Zip Code',
                                              Icons.pin_drop),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // Remark Input Field
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey
                                                  .shade100, // Subtle background color
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .shade300, // Light shadow
                                                  blurRadius: 6.0,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: TextField(
                                              controller: remarkController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 18.0),
                                                labelText: 'Remark',
                                                labelStyle: TextStyle(
                                                    color:
                                                        Colors.grey.shade600),
                                                prefixIcon: Icon(Icons.comment,
                                                    color:
                                                        Colors.grey.shade600),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: const BorderSide(
                                                      color: Colors.blue,
                                                      width: 1.5),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1.0),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),

                                        // Image Picker
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: provider.pickImage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .shade100, // Subtle background color
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    blurRadius: 6.0,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 18.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      color:
                                                          Colors.grey.shade600,
                                                      size: 28.0,
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: Text(
                                                        provider.imageFile ==
                                                                null
                                                            ? 'Pick an image from gallery'
                                                            : 'Image selected',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final updatedAdmin =
                                            // {
                                            //   "userid": "ADMIN",
                                            //   "businessname": bsNameController.text,
                                            //   "address": addressController.text,
                                            //   "town": townController.text,
                                            //   "state": stateController.text,
                                            //   "zipcode": zipcodeController.text,
                                            //   "mobileno": phoneController.text,
                                            //   "email": emailController.text,
                                            //   "tfn": telephoneController.text,
                                            //   "fullname": contactPersonNameController.text,
                                            //   "businesscontact": contactNumController.text,
                                            //   "addressCheckbox": "ON",
                                            //   "delivery_address": deliveryAddressController.text,
                                            //   "delivery_town": deliveryTownController.text,
                                            //   "delivery_state": deliveryStateController.text,
                                            //   "delivery_zipcode": deliveryZipcodeController.text,
                                            //   "remark": remarkController.text,
                                            //   "customerpicture": '',
                                            //   "company_id": SessionHelper.loginSavedData?.companyId ?? 0,
                                            //   "salesman_id": null,
                                            //   "salesman_name": null,
                                            //   "status_type": 1
                                            // };

                                            CustomerDashMo(
                                          fullname: nameController.text,
                                          mobileno: phoneController.text,
                                          email: emailController.text,
                                          town: townController.text,
                                          state: stateController.text,
                                          zipcode:
                                              int.parse(zipcodeController.text),
                                          address: addressController.text,
                                          businessName: bsNameController.text,
                                          businessNo: bsNumController.text,
                                        );

                                        try {
                                          await provider.addCustomer(
                                              admin: updatedAdmin,
                                              salsmanId: customer!.salesmanId
                                                  .toString());
                                          Navigator.of(context).pop();
                                        } catch (error) {
                                          log(error.toString());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Add Leads',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            text: 'Leads',
          ),
        );
      },
    );
  });
}

Widget buildInputField(
    TextEditingController controller, String labelText, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Subtle background color
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300, // Light shadow
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 18.0), // Modern padding
          labelText: labelText,
          labelStyle:
              TextStyle(color: Colors.grey.shade600), // Modern label color
          prefixIcon: Icon(icon, color: Colors.grey.shade600), // Icon styling
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Colors.blue, width: 1.5), // Highlight color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
                color: Colors.grey.shade400, width: 1.0), // Neutral border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Colors.red, width: 1.5), // Error styling
          ),
          filled: true,
          fillColor: Colors.white, // Background inside the text field
        ),
      ),
    ),
  );
}

class CustomButtonLeads extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  const CustomButtonLeads({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: primaryColor,
                fontSize: isSmallScreen ? 7 : 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: isSmallScreen ? 10 : 14,
            ),
          ],
        ),
      ),
    );
  }
}
