import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/problem/add_customer_screen.dart';

class AddProblemScreen extends StatefulWidget {
  const AddProblemScreen({super.key});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _problemTypeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  static const Color primaryColor = Color(0xFF56C7F1);

  CustomerModel? _selectedCustomer;
  List<CustomerModel> _filteredCustomers = [];
  final List<File> _selectedImages = [];

  bool _isClientDropdownVisible = false;
  bool _isTypeDropdownVisible = false;
  bool _isDirectionDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().fetchCustomers();
    context.read<CustomerCubit>().fetchProblemStatus();
    context.read<EngineerCubit>().fetchEngineers();
    _clientNameController.addListener(_onClientNameChanged);
  }

  void _onClientNameChanged() {
    final query = _clientNameController.text;
    if (query.isNotEmpty) {
      context.read<CustomerCubit>().searchCustomers(query);
      setState(() => _isClientDropdownVisible = true);
    } else {
      setState(() {
        _isClientDropdownVisible = false;
        _selectedCustomer = null;
        _filteredCustomers = [];
      });
    }
  }

  @override
  void dispose() {
    _clientNameController.removeListener(_onClientNameChanged);
    _clientNameController.dispose();
    _problemTypeController.dispose();
    _phoneNumberController.dispose();
    _directionController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && pickedFile.path.isNotEmpty) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في اختيار الصورة')),
      );
    }
  }

  void _onSave() {
    if (_selectedCustomer == null ||
        _problemTypeController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _directionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    // التحقق من صحة الصور
    bool hasValidImages = true;
    for (var image in _selectedImages) {
      if (!image.existsSync() || image.lengthSync() == 0) {
        hasValidImages = false;
        print('Invalid image: ${image.path}');
      }
    }
    if (!hasValidImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم اختيار صورة غير صالحة')),
      );
      return;
    }

    final customerState = context.read<CustomerCubit>().state;
    final engineerState = context.read<EngineerCubit>().state;

    final selectedStatus = customerState.problemStatusList.firstWhere(
      (s) => s.name == _problemTypeController.text,
      orElse: () => ProblemStatusModel(id: 0, name: ''),
    );

    if (selectedStatus.id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حالة المشكلة غير صالحة')),
      );
      return;
    }

    final selectedEngineer = engineerState.engineers.firstWhere(
      (e) => e.name == _directionController.text,
      orElse: () => EngineerModel(id: '', name: '', address: '', telephone: ''),
    );

    if (_selectedCustomer!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('معرف العميل غير متاح')),
      );
      return;
    }

    context.read<CustomerCubit>().createProblem(
          customerId: _selectedCustomer!.id!,
          dateTime: DateTime.now(),
          problemStatusId: selectedStatus.id,
          note: _detailsController.text.isNotEmpty
              ? _detailsController.text
              : null,
          engineerId:
              selectedEngineer.id.isNotEmpty ? selectedEngineer.id : null,
          details: _detailsController.text.isNotEmpty
              ? _detailsController.text
              : null,
          phone: _phoneNumberController.text,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );
  }

  InputDecoration _buildDropdownDecoration({
    required String hint,
    required VoidCallback onIconTap,
    required String iconAsset,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      suffixIcon: GestureDetector(
        onTap: onIconTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 19),
          child: Image.asset(
            iconAsset,
            width: 24,
            height: 24,
          ),
        ),
      ),
      filled: true,
      fillColor: Colors.white,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    );
  }

  InputDecoration _buildPhoneDecoration() {
    return InputDecoration(
      hintText: 'رقم التواصل',
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 19),
        child:
            Image.asset('assets/images/pngs/phone.png', width: 24, height: 24),
      ),
      filled: true,
      fillColor: Colors.white,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocListener<CustomerCubit, CustomerState>(
          listenWhen: (previous, current) =>
              current.isProblemAdded != previous.isProblemAdded ||
              current.status == CustomerStatus.failure,
          listener: (context, state) {
            if (state.isProblemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت إضافة المشكلة بنجاح')),
              );
              _detailsController.clear();
              _clientNameController.clear();
              _problemTypeController.clear();
              _phoneNumberController.clear();
              _directionController.clear();
              setState(() {
                _selectedCustomer = null;
                _isClientDropdownVisible = false;
                _isTypeDropdownVisible = false;
                _isDirectionDropdownVisible = false;
                _selectedImages.clear(); // إعادة تعيين الصور
              });
              Navigator.of(context).pop();
            } else if (state.status == CustomerStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(state.errorMessage ?? 'فشل في إضافة المشكلة')),
              );
            }
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: CustomAppBar(
                  title: 'إضافة مشكلة',
                  height: 343,
                  leading: IconButton(
                    icon: Image.asset('assets/images/pngs/back.png',
                        width: 30, height: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Image.asset('assets/images/pngs/add_customer.png',
                          width: 38, height: 38),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddCustomerScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: size.height * 0.25,
                left: size.width * 0.05,
                right: size.width * 0.05,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(100, 95, 93, 93).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: size.height * 0.7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Client dropdown...
                            BlocBuilder<CustomerCubit, CustomerState>(
                              builder: (context, state) {
                                if (state.status == CustomerStatus.success) {
                                  _filteredCustomers = state.customers;
                                }
                                return Column(
                                  children: [
                                    TextField(
                                      controller: _clientNameController,
                                      textAlign: TextAlign.center,
                                      decoration: _buildDropdownDecoration(
                                        hint: 'اسم العميل',
                                        iconAsset:
                                            'assets/images/pngs/drop_down.png',
                                        onIconTap: () {
                                          setState(() =>
                                              _isClientDropdownVisible =
                                                  !_isClientDropdownVisible);
                                          if (_isClientDropdownVisible &&
                                              _filteredCustomers.isEmpty) {
                                            context
                                                .read<CustomerCubit>()
                                                .fetchCustomers();
                                          }
                                        },
                                      ),
                                    ),
                                    if (_isClientDropdownVisible &&
                                        _filteredCustomers.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        constraints: const BoxConstraints(
                                            maxHeight: 300),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: primaryColor, width: 1.5),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemCount: _filteredCustomers.length,
                                          itemBuilder: (ctx, idx) {
                                            final c = _filteredCustomers[idx];
                                            return ListTile(
                                              title: Text(c.name ?? ''),
                                              onTap: () {
                                                setState(() {
                                                  _selectedCustomer = c;
                                                  _clientNameController.text =
                                                      c.name ?? '';
                                                  _phoneNumberController.text =
                                                      c.phone ?? '';
                                                  _isClientDropdownVisible =
                                                      false;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Problem type dropdown...
                            // Problem type dropdown
                            GestureDetector(
                              onTap: () {
                                setState(() => _isTypeDropdownVisible =
                                    !_isTypeDropdownVisible);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: primaryColor.withOpacity(0.5),
                                      width: 1.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _problemTypeController.text.isEmpty
                                            ? 'نوع المشكلة'
                                            : _problemTypeController.text,
                                        style: TextStyle(
                                          color: _problemTypeController
                                                  .text.isEmpty
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/pngs/drop_down.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isTypeDropdownVisible)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                constraints:
                                    const BoxConstraints(maxHeight: 300),
                                padding: const EdgeInsets.only(
                                    right: 15.0, left: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: primaryColor, width: 1.5),
                                ),
                                child:
                                    BlocBuilder<CustomerCubit, CustomerState>(
                                  builder: (context, state) {
                                    if (state.status ==
                                        CustomerStatus.loading) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (state
                                        .problemStatusList.isNotEmpty) {
                                      return ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children: state.problemStatusList
                                            .map((status) {
                                          return ListTile(
                                            title: Text(status.name),
                                            onTap: () {
                                              setState(() {
                                                _problemTypeController.text =
                                                    status.name;
                                                _isTypeDropdownVisible = false;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      );
                                    } else {
                                      return const Text('لا توجد حالات متاحة');
                                    }
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Phone
                            TextFormField(
                              controller: _phoneNumberController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.phone,
                              decoration: _buildPhoneDecoration(),
                            ),
                            const SizedBox(height: 16),

                            // Engineer dropdown
                            GestureDetector(
                              onTap: () {
                                setState(() => _isDirectionDropdownVisible =
                                    !_isDirectionDropdownVisible);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: primaryColor.withOpacity(0.5),
                                      width: 1.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _directionController.text.isEmpty
                                            ? 'توجيه إلي'
                                            : _directionController.text,
                                        style: TextStyle(
                                          color:
                                              _directionController.text.isEmpty
                                                  ? Colors.grey
                                                  : Colors.black,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/pngs/drop_down.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isDirectionDropdownVisible)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                constraints:
                                    const BoxConstraints(maxHeight: 300),
                                padding: const EdgeInsets.only(
                                    right: 15.0, left: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: primaryColor, width: 1.5),
                                ),
                                child:
                                    BlocBuilder<EngineerCubit, EngineerState>(
                                  builder: (context, state) {
                                    if (state.status ==
                                        EngineerStatus.loading) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (state.engineers.isNotEmpty) {
                                      return ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children:
                                            state.engineers.map((engineer) {
                                          return ListTile(
                                            title: Text(engineer.name),
                                            onTap: () {
                                              setState(() {
                                                _directionController.text =
                                                    engineer.name;
                                                _isDirectionDropdownVisible =
                                                    false;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      );
                                    } else {
                                      return const Text(
                                          'لا توجد مهندسين متاحين');
                                    }
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Details
                            TextFormField(
                              controller: _detailsController,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'تفاصيل',
                                hintStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 16),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: primaryColor.withOpacity(0.5),
                                      width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: primaryColor.withOpacity(0.5),
                                      width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 20),
                              ),
                            ),

                            // Display selected images
                            if (_selectedImages.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedImages.map((image) {
                                  return Stack(
                                    children: [
                                      Image.file(
                                        image,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedImages.remove(image);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],

                            // Upload picture button
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (_) => ImagePickerBottomSheet(
                                    onImagePicked: (file) {
                                      setState(() {
                                        _selectedImages.add(file);
                                      });
                                    },
                                  ),
                                );
                              },
                              child: Image.asset(
                                'assets/images/pngs/upload_pic.png',
                                width: 100,
                                height: 100,
                              ),
                            ),

                            // Save button
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _onSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'حفظ',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
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
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }
}

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(File) onImagePicked;

  const ImagePickerBottomSheet({super.key, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('الكاميرا'),
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null && pickedFile.path.isNotEmpty) {
                onImagePicked(File(pickedFile.path));
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في اختيار الصورة')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('المعرض'),
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null && pickedFile.path.isNotEmpty) {
                onImagePicked(File(pickedFile.path));
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في اختيار الصورة')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
