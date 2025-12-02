// import 'package:flutter/material.dart';

// class SaveButton extends StatelessWidget {
//   final VoidCallback onPressed;

//   const SaveButton({
//     super.key,
//     required this.onPressed,
//   });

//   static const Color primaryColor = Color(0xFF56C7F1);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//         child: const Text(
//           'حفظ',
//           style: TextStyle(fontSize: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }