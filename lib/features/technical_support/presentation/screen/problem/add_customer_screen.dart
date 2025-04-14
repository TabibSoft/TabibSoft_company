import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  static const Color primaryColor = Color(0xFF56C7F1);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _engineerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _showEngineerDropdown = false;
  bool _showProgramDropdown = false;

  @override
  void initState() {
    super.initState();
    // fetch lists
    context.read<EngineerCubit>().fetchEngineers();
    context.read<CustomerCubit>().fetchProblemStatus();
  }

  InputDecoration _buildFieldDecoration({
    required String hint,
    required VoidCallback onTapIcon,
    String? iconAsset,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      suffixIcon: GestureDetector(
        onTap: onTapIcon,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: iconAsset != null
              ? Image.asset(iconAsset, width: 24, height: 24)
              : const SizedBox.shrink(),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
    );
  }

  InputDecoration _buildPhoneDecoration() {
    return InputDecoration(
      hintText: 'رقم التواصل',
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      suffixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child:
            Image.asset('assets/images/pngs/phone.png', width: 24, height: 24),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Top curved AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'اضافة عميل',
                height: 343,
                leading: IconButton(
                  icon: Image.asset('assets/images/pngs/back.png',
                      width: 30, height: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Form container
            Positioned(
              top: size.height * 0.23,
              left: size.width * 0.05,
              right: size.width * 0.05,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor, width: 3),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        // Name
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          decoration: _buildFieldDecoration(
                            hint: 'اسم العميل',
                            // iconAsset: 'assets/images/pngs/drop_down.png',
                            onTapIcon: () {
                              // no dropdown here, just focus
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Engineer dropdown
                        TextField(
                          controller: _engineerController,
                          textAlign: TextAlign.center,
                          readOnly: true,
                          decoration: _buildFieldDecoration(
                            hint: 'المهندس',
                            iconAsset: 'assets/images/pngs/drop_down.png',
                            onTapIcon: () {
                              setState(() {
                                _showEngineerDropdown = !_showEngineerDropdown;
                                if (_showEngineerDropdown) {
                                  _showProgramDropdown = false;
                                }
                              });
                            },
                          ),
                        ),
                        if (_showEngineerDropdown)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            constraints: const BoxConstraints(maxHeight: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  Border.all(color: primaryColor, width: 1.5),
                            ),
                            child: BlocBuilder<EngineerCubit, EngineerState>(
                              builder: (context, state) {
                                if (state.status == EngineerStatus.loading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state.status ==
                                    EngineerStatus.success) {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: state.engineers
                                        .map((e) => ListTile(
                                              title: Text(e.name),
                                              onTap: () {
                                                setState(() {
                                                  _engineerController.text =
                                                      e.name;
                                                  _showEngineerDropdown = false;
                                                });
                                              },
                                            ))
                                        .toList(),
                                  );
                                } else {
                                  return const Center(
                                      child: Text('لا توجد مهندسين متاحين'));
                                }
                              },
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Phone
                        TextField(
                          controller: _phoneController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.phone,
                          decoration: _buildPhoneDecoration(),
                        ),
                        const SizedBox(height: 16),

                        // Program / Problem Status dropdown
                        TextField(
                          controller: _programController,
                          textAlign: TextAlign.center,
                          readOnly: true,
                          decoration: _buildFieldDecoration(
                            hint: 'البرنامج',
                            iconAsset: 'assets/images/pngs/drop_down.png',
                            onTapIcon: () {
                              setState(() {
                                _showProgramDropdown = !_showProgramDropdown;
                                if (_showProgramDropdown) {
                                  _showEngineerDropdown = false;
                                }
                              });
                            },
                          ),
                        ),
                        if (_showProgramDropdown)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            constraints: const BoxConstraints(maxHeight: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  Border.all(color: primaryColor, width: 1.5),
                            ),
                            child: BlocBuilder<CustomerCubit, CustomerState>(
                              builder: (context, state) {
                                if (state.status == CustomerStatus.loading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state.problemStatusList.isNotEmpty) {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: state.problemStatusList
                                        .map((s) => ListTile(
                                              title: Text(s.name),
                                              onTap: () {
                                                setState(() {
                                                  _programController.text =
                                                      s.name;
                                                  _showProgramDropdown = false;
                                                });
                                              },
                                            ))
                                        .toList(),
                                  );
                                } else {
                                  return const Center(
                                      child: Text('لا توجد حالات متاحة'));
                                }
                              },
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Location (just a plain field with icon)
                        TextField(
                          controller: _locationController,
                          textAlign: TextAlign.center,
                          decoration: _buildFieldDecoration(
                            hint: 'المكان',
                            iconAsset: 'assets/images/pngs/location.png',
                            onTapIcon: () {
                              // maybe open map picker
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // your save logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'حفظ',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // empty nav bar as per your screenshot
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }
}
