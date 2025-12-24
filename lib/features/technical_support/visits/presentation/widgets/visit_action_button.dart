// import 'package:flutter/material.dart';

// class VisitActionButton extends StatelessWidget {
//   final BuildContext context;
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const VisitActionButton({
//     super.key,
//     required this.context,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(25),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.2),
//               blurRadius: 15,
//               offset: const Offset(0, 5),
//             ),
//           ],
//           border: Border.all(color: color.withOpacity(0.3), width: 2),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Icon(
//                 icon,
//                 size: 40,
//                 color: color,
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: color,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_back_ios,
//               color: color,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
