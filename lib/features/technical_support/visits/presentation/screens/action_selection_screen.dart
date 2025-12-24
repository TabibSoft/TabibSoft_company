// import 'package:flutter/material.dart';
// import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';
// import 'package:tabib_soft_company/features/technical_support/visits/presentation/screens/visit_detail_screen.dart';
// import 'package:tabib_soft_company/features/technical_support/visits/presentation/screens/visit_notes_screen.dart';
// import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/visit_action_button.dart';

// class ActionSelectionScreen extends StatelessWidget {
//   final VisitModel visit;

//   const ActionSelectionScreen({super.key, required this.visit});

//   @override
//   Widget build(BuildContext context) {
//     const mainBlueColor = Color(0xFF16669E);
//     const cyanButtonColor = Color(0xFF00BCD4);

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         backgroundColor: mainBlueColor,
//         body: SafeArea(
//           bottom: false,
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Center(
//                 child: Image.asset(
//                   'assets/images/pngs/TS_Logo0.png',
//                   width: 110,
//                   height: 110,
//                   fit: BoxFit.contain,
//                   color: Colors.white.withOpacity(0.4),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFF5F7FA),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(35),
//                       topRight: Radius.circular(35),
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(30),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'اختر نوع الإجراء المطلوب',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: mainBlueColor,
//                         ),
//                       ),
//                       const SizedBox(height: 50),

//                       // زر الملاحظات العامة
//                       VisitActionButton(
//                         context: context,
//                         title: 'الملاحظات العامة',
//                         subtitle: 'إضافة ملاحظات مع صور وتفاصيل كاملة',
//                         icon: Icons.edit_note,
//                         color: cyanButtonColor,
//                         onTap: () async {
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   VisitDetailScreen(visit: visit),
//                             ),
//                           );

//                           // إذا تم إتمام الزيارة أو حفظ التفاصيل، ارجع بـ true
//                           if (result == true && context.mounted) {
//                             Navigator.pop(context, true);
//                           }
//                         },
//                       ),

//                       const SizedBox(height: 30),

//                       // زر إضافة ملاحظة سريعة
//                       VisitActionButton(
//                         context: context,
//                         title: 'إضافة ملاحظة',
//                         subtitle: 'ملاحظة نصية سريعة',
//                         icon: Icons.note_add,
//                         color: const Color(0xFF2196F3),
//                         onTap: () async {
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   VisitNotesScreen(visit: visit),
//                             ),
//                           );

//                           // إذا تمت إضافة ملاحظة، ارجع بـ true
//                           if (result == true && context.mounted) {
//                             Navigator.pop(context, true);
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
