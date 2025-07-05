// import 'package:flutter/material.dart';

// class ProgrammersDetailsDialog extends StatefulWidget {
//   final String programType;

//   const ProgrammersDetailsDialog({super.key, required this.programType});

//   @override
//   State<ProgrammersDetailsDialog> createState() =>
//       _ProgrammersDetailsDialogState();
// }

// class _ProgrammersDetailsDialogState extends State<ProgrammersDetailsDialog> {
//   // حالة المهام (true لـ "نعم"، false لـ "لا")
//   List<bool> taskStates = [true, false, true]; // بيانات اختبارية

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Container(
//         width: size.width * 0.8,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: const Color(0xFF56C7F1), width: 3),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // العنوان والزر
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'إضافة مشروع',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     // إضافة مهمة جديدة (يمكن توسيع المنطق لاحقًا)
//                   },
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF178CBB),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.add, color: Colors.white, size: 24),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // قائمة المهام
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: taskStates.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       const Text(
//                         'اسم المشروع: مهمة جديدة',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             taskStates[index] = false;
//                           });
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: taskStates[index]
//                                 ? Colors.white
//                                 : const Color(0xFF178CBB),
//                             shape: BoxShape.circle,
//                             border: Border.all(color: const Color(0xFF178CBB)),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'لا',
//                               style: TextStyle(
//                                 color: taskStates[index]
//                                     ? const Color(0xFF178CBB)
//                                     : Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             taskStates[index] = true;
//                           });
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: taskStates[index]
//                                 ? const Color(0xFF178CBB)
//                                 : Colors.white,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: const Color(0xFF178CBB)),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'نعم',
//                               style: TextStyle(
//                                 color: taskStates[index]
//                                     ? Colors.white
//                                     : const Color(0xFF178CBB),
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
