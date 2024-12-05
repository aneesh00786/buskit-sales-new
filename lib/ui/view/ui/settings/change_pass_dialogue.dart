// import 'package:busskit_admin/ui/components/color/colors.dart';
// import 'package:busskit_admin/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_admin/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_admin/ui/theme/custom_fonts.dart';
// import 'package:busskit_admin/ui/view/ui/settings/settings_controller.dart';
// import 'package:flutter/material.dart';

// class ChangePasswordDialog extends StatefulWidget {
//   //final SettingsController settingsController;

//   ChangePasswordDialog({required this.settingsController});

//   @override
//   _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
// }

// class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
//   final TextEditingController _currentPasswordController =
//       TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   @override
//   void dispose() {
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     final currentPassword = _currentPasswordController.text;
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword == confirmPassword) {
//       print('Current Password: $currentPassword');
//       print('New Password: $newPassword');
//     } else {
//       print('New password and confirmation do not match');
//     }

//     widget.settingsController.changePassword(
//       currentPass: currentPassword,
//       newPass: newPassword,
//       confirmPass: confirmPassword,
//       context: context,
//     );

//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: AlertDialog(
//         contentPadding: EdgeInsets.zero,
//         titlePadding: EdgeInsets.zero,
//         title: Container(
//           width: MediaQuery.of(context).size.width * 0.5,
//           padding: const EdgeInsets.all(10),
//           decoration: const BoxDecoration(
//             color: primaryColor,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10),
//               topRight: Radius.circular(10),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Change Password',
//                 style: TextStyle(
//                   color: white,
//                   fontSize: 16,
//                   fontFamily: 'Poppins_Regular',
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               dialogCloseButton(context, red)
//             ],
//           ),
//         ),
//         content: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildTextField(
//                 'Current Password',
//                 _currentPasswordController,
//               ),
//               nkMediumSizeBox(),
//               _buildTextField(
//                 'New Password',
//                 _newPasswordController,
//               ),
//               nkMediumSizeBox(),
//               _buildTextField(
//                 'Confirm Password',
//                 _confirmPasswordController,
//               ),
//               SizedBox(height: 20),
//               CustomButton(text: 'Change Password', onPressed: _submit)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w600),
//         ),
//         nkSmallSizeBox(),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: controller,
//                 decoration: InputDecoration(
//                   hintText: label,
//                   enabledBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Colors.grey.shade300, width: 1),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue, width: 2),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
