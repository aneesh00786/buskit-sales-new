// class CustomSearchBar extends StatelessWidget {
//   final String text;
//   final TextEditingController controller;
//   final ValueChanged<String> onChange;
//   final IconData icon;

//   CustomSearchBar({
//     super.key,
//     required this.text,
//     required this.controller,
//     required this.onChange,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       onChanged: onChange,
//       decoration: InputDecoration(
//         fillColor: Colors.white,
//         filled: true,
//         hintText: text,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(
//             color: Colors.grey.shade300,
//             width: 1.0,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(
//             color: Colors.grey.shade300,
//             width: 1.0,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(
//             color: Colors.grey.shade500,
//             width: 1.5,
//           ),
//         ),
//         prefixIcon: Icon(icon),
//       ),
//     );
//   }
// }