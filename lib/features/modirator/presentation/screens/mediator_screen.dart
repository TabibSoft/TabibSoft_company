// lib/features/home/presentation/screens/moderator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/modirator/export.dart';


class ModeratorScreen extends StatelessWidget {
  const ModeratorScreen({super.key});

  static const Color topDark = Color(0xFF104D9D);
  static const Color topLight = Color(0xFF20AAC9);
  static const Color buttonBorder = Color(0xFF1386B0);
  static const double _cardTopFactor = 0.36;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 19, 99, 209),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: size.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topDark, topLight],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    'assets/images/pngs/TS_Logo1.png',
                    width: size.width * 0.9,
                    height: size.width * 0.45,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: size.height * _cardTopFactor,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F8FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36.r),
                      topRight: Radius.circular(36.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      BigPillButton(
                        context,
                        label: 'عميل جديد',
                        onTap: () => _openNewClientDialog(context),
                        borderColor: buttonBorder,
                      ),
                      SizedBox(height: 39.h),
                      BigPillButton(
                        context,
                        label: 'إضافة مشكلة',
                        onTap: () => _openAddIssueDialog(context),
                        borderColor: buttonBorder,
                      ),
                      SizedBox(height: 39.h),
                      BigPillButton(
                        context,
                        label: 'إضافة اشتراك',
                        onTap: () => _openAddSubscriptionDialog(context),
                        borderColor: buttonBorder,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigPillButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required Color borderColor,
  }) {
    return BigPillButton(
      context,
      label: label,
      onTap: onTap,
      borderColor: borderColor,
    );
  }

  // POP-UP dialogs
  Future<void> _openNewClientDialog(BuildContext context) async {
    await _openBlockingDialog(
      context,
      title: 'عميل جديد',
      child: AddCustomerForm(onSaved: () => Navigator.of(context).pop()),
    );
  }

  Future<void> _openAddIssueDialog(BuildContext context) async {
    await _openBlockingDialog(
      context,
      title: 'إضافة مشكلة',
      child: AddIssueForm(
        onSaved: () => Navigator.of(context).pop(),
        onClientTap: () => _openNewClientDialog(context),
      ),
    );
  }

  Future<void> _openAddSubscriptionDialog(BuildContext context) async {
    await _openBlockingDialog(
      context,
      title: 'إضافة اشتراك',
      child: AddSubscriptionForm(
        onSaved: () => Navigator.of(context).pop(),
        onClientTap: () => _openAddIssueDialog(context),
      ),
    );
  }

  Future<void> _openBlockingDialog(
    BuildContext context, {
    required String title,
    required Widget child,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => true,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              insetPadding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 720.w),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DialogGrabberAndTitle(title),
                            SizedBox(height: 8.h),
                            child,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        tooltip: 'إغلاق',
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}






// // lib/features/home/presentation/screens/mediator_screen.dart
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tabib_soft_company/features/modirator/data/models/add_subscription_model.dart';
// import 'package:tabib_soft_company/features/modirator/data/models/payment_method_model.dart';
// import 'package:tabib_soft_company/features/modirator/presentation/cubits/add_subscription_cubit.dart';
// import 'package:tabib_soft_company/features/modirator/presentation/cubits/payment_method_cubit.dart';
// import 'package:tabib_soft_company/features/modirator/presentation/cubits/payment_method_state.dart';
// import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
// import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
// import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
// import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/add_customer_model.dart';
// import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
// import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
// import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_customer_state.dart';
// import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
// import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_state.dart';
// import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
// import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';
// import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
// import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';

// class ModiratorScreen extends StatelessWidget {
//   const ModiratorScreen({super.key});

//   static const Color topDark = Color(0xFF104D9D);
//   static const Color topLight = Color(0xFF20AAC9);
//   static const Color buttonBorder = Color(0xFF1386B0);
//   static const double _cardTopFactor = 0.36;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: const Color.fromARGB(255, 19, 99, 209),
//         body: SafeArea(
//           child: Stack(
//             children: [
//               Container(
//                 height: size.height,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [topDark, topLight],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 40,
//                 left: 0,
//                 right: 0,
//                 child: Opacity(
//                   opacity: 0.12,
//                   child: Image.asset(
//                     'assets/images/pngs/TS_Logo1.png',
//                     width: size.width * 0.9,
//                     height: size.width * 0.45,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: size.height * _cardTopFactor,
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF3F8FA),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(36.r),
//                       topRight: Radius.circular(36.r),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 30.h),
//                       _bigPillButton(
//                         context,
//                         label: 'عميل جديد',
//                         onTap: () => _openNewClientDialog(context),
//                         borderColor: buttonBorder,
//                       ),
//                       SizedBox(height: 39.h),
//                       _bigPillButton(
//                         context,
//                         label: 'إضافة مشكلة',
//                         onTap: () => _openAddIssueDialog(context),
//                         borderColor: buttonBorder,
//                       ),
//                       SizedBox(height: 39.h),
//                       _bigPillButton(
//                         context,
//                         label: 'إضافة اشتراك',
//                         onTap: () => _openAddSubscriptionDialog(context),
//                         borderColor: buttonBorder,
//                       ),
//                       const Spacer(),
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

//   Widget _bigPillButton(
//     BuildContext context, {
//     required String label,
//     required VoidCallback onTap,
//     required Color borderColor,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       height: 78.h,
//       child: ElevatedButton(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white,
//           elevation: 6,
//           shadowColor: Colors.black26,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(48.r),
//             side: BorderSide(color: borderColor, width: 2),
//           ),
//           padding: EdgeInsets.zero,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: const Color(0xFF0F5FA8),
//                 fontSize: 22.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // POP-UP dialogs
//   Future<void> _openNewClientDialog(BuildContext context) async {
//     await _openBlockingDialog(
//       context,
//       title: 'عميل جديد',
//       child: _NewClientForm(onSaved: () => Navigator.of(context).pop()),
//     );
//   } // يستخدم showDialog مع barrierDismissible:false بحسب التوثيق.

//   Future<void> _openAddIssueDialog(BuildContext context) async {
//     await _openBlockingDialog(
//       context,
//       title: 'إضافة مشكلة',
//       child: _AddIssueForm(
//         onSaved: () => Navigator.of(context).pop(),
//         onClientTap: () => _openNewClientDialog(context),
//       ),
//     );
//   } // التحكم بزر الرجوع عبر WillPopScope مسموح.

//   Future<void> _openAddSubscriptionDialog(BuildContext context) async {
//     await _openBlockingDialog(
//       context,
//       title: 'إضافة اشتراك',
//       child: _AddSubscriptionForm(
//         onSaved: () => Navigator.of(context).pop(),
//         onClientTap: () => _openAddIssueDialog(context),
//       ),
//     );
//   } // زر X داخل الـ Dialog مخصص أعلى اليمين.

//   Future<void> _openBlockingDialog(
//     BuildContext context, {
//     required String title,
//     required Widget child,
//   }) async {
//     await showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) {
//         return WillPopScope(
//           onWillPop: () async => true,
//           child: Directionality(
//             textDirection: TextDirection.rtl,
//             child: Dialog(
//               insetPadding:
//                   EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24)),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: 720.w),
//                 child: Stack(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             _dialogGrabberAndTitle(title),
//                             SizedBox(height: 8.h),
//                             child,
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: IconButton(
//                         tooltip: 'إغلاق',
//                         onPressed: () => Navigator.of(ctx).pop(),
//                         icon: const Icon(Icons.close,
//                             color: Color.fromARGB(255, 0, 0, 0)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   } // showDialog وDialog يحققان السلوك المطلوب.
// }

// // ============ النماذج ============

// class _NewClientForm extends StatefulWidget {
//   const _NewClientForm({required this.onSaved});
//   final VoidCallback onSaved;

//   @override
//   State<_NewClientForm> createState() => _NewClientFormState();
// }

// class _NewClientFormState extends State<_NewClientForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _name = TextEditingController();
//   final _phone = TextEditingController();
//   final _location = TextEditingController();
//   final _engineer = TextEditingController();
//   final _product = TextEditingController();

//   bool _showEngineerDropdown = false;
//   bool _showProductDropdown = false;
//   String? _selectedEngineerId;
//   String? _selectedProductId;

//   @override
//   void initState() {
//     super.initState();
//     context.read<EngineerCubit>().fetchEngineers();
//     context.read<ProductCubit>().fetchProducts();
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     _phone.dispose();
//     _location.dispose();
//     _engineer.dispose();
//     _product.dispose();
//     super.dispose();
//   }

//   void _onSave() {
//     if (_formKey.currentState!.validate()) {
//       final customer = AddCustomerModel(
//         name: _name.text,
//         telephone: _phone.text,
//         engineerId: _selectedEngineerId ?? '',
//         productId: _selectedProductId ?? '',
//         location: _location.text.isNotEmpty ? _location.text : null,
//       );

//       context.read<AddCustomerCubit>().addCustomer(customer);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AddCustomerCubit, AddCustomerState>(
//       listener: (context, state) {
//         if (state.status == AddCustomerStatus.success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('تم إضافة العميل بنجاح')),
//           );
//           widget.onSaved();
//         } else if (state.status == AddCustomerStatus.failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(state.errorMessage ?? 'حدث خطأ أثناء الإضافة')),
//           );
//         }
//       },
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             RowField(label: 'اسم العميل', child: _boxedText(_name)),
//             RowField(
//                 label: 'رقم التواصل',
//                 child: _boxedText(_phone, type: TextInputType.phone)),
//             RowField(label: 'الموقع', child: _boxedText(_location)),
//             RowField(label: 'المهندس', child: _engineerDropdown()),
//             if (_showEngineerDropdown)
//               SizedBox(
//                 height: 200.h, // ارتفاع ثابت للتمرير الداخلي
//                 child: BlocBuilder<EngineerCubit, EngineerState>(
//                   builder: (context, state) {
//                     if (state.status == EngineerStatus.loading) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state.status == EngineerStatus.success) {
//                       return ListView.builder(
//                         itemCount: state.engineers.length,
//                         itemBuilder: (context, index) {
//                           final engineer = state.engineers[index];
//                           return ListTile(
//                             title: Text(engineer.name),
//                             onTap: () {
//                               setState(() {
//                                 _engineer.text = engineer.name;
//                                 _selectedEngineerId = engineer.id;
//                                 _showEngineerDropdown = false;
//                               });
//                             },
//                           );
//                         },
//                       );
//                     } else {
//                       return const Text('خطأ في تحميل المهندسين');
//                     }
//                   },
//                 ),
//               ),
//             RowField(label: 'التخصص', child: _productDropdown()),
//             if (_showProductDropdown)
//               SizedBox(
//                 height: 200.h, // ارتفاع ثابت للتمرير الداخلي
//                 child: BlocBuilder<ProductCubit, ProductState>(
//                   builder: (context, state) {
//                     if (state.status == ProductStatus.loading) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state.status == ProductStatus.success) {
//                       return ListView.builder(
//                         itemCount: state.products.length,
//                         itemBuilder: (context, index) {
//                           final product = state.products[index];
//                           return ListTile(
//                             title: Text(product.name),
//                             onTap: () {
//                               setState(() {
//                                 _product.text = product.name;
//                                 _selectedProductId = product.id;
//                                 _showProductDropdown = false;
//                               });
//                             },
//                           );
//                         },
//                       );
//                     } else {
//                       return const Text('خطأ في تحميل المنتجات');
//                     }
//                   },
//                 ),
//               ),
//             SizedBox(height: 16.h),
//             _saveButton(onPressed: _onSave),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _engineerDropdown() {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _showEngineerDropdown = !_showEngineerDropdown;
//           _showProductDropdown = false;
//         });
//       },
//       child: Container(
//         height: 52,
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: BoxDecoration(
//           color: const Color(0xff104D9D),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Text(
//             _engineer.text.isEmpty ? 'اختر المهندس' : _engineer.text,
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _productDropdown() {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _showProductDropdown = !_showProductDropdown;
//           _showEngineerDropdown = false;
//         });
//       },
//       child: Container(
//         height: 52,
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: BoxDecoration(
//           color: const Color(0xff104D9D),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Text(
//             _product.text.isEmpty ? 'اختر التخصص' : _product.text,
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AddIssueForm extends StatefulWidget {
//   const _AddIssueForm({
//     required this.onSaved,
//     this.onClientTap,
//   });
//   final VoidCallback onSaved;
//   final VoidCallback? onClientTap;

//   @override
//   State<_AddIssueForm> createState() => _AddIssueFormState();
// }

// class _AddIssueFormState extends State<_AddIssueForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _clientNameController = TextEditingController();
//   final _problemTypeController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   final _directionController = TextEditingController();
//   final _detailsController = TextEditingController();
//   final _statusController = TextEditingController();

//   static const Color primaryColor = Color(0xff104D9D);

//   CustomerModel? _selectedCustomer;
//   final List<File> _selectedImages = [];
//   ProblemStatusModel? _selectedStatus;
//   ProblemCategoryModel? _selectedCategory;
//   EngineerModel? _selectedEngineer;

//   bool _isClientDropdownVisible = false;
//   bool _isTypeDropdownVisible = false;
//   bool _isDirectionDropdownVisible = false;
//   bool _isStatusDropdownVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     context.read<CustomerCubit>().fetchCustomers();
//     context.read<CustomerCubit>().fetchProblemCategories();
//     context.read<CustomerCubit>().fetchProblemStatus();
//     context.read<EngineerCubit>().fetchEngineers();
//     _clientNameController.addListener(_onClientNameChanged);
//   }

//   void _onClientNameChanged() {
//     final query = _clientNameController.text;
//     if (query.isNotEmpty) {
//       context.read<CustomerCubit>().searchCustomers(query);
//       setState(() => _isClientDropdownVisible = true);
//     } else {
//       setState(() {
//         _isClientDropdownVisible = false;
//         _selectedCustomer = null;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _clientNameController.removeListener(_onClientNameChanged);
//     _clientNameController.dispose();
//     _problemTypeController.dispose();
//     _phoneNumberController.dispose();
//     _directionController.dispose();
//     _detailsController.dispose();
//     _statusController.dispose();
//     super.dispose();
//   }

//   void _onCustomerSelected(CustomerModel customer) {
//     setState(() {
//       _selectedCustomer = customer;
//       _clientNameController.text = customer.name ?? '';
//       _phoneNumberController.text = customer.phone ?? '';
//       _isClientDropdownVisible = false;
//     });
//   }

//   void _onImagePicked(File image) {
//     setState(() {
//       _selectedImages.add(image);
//     });
//   }

//   void _onImageRemoved(File image) {
//     setState(() {
//       _selectedImages.remove(image);
//     });
//   }

//   void _onSave() {
//     if (_selectedCustomer == null ||
//         _problemTypeController.text.isEmpty ||
//         _phoneNumberController.text.isEmpty ||
//         _directionController.text.isEmpty ||
//         _selectedStatus == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
//       );
//       return;
//     }

//     bool hasValidImages = true;
//     for (var image in _selectedImages) {
//       if (!image.existsSync() || image.lengthSync() == 0) {
//         hasValidImages = false;
//         print('Invalid image: ${image.path}');
//       }
//     }
//     if (!hasValidImages) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم اختيار صورة غير صالحة')),
//       );
//       return;
//     }

//     final customerState = context.read<CustomerCubit>().state;
//     final engineerState = context.read<EngineerCubit>().state;

//     final selectedCategory = customerState.problemCategories.firstWhere(
//       (c) => c.name == _problemTypeController.text,
//       orElse: () => ProblemCategoryModel(id: '', name: ''),
//     );

//     if (selectedCategory.id.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('فئة المشكلة غير صالحة')),
//       );
//       return;
//     }

//     final selectedEngineer = engineerState.engineers.firstWhere(
//       (e) => e.name == _directionController.text,
//       orElse: () => EngineerModel(id: '', name: '', address: '', telephone: ''),
//     );

//     if (_selectedCustomer!.id == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('معرف العميل غير متاح')),
//       );
//       return;
//     }

//     if (!RegExp(
//             r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
//         .hasMatch(_selectedCustomer!.id!)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('معرف العميل غير صالح')),
//       );
//       return;
//     }
//     if (!RegExp(
//             r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
//         .hasMatch(selectedCategory.id)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('معرف فئة المشكلة غير صالح')),
//       );
//       return;
//     }
//     if (selectedEngineer.id.isNotEmpty &&
//         !RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
//             .hasMatch(selectedEngineer.id)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('معرف المهندس غير صالح')),
//       );
//       return;
//     }

//     context.read<CustomerCubit>().createProblem(
//           customerId: _selectedCustomer!.id!,
//           dateTime: DateTime.now(),
//           problemStatusId: _selectedStatus!.id,
//           problemCategoryId: selectedCategory.id,
//           note: _detailsController.text.isNotEmpty
//               ? _detailsController.text
//               : null,
//           engineerId:
//               selectedEngineer.id.isNotEmpty ? selectedEngineer.id : null,
//           details: _detailsController.text.isNotEmpty
//               ? _detailsController.text
//               : null,
//           phone: _phoneNumberController.text,
//           images: _selectedImages.isNotEmpty ? _selectedImages : null,
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CustomerCubit, CustomerState>(
//       listener: (context, state) {
//         if (state.status == CustomerStatus.success && state.isProblemAdded) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('تم إضافة المشكلة بنجاح')),
//           );
//           widget.onSaved();
//         } else if (state.status == CustomerStatus.failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(state.errorMessage ?? 'حدث خطأ أثناء الإضافة')),
//           );
//         }
//       },
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             RowField(
//               label: 'اسم العميل',
//               child: ClientNameField(
//                 controller: _clientNameController,
//                 isDropdownVisible: _isClientDropdownVisible,
//                 onToggleDropdown: () {
//                   setState(() {
//                     _isClientDropdownVisible = !_isClientDropdownVisible;
//                     if (_isClientDropdownVisible) {
//                       context.read<CustomerCubit>().fetchCustomers();
//                     }
//                   });
//                 },
//                 onCustomerSelected: _onCustomerSelected,
//               ),
//             ),
//             RowField(
//               label: 'رقم التواصل',
//               child:
//                   _boxedText(_phoneNumberController, type: TextInputType.phone),
//             ),
//             RowField(
//               label: 'نوع المشكلة',
//               child: ProblemTypeDropdown(
//                 controller: _problemTypeController,
//                 isDropdownVisible: _isTypeDropdownVisible,
//                 onToggleDropdown: () {
//                   setState(() {
//                     _isTypeDropdownVisible = !_isTypeDropdownVisible;
//                   });
//                 },
//               ),
//             ),
//             RowField(
//               label: 'توجيه إلى',
//               child: DirectionDropdown(
//                 controller: _directionController,
//                 isDropdownVisible: _isDirectionDropdownVisible,
//                 onToggleDropdown: () {
//                   setState(() {
//                     _isDirectionDropdownVisible = !_isDirectionDropdownVisible;
//                   });
//                 },
//               ),
//             ),
//             RowField(
//               label: 'حالة المشكلة',
//               child: StatusDropdown(
//                 controller: _statusController,
//                 isDropdownVisible: _isStatusDropdownVisible,
//                 onToggleDropdown: () {
//                   setState(() {
//                     _isStatusDropdownVisible = !_isStatusDropdownVisible;
//                   });
//                 },
//                 onStatusSelected: (status) {
//                   setState(() {
//                     _selectedStatus = status;
//                   });
//                 },
//               ),
//             ),
//             RowField(
//               label: 'التفاصيل',
//               child: _boxedMultiline(_detailsController),
//             ),
//             RowField(
//               label: 'الصور',
//               child: ImagePickerWidget(
//                 onImagePicked: _onImagePicked,
//               ),
//             ),
//             if (_selectedImages.isNotEmpty)
//               SizedBox(
//                 height: 100.h,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _selectedImages.length,
//                   itemBuilder: (context, index) {
//                     final image = _selectedImages[index];
//                     return Padding(
//                       padding: EdgeInsets.all(8.w),
//                       child: Stack(
//                         children: [
//                           Image.file(
//                             image,
//                             width: 80.w,
//                             height: 80.h,
//                             fit: BoxFit.cover,
//                           ),
//                           Positioned(
//                             top: 0,
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: () => _onImageRemoved(image),
//                               child: const Icon(
//                                 Icons.remove_circle,
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             SizedBox(height: 16.h),
//             _saveButton(onPressed: _onSave),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ClientNameField extends StatelessWidget {
//   final TextEditingController controller;
//   final bool isDropdownVisible;
//   final VoidCallback onToggleDropdown;
//   final Function(CustomerModel) onCustomerSelected;

//   const ClientNameField({
//     super.key,
//     required this.controller,
//     required this.isDropdownVisible,
//     required this.onToggleDropdown,
//     required this.onCustomerSelected,
//   });

//   static const Color primaryColor = Color(0xff104D9D);

//   InputDecoration _buildDropdownDecoration({
//     required String hint,
//     required VoidCallback onIconTap,
//     required String iconAsset,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.white70, fontSize: 16),
//       suffixIcon: GestureDetector(
//         onTap: onIconTap,
//         child: Padding(
//           padding: const EdgeInsets.only(right: 15.0, left: 19),
//           child: Image.asset(iconAsset, width: 24, height: 24),
//         ),
//       ),
//       filled: true,
//       fillColor: primaryColor,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CustomerCubit, CustomerState>(
//       builder: (context, state) {
//         final filteredCustomers = state.customers;
//         return Column(
//           children: [
//             TextField(
//               controller: controller,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.white),
//               decoration: _buildDropdownDecoration(
//                 hint: 'اسم العميل',
//                 iconAsset: 'assets/images/pngs/dropdown.png',
//                 onIconTap: onToggleDropdown,
//               ),
//             ),
//             if (isDropdownVisible && filteredCustomers.isNotEmpty)
//               Container(
//                 margin: const EdgeInsets.only(top: 8),
//                 constraints: const BoxConstraints(maxHeight: 300),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: primaryColor, width: 1.5),
//                 ),
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   physics: const ClampingScrollPhysics(),
//                   itemCount: filteredCustomers.length,
//                   itemBuilder: (ctx, idx) {
//                     final customer = filteredCustomers[idx];
//                     return ListTile(
//                       title: Text(customer.name ?? ''),
//                       onTap: () => onCustomerSelected(customer),
//                     );
//                   },
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// class ProblemTypeDropdown extends StatelessWidget {
//   final TextEditingController controller;
//   final bool isDropdownVisible;
//   final VoidCallback onToggleDropdown;

//   const ProblemTypeDropdown({
//     super.key,
//     required this.controller,
//     required this.isDropdownVisible,
//     required this.onToggleDropdown,
//   });

//   static const Color primaryColor = Color(0xff104D9D);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onToggleDropdown,
//           child: Container(
//             decoration: BoxDecoration(
//               color: primaryColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     controller.text.isEmpty ? 'نوع المشكلة' : controller.text,
//                     style: TextStyle(
//                       color: controller.text.isEmpty
//                           ? Colors.white70
//                           : Colors.white,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/pngs/dropdown.png',
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
//             child: BlocBuilder<CustomerCubit, CustomerState>(
//               builder: (context, state) {
//                 if (state.status == CustomerStatus.loading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state.status == CustomerStatus.failure) {
//                   return Column(
//                     children: [
//                       const Text('فشل في جلب فئات المشكلة'),
//                       TextButton(
//                         onPressed: () {
//                           context
//                               .read<CustomerCubit>()
//                               .fetchProblemCategories();
//                         },
//                         child: const Text('إعادة المحاولة'),
//                       ),
//                     ],
//                   );
//                 } else if (state.problemCategories.isNotEmpty) {
//                   return ListView(
//                     shrinkWrap: true,
//                     physics: const ClampingScrollPhysics(),
//                     children: state.problemCategories.map((category) {
//                       return ListTile(
//                         title: Text(category.name),
//                         onTap: () {
//                           controller.text = category.name;
//                           onToggleDropdown();
//                         },
//                       );
//                     }).toList(),
//                   );
//                 } else {
//                   return Column(
//                     children: [
//                       const Text('لا توجد فئات متاحة'),
//                       TextButton(
//                         onPressed: () {
//                           context
//                               .read<CustomerCubit>()
//                               .fetchProblemCategories();
//                         },
//                         child: const Text('إعادة المحاولة'),
//                       ),
//                     ],
//                   );
//                 }
//               },
//             ),
//           ),
//       ],
//     );
//   }
// }

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

//   static const Color primaryColor = Color(0xff104D9D);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onToggleDropdown,
//           child: Container(
//             decoration: BoxDecoration(
//               color: primaryColor,
//               borderRadius: BorderRadius.circular(12),
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
//                           ? Colors.white70
//                           : Colors.white,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/pngs/dropdown.png',
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

// class StatusDropdown extends StatelessWidget {
//   final TextEditingController controller;
//   final bool isDropdownVisible;
//   final VoidCallback onToggleDropdown;
//   final Function(ProblemStatusModel) onStatusSelected;

//   const StatusDropdown({
//     super.key,
//     required this.controller,
//     required this.isDropdownVisible,
//     required this.onToggleDropdown,
//     required this.onStatusSelected,
//   });

//   static const Color primaryColor = Color(0xff104D9D);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onToggleDropdown,
//           child: Container(
//             decoration: BoxDecoration(
//               color: primaryColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     controller.text.isEmpty ? 'حالة المشكلة' : controller.text,
//                     style: TextStyle(
//                       color: controller.text.isEmpty
//                           ? Colors.white70
//                           : Colors.white,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/pngs/dropdown.png',
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
//             child: BlocBuilder<CustomerCubit, CustomerState>(
//               builder: (context, state) {
//                 if (state.status == CustomerStatus.loading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state.status == CustomerStatus.failure) {
//                   return Column(
//                     children: [
//                       const Text('فشل في جلب حالات المشكلة'),
//                       TextButton(
//                         onPressed: () {
//                           context.read<CustomerCubit>().fetchProblemStatus();
//                         },
//                         child: const Text('إعادة المحاولة'),
//                       ),
//                     ],
//                   );
//                 } else if (state.problemStatusList.isNotEmpty) {
//                   return ListView(
//                     shrinkWrap: true,
//                     physics: const ClampingScrollPhysics(),
//                     children: state.problemStatusList.map((status) {
//                       return ListTile(
//                         title: Text(status.name),
//                         onTap: () {
//                           controller.text = status.name;
//                           onStatusSelected(status);
//                           onToggleDropdown();
//                         },
//                       );
//                     }).toList(),
//                   );
//                 } else {
//                   return Column(
//                     children: [
//                       const Text('لا توجد حالات متاحة'),
//                       TextButton(
//                         onPressed: () {
//                           context.read<CustomerCubit>().fetchProblemStatus();
//                         },
//                         child: const Text('إعادة المحاولة'),
//                       ),
//                     ],
//                   );
//                 }
//               },
//             ),
//           ),
//       ],
//     );
//   }
// }

// class ImagePickerWidget extends StatelessWidget {
//   final Function(File) onImagePicked;

//   const ImagePickerWidget({
//     super.key,
//     required this.onImagePicked,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           builder: (_) => ImagePickerBottomSheet(
//             onImagePicked: onImagePicked,
//           ),
//         );
//       },
//       child: Image.asset(
//         'assets/images/pngs/upload_pic.png',
//         width: 100,
//         height: 100,
//       ),
//     );
//   }
// }

// class ImagePickerBottomSheet extends StatelessWidget {
//   final Function(File) onImagePicked;

//   const ImagePickerBottomSheet({
//     super.key,
//     required this.onImagePicked,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Wrap(
//         children: [
//           ListTile(
//             leading: const Icon(Icons.camera_alt),
//             title: const Text('الكاميرا'),
//             onTap: () async {
//               final picker = ImagePicker();
//               final pickedFile =
//                   await picker.pickImage(source: ImageSource.camera);
//               if (pickedFile != null && pickedFile.path.isNotEmpty) {
//                 onImagePicked(File(pickedFile.path));
//                 Navigator.of(context).pop();
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('فشل في اختيار الصورة')),
//                 );
//               }
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.photo),
//             title: const Text('المعرض'),
//             onTap: () async {
//               final picker = ImagePicker();
//               final pickedFile =
//                   await picker.pickImage(source: ImageSource.gallery);
//               if (pickedFile != null && pickedFile.path.isNotEmpty) {
//                 onImagePicked(File(pickedFile.path));
//                 Navigator.of(context).pop();
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('فشل في اختيار الصورة')),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AddSubscriptionForm extends StatefulWidget {
//   final VoidCallback onSaved;
//   final VoidCallback? onClientTap;

//   const _AddSubscriptionForm({required this.onSaved, this.onClientTap});

//   @override
//   State<_AddSubscriptionForm> createState() => _AddSubscriptionFormState();
// }

// class _AddSubscriptionFormState extends State<_AddSubscriptionForm> {
//   final _formKey = GlobalKey<FormState>();

//   final _clientController = TextEditingController();
//   final _amountController = TextEditingController();
//   final _notesController = TextEditingController();
//   final _paymentMethodController = TextEditingController();

//   DateTime? _contractDate;
//   DateTime? _startDate;
//   DateTime? _endDate;

//   String? _selectedCustomerId;
//   String? _selectedPaymentMethodId;

//   final List<String> _imagePaths = [];
//   final ImagePicker _picker = ImagePicker();

//   late AddSubscriptionCubit _cubit;

//   @override
//   void initState() {
//     super.initState();
//     _cubit = context.read<AddSubscriptionCubit>();
//     _contractDate = DateTime.now();
//     _startDate = DateTime.now();
//     _endDate = DateTime.now().add(const Duration(days: 365));
//   }

//   Future<void> _pickDate(
//       ValueSetter<DateTime> setter, DateTime? current) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: current ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(primary: Color(0xFF20AAC9)),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setter(picked);
//       setState(() {});
//     }
//   }

//   Future<void> _pickImage() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('معرض الصور'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final file =
//                     await _picker.pickImage(source: ImageSource.gallery);
//                 if (file != null) {
//                   setState(() => _imagePaths.add(file.path));
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('الكاميرا'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final file =
//                     await _picker.pickImage(source: ImageSource.camera);
//                 if (file != null) {
//                   setState(() => _imagePaths.add(file.path));
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<List<MultipartFile>?> _prepareImages() async {
//     if (_imagePaths.isEmpty) return null;
//     return Future.wait(_imagePaths.map((path) => MultipartFile.fromFile(path)));
//   }

//   void _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedCustomerId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('يرجى اختيار العميل')),
//       );
//       return;
//     }

//     final images = await _prepareImages();

//     final model = AddSubscriptionModel(
//       customerId: _selectedCustomerId!,
//       contractDate: _contractDate!,
//       startDate: _startDate!,
//       endDate: _endDate!,
//       cost: double.tryParse(_amountController.text) ?? 0.0,
//       payment: double.tryParse(_amountController.text) ?? 0.0,
//       payMethodId: _selectedPaymentMethodId ?? '',
//       notes: _notesController.text.isNotEmpty ? _notesController.text : null,
//       file: images,
//     );

//     _cubit.addSubscription(model);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AddSubscriptionCubit, AddSubscriptionState>(
//       listener: (context, state) {
//         if (state.status == AddSubscriptionStatus.success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('تم إضافة الاشتراك بنجاح')),
//           );
//           widget.onSaved();
//         } else if (state.status == AddSubscriptionStatus.failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(state.errorMessage ?? 'فشل في إضافة الاشتراك')),
//           );
//         }
//       },
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // العميل (بحث + اختيار)
//             RowField(
//               label: 'العميل',
//               child: ClientSearchField(
//                 onCustomerSelected: (customer) {
//                   _selectedCustomerId = customer.id;
//                   _clientController.text = customer.name ?? '';
//                 },
//               ),
//             ),

//             // تاريخ العقد
//             RowField(
//               label: 'تاريخ العقد',
//               child: _dateBox(
//                 value: _contractDate == null
//                     ? 'اختر التاريخ'
//                     : '${_contractDate!.year}/${_contractDate!.month.toString().padLeft(2, '0')}/${_contractDate!.day.toString().padLeft(2, '0')}',
//                 onTap: () => _pickDate((d) => _contractDate = d, _contractDate),
//               ),
//             ),

//             // بداية الاشتراك
//             RowField(
//               label: 'بداية الاشتراك',
//               child: _dateBox(
//                 value: _startDate == null
//                     ? 'اختر التاريخ'
//                     : '${_startDate!.year}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.day.toString().padLeft(2, '0')}',
//                 onTap: () => _pickDate((d) => _startDate = d, _startDate),
//               ),
//             ),

//             // نهاية الاشتراك
//             RowField(
//               label: 'نهاية الاشتراك',
//               child: _dateBox(
//                 value: _endDate == null
//                     ? 'اختر التاريخ'
//                     : '${_endDate!.year}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.day.toString().padLeft(2, '0')}',
//                 onTap: () => _pickDate((d) => _endDate = d, _endDate),
//               ),
//             ),

//             // المبلغ
//             RowField(
//               label: 'المبلغ',
//               child: _boxedText(_amountController, type: TextInputType.number),
//             ),

//             // طريقة الدفع (قابلة للتوسيع لاحقًا)
//             RowField(
//               label: 'طريقة الدفع',
//               child: PaymentMethodDropdown(
//                 controller: _paymentMethodController,
//                 onMethodSelected: (method) {
//                   setState(() {
//                     _selectedPaymentMethodId = method.id;
//                     _paymentMethodController.text = method.name;
//                   });
//                 },
//               ),
//             ),
//             // ملاحظات
//             RowField(
//               label: 'ملاحظات',
//               child: _boxedMultiline(_notesController),
//             ),

//             // رفع الملفات
//             RowField(
//               label: 'الملفات',
//               child: _imagesUploadSection(),
//             ),

//             SizedBox(height: 20.h),

//             // زر الحفظ
//             BlocBuilder<AddSubscriptionCubit, AddSubscriptionState>(
//               builder: (context, state) {
//                 return _saveButton(
//                   onPressed: state.status == AddSubscriptionStatus.loading
//                       ? null
//                       : _submit,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _imagesUploadSection() {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: _pickImage,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Image.asset('assets/images/pngs/pictures_folder.png',
//                   width: 90.w, height: 90.h),
//               if (_imagePaths.isNotEmpty)
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: CircleAvatar(
//                     radius: 12,
//                     backgroundColor: Colors.red,
//                     child: Text(_imagePaths.length.toString(),
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 12)),
//                   ),
//                 ),
//               const Text('+',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//         if (_imagePaths.isNotEmpty)
//           SizedBox(
//             height: 100.h,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _imagePaths.length,
//               itemBuilder: (_, i) => Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: Stack(
//                   children: [
//                     Image.file(File(_imagePaths[i]),
//                         width: 80.w, height: 80.h, fit: BoxFit.cover),
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: GestureDetector(
//                         onTap: () => setState(() => _imagePaths.removeAt(i)),
//                         child:
//                             const Icon(Icons.remove_circle, color: Colors.red),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class PaymentMethodDropdown extends StatelessWidget {
//   final TextEditingController controller;
//   final Function(PaymentMethodModel) onMethodSelected;

//   const PaymentMethodDropdown({
//     super.key,
//     required this.controller,
//     required this.onMethodSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // عند الضغط على الحقل نجلب البيانات
//     return GestureDetector(
//       onTap: () {
//         context.read<PaymentMethodCubit>().fetchPaymentMethods();
//       },
//       child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
//         builder: (context, state) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // الحقل الرئيسي
//               Container(
//                 height: 52,
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xff104D9D),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         controller.text.isEmpty
//                             ? 'اختر طريقة الدفع'
//                             : controller.text,
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ),
//                     const Icon(Icons.arrow_drop_down, color: Colors.white),
//                   ],
//                 ),
//               ),

//               // حالة التحميل
//               if (state.status == PaymentMethodStatus.loading)
//                 const Padding(
//                   padding: EdgeInsets.only(top: 8),
//                   child: SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                         strokeWidth: 2, color: Colors.white),
//                   ),
//                 ),

//               // عرض القائمة عند النجاح
//               if (state.status == PaymentMethodStatus.success &&
//                   state.paymentMethods.isNotEmpty)
//                 Container(
//                   margin: const EdgeInsets.only(top: 8),
//                   constraints: const BoxConstraints(maxHeight: 250),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border:
//                         Border.all(color: const Color(0xff104D9D), width: 1.5),
//                     boxShadow: const [
//                       BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 6,
//                           offset: Offset(0, 3))
//                     ],
//                   ),
//                   child: ListView.builder(
//                     padding: EdgeInsets.zero,
//                     shrinkWrap: true,
//                     itemCount: state.paymentMethods.length,
//                     itemBuilder: (ctx, index) {
//                       final method = state.paymentMethods[index];
//                       return ListTile(
//                         dense: true,
//                         title: Text(method.name),
//                         onTap: () {
//                           onMethodSelected(method);
//                         },
//                       );
//                     },
//                   ),
//                 ),

//               // رسالة خطأ
//               if (state.status == PaymentMethodStatus.failure)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Text(
//                     'فشل في جلب طرق الدفع',
//                     style: TextStyle(color: Colors.red[300], fontSize: 13),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// } // ============ عناصر واجهة مشتركة (صف تسمية + حقل) ============

// class ClientSearchField extends StatelessWidget {
//   final Function(CustomerModel) onCustomerSelected;

//   const ClientSearchField({super.key, required this.onCustomerSelected});

//   @override
//   Widget build(BuildContext context) {
//     final controller = TextEditingController();
//     bool showDropdown = false;

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Column(
//           children: [
//             TextField(
//               controller: controller,
//               onChanged: (q) {
//                 if (q.isNotEmpty) {
//                   context.read<CustomerCubit>().searchCustomers(q);
//                   setState(() => showDropdown = true);
//                 } else {
//                   setState(() => showDropdown = false);
//                 }
//               },
//               decoration: InputDecoration(
//                 hintText: 'ابحث عن العميل',
//                 filled: true,
//                 fillColor: const Color(0xFF104D9D),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none),
//                 suffixIcon: const Icon(Icons.search, color: Colors.white),
//               ),
//               style: const TextStyle(color: Colors.white),
//             ),
//             if (showDropdown)
//               Container(
//                 margin: const EdgeInsets.only(top: 8),
//                 constraints: const BoxConstraints(maxHeight: 300),
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12)),
//                 child: BlocBuilder<CustomerCubit, CustomerState>(
//                   builder: (context, state) {
//                     if (state.customers.isEmpty)
//                       return const Text('لا يوجد عملاء');
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: state.customers.length,
//                       itemBuilder: (_, i) {
//                         final c = state.customers[i];
//                         return ListTile(
//                           title: Text(c.name ?? ''),
//                           subtitle: Text(c.phone ?? ''),
//                           onTap: () {
//                             onCustomerSelected(c);
//                             controller.text = c.name ?? '';
//                             setState(() => showDropdown = false);
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// class RowField extends StatelessWidget {
//   const RowField({
//     super.key,
//     required this.label,
//     required this.child,
//   });

//   final String label;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 110, // عرض ثابت للنص مثل الصور
//             child: Text(label,
//                 style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
//           ),
//           Expanded(child: child),
//         ],
//       ),
//     );
//   }
// } // استخدام تخطيط صف لمحاذاة التسمية بجوار الحقل كما توصي أدلة التخطيط.

// Widget _boxedText(TextEditingController c,
//     {TextInputType type = TextInputType.text}) {
//   return Container(
//     decoration: BoxDecoration(
//       color: const Color(0xff104D9D),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: TextFormField(
//       controller: c,
//       keyboardType: type,
//       style: const TextStyle(color: Colors.white),
//       decoration: const InputDecoration(
//         border: InputBorder.none,
//         contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         hintStyle: TextStyle(color: Colors.white70),
//       ),
//       validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
//     ),
//   );
// } // حقل نصي مطابق مع خامة ولون.

// Widget _boxedMultiline(TextEditingController c) {
//   return Container(
//     height: 100.h, // ارتفاع محدد للتوافق مع التصميم
//     decoration: BoxDecoration(
//       color: const Color(0xff104D9D),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: TextFormField(
//       controller: c,
//       maxLines: null,
//       expands: true,
//       style: const TextStyle(color: Colors.white),
//       decoration: const InputDecoration(
//         border: InputBorder.none,
//         contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         hintStyle: TextStyle(color: Colors.white70),
//       ),
//       validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
//     ),
//   );
// } // متعدد الأسطر بنفس النمط.

// Widget _dropdownBox(TextEditingController c) {
//   return Container(
//     height: 52,
//     padding: const EdgeInsets.symmetric(horizontal: 14),
//     decoration: BoxDecoration(
//       color: Colors.orange, // تغيير اللون إلى برتقالي
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Center(
//       child: TextFormField(
//         controller: c,
//         readOnly: true,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           hintText: 'اختر',
//           hintStyle: const TextStyle(color: Colors.white70),
//           isCollapsed: true,
//           suffixIcon: Padding(
//             padding: const EdgeInsetsDirectional.only(end: 6),
//             child: ColorFiltered(
//               colorFilter:
//                   const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//               child: Image.asset(
//                 'assets/images/pngs/dropdown.png',
//                 width: 10,
//                 height: 14,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ),
//         validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
//         onTap: () {
//           // TODO: فتح قائمة اختيار
//         },
//       ),
//     ),
//   );
// } // suffixIcon مخصص وفق InputDecoration API.

// Widget _dateBox({
//   required String value,
//   required VoidCallback onTap,
//   IconData icon = Icons.calendar_month,
// }) {
//   return InkWell(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xff104D9D),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(width: 8),
//           Expanded(
//               child: Text(value, style: const TextStyle(color: Colors.white))),
//         ],
//       ),
//     ),
//   );
// } // عنصر تاريخ/وقت بنفس مظهر الحقول في صف واحد.

// Widget _dialogGrabberAndTitle(String title) {
//   return Column(
//     children: [
//       Container(
//         width: 50,
//         height: 5,
//         margin: const EdgeInsets.only(top: 6, bottom: 10),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE0E0E0),
//           borderRadius: BorderRadius.circular(3),
//         ),
//       ),
//       Text(
//         title,
//         style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF0F5FA8)),
//       ),
//     ],
//   );
// } // عنوان الحوار.

// Widget _saveButton({VoidCallback? onPressed}) {
//   return SizedBox(
//     width: double.infinity,
//     height: 48,
//     child: ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor:
//             onPressed != null ? const Color(0xFF20AAC9) : Colors.grey,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: const Text('حفظ',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//     ),
//   );
// } // زر الحفظ يغلق عبر onSaved.

// // ===== Dialog لاختيار التاريخ مع تأكيد/إلغاء =====
// class _DatePickerDialog extends StatefulWidget {
//   const _DatePickerDialog({required this.initialDate, required this.onConfirm});
//   final DateTime initialDate;
//   final ValueChanged<DateTime> onConfirm;

//   @override
//   State<_DatePickerDialog> createState() => _DatePickerDialogState();
// }

// class _DatePickerDialogState extends State<_DatePickerDialog> {
//   late DateTime _temp = widget.initialDate;

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       backgroundColor: const Color(0xFF104D9D),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: SizedBox(
//           width: 360,
//           child: Theme(
//             data: ThemeData.dark(),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 12),
//                 const Text('اختر التاريخ',
//                     style: TextStyle(
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         fontSize: 18)),
//                 const Divider(height: 20, color: Colors.white70),
//                 Theme(
//                   data: ThemeData.dark(),
//                   child: CalendarDatePicker(
//                     initialDate: _temp,
//                     firstDate: DateTime(_temp.year - 5),
//                     lastDate: DateTime(_temp.year + 5),
//                     onDateChanged: (d) => setState(() => _temp = d),
//                   ),
//                 ),
//                 const Divider(height: 20, color: Colors.white70),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.white),
//                           onPressed: () => Navigator.of(context).pop(),
//                           child: const Text('إلغاء'),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF20AAC9),
//                             foregroundColor: Colors.white,
//                           ),
//                           onPressed: () => widget.onConfirm(_temp),
//                           child: const Text('تأكيد'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// } // حوار تاريخ مخصص يعمل ضمن showDialog.
