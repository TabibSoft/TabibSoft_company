// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
// import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';

// class DirectionDropdown extends StatelessWidget {
//   final TextEditingController controller;
//   final bool isDropdownVisible;
//   final VoidCallback onToggleDropdown;

//   const DirectionDropdown({
//     super.key,
//     required this.controller,
//     required this.isDropdownVisible,
//     required this.onToggleDropdown,
//   });

//   static const Color primaryColor = Color(0xFF56C7F1);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onToggleDropdown,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(30),
//               border: Border.all(
//                   color: primaryColor.withOpacity(0.5), width: 1.5),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     controller.text.isEmpty ? 'توجيه إلي' : controller.text,
//                     style: TextStyle(
//                       color: controller.text.isEmpty
//                           ? Colors.grey
//                           : Colors.black,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/pngs/drop_down.png',
//                   width: 24,
//                   height: 24,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (isDropdownVisible)
//           Container(
//             margin: const EdgeInsets.only(top: 8),
//             constraints: const BoxConstraints(maxHeight: 300),
//             padding: const EdgeInsets.only(right: 15.0, left: 15),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(color: primaryColor, width: 1.5),
//             ),
//             child: BlocBuilder<EngineerCubit, EngineerState>(
//               builder: (context, state) {
//                 if (state.status == EngineerStatus.loading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state.engineers.isNotEmpty) {
//                   return ListView(
//                     shrinkWrap: true,
//                     physics: const ClampingScrollPhysics(),
//                     children: state.engineers.map((engineer) {
//                       return ListTile(
//                         title: Text(engineer.name),
//                         onTap: () {
//                           controller.text = engineer.name;
//                           onToggleDropdown();
//                         },
//                       );
//                     }).toList(),
//                   );
//                 } else {
//                   return const Text('لا توجد مهندسين متاحين');
//                 }
//               },
//             ),
//           ),
//       ],
//     );
//   }
// }
