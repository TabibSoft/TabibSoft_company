import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/add_customer_bottom_sheet.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/add_problem_dialog.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/customer_list_widget.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/image_picker_sheet.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/search_bar_widget.dart';

class TechnicalSupportScreen extends StatefulWidget {
  const TechnicalSupportScreen({super.key});

  @override
  State<TechnicalSupportScreen> createState() => _TechnicalSupportScreenState();
}

class _TechnicalSupportScreenState extends State<TechnicalSupportScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _field1Controller = TextEditingController();
  final TextEditingController _field2Controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? savedField1;
  String? savedField2;
  List<String> savedImageUrls = [];
  String _searchQuery = '';

  static const Color primaryColor = Color(0xFF56C7F1);
  static const Color secondaryColor = Color(0xFF75D6A9);

  final List<String> imageUrls = [
    'assets/images/pngs/tabibLogo.png',
    'assets/images/pngs/tabibLogo.png',
    'assets/images/pngs/tabibLogo.png',
    'assets/images/pngs/tabibLogo.png',
    'assets/images/pngs/tabibLogo.png',
    'assets/images/pngs/tabibLogo.png',
  ];

  final List<String> _selectedImageUrls = [];

  @override
  void initState() {
    super.initState();
    final token = CacheHelper.getString(key: 'loginToken');
    print('Token in TechnicalSupportScreen: $token');
    if (token.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      context.read<CustomerCubit>().fetchTechSupportIssues(); // تغيير إلى fetchTechSupportIssues
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImagePickerBottomSheet(
        imageUrls: imageUrls,
        selectedImageUrls: _selectedImageUrls,
      ),
    );
  }

  void _showAddCustomerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddCustomerBottomSheet(),
    );
  }

  void _showAddProblemDialog() {
    _selectedImageUrls.clear(); // Reset selection for new dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddProblemDialog(
        field1Controller: _field1Controller,
        field2Controller: _field2Controller,
        selectedImageUrls: _selectedImageUrls,
        onSave: () {
          if (_field1Controller.text.isNotEmpty ||
              _field2Controller.text.isNotEmpty ||
              _selectedImageUrls.isNotEmpty) {
            setState(() {
              savedField1 = _field1Controller.text;
              savedField2 = _field2Controller.text;
              savedImageUrls = List.from(_selectedImageUrls);
            });
            _field1Controller.clear();
            _field2Controller.clear();
            _selectedImageUrls.clear();
            Navigator.of(context).pop();
          }
        },
        onShowImagePicker: _showImagePickerBottomSheet,
        primaryColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const navBarHeight = 60.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'الدعم الفني',
                height: 480,
                leading: IconButton(
                  icon: Image.asset(
                    'assets/images/pngs/back.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showAddCustomerBottomSheet,
                          child: Image.asset(
                            'assets/images/pngs/plus.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // Add your action here
                          },
                          child: Image.asset(
                            'assets/images/pngs/filter.png', // Replace with your icon
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              top: 0,
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * 0.33,
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor,
                          width: 3.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SearchBarWidget(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                            CustomerListWidget(searchQuery: _searchQuery),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.25,
                    left: size.width * 0.20,
                    right: size.width * 0.20,
                    child: InkWell(
                      onTap: _showAddProblemDialog, // استدعاء الديالوغ بدلاً من الانتقال
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: primaryColor,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'حالة مشكلة',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 25),
                            Image.asset(
                              'assets/images/pngs/filter.png',
                              width: size.width * 0.08,
                              height: size.width * 0.08,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(
          items: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/pngs/push_notification.png',
                width: 35,
                height: 35,
              ),
            ),
            const SizedBox(), // Empty space in the middle
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/pngs/calendar.png',
                width: 35,
                height: 35,
              ),
            ),
          ],
          alignment: MainAxisAlignment.spaceBetween,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    super.dispose();
  }
}