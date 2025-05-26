// import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/settings/widget/password_textfield.dart';
// import 'package:flutter/material.dart';

// Widget buildChangePasswordButton({
//   required BuildContext context,
//   required GlobalKey<FormState> formKey,
//   required TextEditingController oldPasswordController,
//   required TextEditingController newPasswordController,
//   required TextEditingController confirmPasswordController,
//   required bool obscureNew,
//   required bool obscureOld,
//   required bool obscureConfirm,
//   required StaffController staffController,
// }) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: [
//       InkWell(
//         onTap: () {
//           showDialog(
//             context: context,
//             builder: (context) {
//               final password = SessionHelper.loginSavedData?.password ?? '';
//               return StatefulBuilder(
//                 builder: (context, setState) {
//                   return Dialog(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: LayoutBuilder(
//                       builder: (context, constraints) {
//                         double dialogWidth = constraints.maxWidth * 0.9;
//                         double maxDialogHeight = constraints.maxHeight * 0.95;

//                         return ConstrainedBox(
//                           constraints: BoxConstraints(
//                             maxWidth: dialogWidth,
//                             maxHeight: maxDialogHeight,
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Form(
//                               key: formKey,
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       'Change Password',
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     PasswordField(
//                                       controller: oldPasswordController,
//                                       label: 'Old Password',
//                                       obscureText: obscureOld,
//                                       toggleVisibility: () => setState(
//                                           () => obscureOld = !obscureOld),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'Old password is required';
//                                         }
//                                         if (value != password) {
//                                           return 'Old password is incorrect';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                     const SizedBox(height: 12),
//                                     PasswordField(
//                                       controller: newPasswordController,
//                                       label: 'New Password',
//                                       obscureText: obscureNew,
//                                       toggleVisibility: () => setState(
//                                           () => obscureNew = !obscureNew),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'New password is required';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                     const SizedBox(height: 12),
//                                     PasswordField(
//                                       controller: confirmPasswordController,
//                                       label: 'Confirm Password',
//                                       obscureText: obscureConfirm,
//                                       toggleVisibility: () => setState(() =>
//                                           obscureConfirm = !obscureConfirm),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'Confirm password is required';
//                                         }
//                                         if (value !=
//                                             newPasswordController.text) {
//                                           return 'Passwords do not match';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                     const SizedBox(height: 24),
//                                     ElevatedButton(
//                                       style: ButtonStyle(
//                                           foregroundColor:
//                                               WidgetStatePropertyAll(white),
//                                           backgroundColor:
//                                               WidgetStatePropertyAll(
//                                                   Colors.blue)),
//                                       onPressed: () {
//                                         if (formKey.currentState!.validate()) {
//                                           staffController.changePassword(
//                                               currentPassword:
//                                                   oldPasswordController.text,
//                                               newPassword:
//                                                   newPasswordController.text,
//                                               confirmPassword:
//                                                   confirmPasswordController
//                                                       .text);
//                                           oldPasswordController.clear();
//                                           newPasswordController.clear();
//                                           confirmPasswordController.clear();
//                                           Navigator.pop(context);
//                                         }
//                                       },
//                                       child: Text('Submit'),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const Center(
//             child: Padding(
//               padding: EdgeInsets.all(15.0),
//               child: Text(
//                 'Change Password',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(
//         width: 10,
//       )
//     ],
//   );
// }
