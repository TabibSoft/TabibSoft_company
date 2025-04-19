import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/features/sales/data/model/sales_model.dart';
import 'package:tabib_soft_company/features/sales/presentation/screens/details/add_payment_screen.dart'; // استيراد الـ PopUp

class SalesDetailScreen extends StatelessWidget {
  final SalesModel measurement;
  final ApiService apiService; // إضافة ApiService

  const SalesDetailScreen({
    super.key,
    required this.measurement,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(
              title: 'تفاصيل الحجز',
              height: 300,
              leading: IconButton(
                icon: Image.asset(
                  'assets/images/pngs/back.png',
                  width: 30,
                  height: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.20,
            left: size.width * 0.05,
            right: size.width * 0.05,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF56C7F1), width: 3),
              ),
              child: SingleChildScrollView(
                child: Column(children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'اسم العميل: ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff178CBB),
                          ),
                        ),
                        TextSpan(
                          text: measurement.customerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildField(label: 'النشاط', value: measurement.proudctName),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'التاريخ',
                    value: measurement.customerTelephone,
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'العنوان',
                    value: measurement.adress ?? 'غير متوفر',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'العرض',
                    value: measurement.offerName ?? 'غير متوفر',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'الإجمالي',
                    value: measurement.total?.toString() ?? '0',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'ملاحظات',
                    value: measurement.note ?? 'لا توجد ملاحظات',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        label: 'حفظ',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      _buildButton(
                        label: 'إضافة مدفوعات',
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // يمنع الإغلاق باللمس الخارجي
                            builder: (_) => WillPopScope(
                              onWillPop: () async =>
                                  true, // يسمح فقط بزر العودة
                              child: AddPaymentPopup(
                                measurementId: measurement.id,
                                totalAmount: measurement.total ??
                                    0.0, // Provide default value of 0.0 if total is null
                                apiService: apiService,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      style: const TextStyle(color: Colors.black),
      enabled: false,
      maxLines: maxLines,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        suffixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF56C7F1)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: const Color(0xFF56C7F1).withOpacity(0.5), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: const Color(0xFF56C7F1).withOpacity(0.5), width: 1.5),
        ),
      ),
      controller: TextEditingController(text: value),
    );
  }

  Widget _buildButton(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 140,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF56C7F1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
// import 'package:tabib_soft_company/features/sales/data/model/sales_model.dart';

// class SalesDetailScreen extends StatelessWidget {
//   final SalesModel measurement;

//   const SalesDetailScreen({super.key, required this.measurement});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: Stack(children: [
//           // المنحني العلوي
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: CustomAppBar(
//               title: 'تفاصيل الحجز',
//               height: 300,
//               leading: IconButton(
//                 icon: Image.asset(
//                   'assets/images/pngs/back.png',
//                   width: 30,
//                   height: 30,
//                 ),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ),
//           // المحتوى التفصيلي
//           Positioned(
//             top: size.height * 0.20,
//             left: size.width * 0.05,
//             right: size.width * 0.05,
//             bottom: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: const Color(0xFF56C7F1), width: 3),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(children: [
//                   // اسم العميل في الأعلى (Bold)
//                   RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       children: [
//                         const TextSpan(
//                           text: 'اسم العميل: ',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xff178CBB),
//                           ),
//                         ),
//                         TextSpan(
//                           text: measurement.customerName,
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // النشاط
//                   _buildField(label: 'النشاط', value: measurement.proudctName),
//                   const SizedBox(height: 12),
//                   // التاريخ (استبدل measurement.date بالحقل المناسب)
//                   _buildField(
//                     label: 'التاريخ',
//                     value: measurement.customerTelephone,
//                     icon: Icons.calendar_today,
//                   ),
//                   const SizedBox(height: 12),
//                   // العنوان
//                   _buildField(
//                     label: 'العنوان',
//                     value: measurement.adress ?? 'غير متوفر',
//                   ),
//                   const SizedBox(height: 12),
//                   // العرض
//                   _buildField(
//                     label: 'العرض',
//                     value: measurement.offerName ?? 'غير متوفر',
//                   ),
//                   const SizedBox(height: 12),
//                   // الإجمالي
//                   _buildField(
//                     label: 'الإجمالي',
//                     value: measurement.total?.toString() ?? '0',
//                   ),
//                   const SizedBox(height: 12),
//                   // الملاحظات
//                   _buildField(
//                     label: 'ملاحظات',
//                     value: measurement.note ?? 'لا توجد ملاحظات',
//                     maxLines: 4,
//                   ),
//                   const SizedBox(height: 24),
//                   // الأزرار
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildButton(label: 'حفظ', onPressed: () {}),
//                       _buildButton(label: 'إضافة مدفوعات', onPressed: () {}),
//                     ],
//                   ),
//                 ]),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget _buildField({
//     required String label,
//     required String value,
//     IconData? icon,
//     int maxLines = 1,
//   }) {
//     return TextField(
//       style: const TextStyle(color: Colors.black),
//       enabled: false,
//       maxLines: maxLines,
//       textAlign: TextAlign.center,
//       decoration: InputDecoration(
//         hintText: label,
//         hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding:
//             const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//         suffixIcon:
//             icon != null ? Icon(icon, color: const Color(0xFF56C7F1)) : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide(
//               color: const Color(0xFF56C7F1).withOpacity(0.5), width: 1.5),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide(
//               color: const Color(0xFF56C7F1).withOpacity(0.5), width: 1.5),
//         ),
//       ),
//       controller: TextEditingController(text: value),
//     );
//   }

//   Widget _buildButton(
//       {required String label, required VoidCallback onPressed}) {
//     return SizedBox(
//       width: 140,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF56C7F1),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//         ),
//         child: Text(label,
//             style: const TextStyle(fontSize: 16, color: Colors.white)),
//       ),
//     );
//   }
// }
