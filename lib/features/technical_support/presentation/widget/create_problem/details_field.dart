// import 'package:flutter/material.dart';

// class DetailsField extends StatelessWidget {
//   final TextEditingController controller;

//   const DetailsField({
//     super.key,
//     required this.controller,
//   });

//   static const Color primaryColor = Color(0xFF56C7F1);

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       textAlign: TextAlign.center,
//       maxLines: 3,
//       decoration: InputDecoration(
//         hintText: 'تفاصيل',
//         hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide:
//               BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide:
//               BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//       ),
//     );
//   }
// }