import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/technical_support/export.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/problem/problem_details_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/new/tech_card_content.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';

class TechnicalSupportScreen extends StatefulWidget {
  const TechnicalSupportScreen({super.key});
  static const double horizontalPadding = 16.0;

  @override
  State<TechnicalSupportScreen> createState() => _TechnicalSupportScreenState();
}

class _TechnicalSupportScreenState extends State<TechnicalSupportScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _doctorPhone = '';
  String _problemLocation = '';
  String? _selectedStatus;
  String? _selectedEngineerName;
  DateTime? _selectedDate;
  List<String?> _statuses = [];

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    final token = CacheHelper.getString(key: 'loginToken');
    if (token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    } else {
      context.read<CustomerCubit>().fetchProblemStatus();
      context.read<EngineerCubit>().fetchEngineers();
      context.read<CustomerCubit>().refreshAllData();
      _animationController.forward();
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    context.read<CustomerCubit>().stream.listen((state) {
      if (state.problemStatusList.isNotEmpty && mounted) {
        setState(() {
          _statuses = [
            null,
            ...state.problemStatusList.map((status) => status.name)
          ];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: TechColors.accentCyan),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: TechColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(icon, color: Colors.grey.shade400, size: 22.r),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 15.sp,
                color: TechColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? TechColors.accentCyan.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? TechColors.accentCyan : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? TechColors.primaryMid : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final TextEditingController localSearchController =
        TextEditingController(text: _searchQuery);
    final TextEditingController localPhoneController =
        TextEditingController(text: _doctorPhone);
    final TextEditingController localLocationController =
        TextEditingController(text: _problemLocation);
    String? localSelectedStatus = _selectedStatus;
    String? localSelectedEngineerName = _selectedEngineerName;
    DateTime? localSelectedDate = _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                    width: 50.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'فلترة وتصفية المشكلات',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: TechColors.primaryDark,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              localSearchController.clear();
                              localPhoneController.clear();
                              localLocationController.clear();
                              localSelectedStatus = null;
                              localSelectedEngineerName = null;
                              localSelectedDate = null;
                            });
                          },
                          icon: Icon(Icons.refresh_rounded,
                              size: 18.r, color: Colors.grey.shade600),
                          label: Text(
                            'إعادة تعيين',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.search_rounded,
                            title: 'بحث عام بالاسم أو الرقم أو التفاصيل',
                          ),
                          SizedBox(height: 8.h),
                          _buildFilterTextField(
                            controller: localSearchController,
                            hintText:
                                'ابحث باسم العميل، رقم الهاتف أو تفاصيل المشكلة...',
                            icon: Icons.search_rounded,
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionHeader(
                            icon: Icons.smartphone_rounded,
                            title: 'رقم هاتف الطبيب',
                          ),
                          SizedBox(height: 8.h),
                          _buildFilterTextField(
                            controller: localPhoneController,
                            hintText: 'ابحث برقم هاتف الطبيب (العميل)...',
                            icon: Icons.smartphone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionHeader(
                            icon: Icons.location_on_rounded,
                            title: 'عنوان أو مكان المشكلة',
                          ),
                          SizedBox(height: 8.h),
                          _buildFilterTextField(
                            controller: localLocationController,
                            hintText: 'ابحث بعنوان أو موقع المشكلة...',
                            icon: Icons.location_on_rounded,
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionHeader(
                            icon: Icons.assignment_rounded,
                            title: 'حالة المشكلة',
                          ),
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _statuses.map((status) {
                              final label = status ?? 'الكل';
                              final isSelected = (status == null &&
                                      localSelectedStatus == null) ||
                                  (status != null &&
                                      localSelectedStatus == status);
                              return _buildFilterChip(
                                label: label,
                                isSelected: isSelected,
                                onTap: () {
                                  setModalState(() {
                                    localSelectedStatus = status;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionHeader(
                            icon: Icons.engineering_rounded,
                            title: 'المهندس المسؤول',
                          ),
                          SizedBox(height: 8.h),
                          BlocBuilder<EngineerCubit, EngineerState>(
                            builder: (context, engineerState) {
                              final List<String> engineers = ['الكل'];
                              if (engineerState.engineers.isNotEmpty) {
                                engineers.addAll(
                                  engineerState.engineers
                                      .map((e) => e.name ?? '')
                                      .where((name) => name.isNotEmpty),
                                );
                              }
                              return Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: engineers.map((engName) {
                                  final isSelected = (engName == 'الكل' &&
                                          localSelectedEngineerName == null) ||
                                      (localSelectedEngineerName == engName);
                                  return _buildFilterChip(
                                    label: engName,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setModalState(() {
                                        localSelectedEngineerName =
                                            engName == 'الكل' ? null : engName;
                                      });
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionHeader(
                            icon: Icons.calendar_month_rounded,
                            title: 'تاريخ المشكلة',
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    localSelectedDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  localSelectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              height: 58.h,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      localSelectedDate == null
                                          ? 'اختر تاريخ المشكلة...'
                                          : "${localSelectedDate!.year}-${localSelectedDate!.month.toString().padLeft(2, '0')}-${localSelectedDate!.day.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: localSelectedDate == null
                                            ? Colors.grey.shade500
                                            : TechColors.primaryDark,
                                        fontWeight: localSelectedDate == null
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.grey.shade400,
                                    size: 24.r,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  TechColors.accentCyan,
                                  TechColors.primaryMid
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: TechColors.accentCyan.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18.r),
                                onTap: () {
                                  setState(() {
                                    _searchQuery =
                                        localSearchController.text.trim();
                                    _searchController.text = _searchQuery;
                                    _doctorPhone =
                                        localPhoneController.text.trim();
                                    _problemLocation =
                                        localLocationController.text.trim();
                                    _selectedStatus = localSelectedStatus;
                                    _selectedEngineerName =
                                        localSelectedEngineerName;
                                    _selectedDate = localSelectedDate;
                                  });

                                  _applyFilters();

                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  child: Center(
                                    child: Text(
                                      'تطبيق الفلترة',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18.r),
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  child: Center(
                                    child: Text(
                                      'إلغاء',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToAddProblemScreen() async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddProblemScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (result == true && mounted) {
      context.read<CustomerCubit>().refreshAllData();
    }
  }

  Future<void> _refreshIssues() async {
    await context.read<CustomerCubit>().refreshAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TechColors.surfaceLight,
        body: Stack(
          children: [
            // Premium gradient background
            Container(
              height: MediaQuery.of(context).size.height * 0.38,
              decoration: const BoxDecoration(
                gradient: TechColors.premiumGradient,
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button with animation
                            _buildAnimatedIconButton(
                              icon: Icons.arrow_back_ios_rounded,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            // Logo
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Image.asset(
                                'assets/images/pngs/TS_Logo0.png',
                                width: 100.w,
                                height: 60.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(
                                width: 48), // Placeholder for balance
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Title
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'الدعم الفني',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                 
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'إدارة المشكلات والاستفسارات',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        // Premium search bar
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildPremiumSearchBar(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Main content area
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: TechColors.surfaceLight,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32.r),
                              topRight: Radius.circular(32.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: TechColors.primaryDark.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32.r),
                              topRight: Radius.circular(32.r),
                            ),
                            child: _buildIssuesList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Floating action button
            Positioned(
              bottom: 24.h,
              left: 24.w,
              child: _buildFloatingActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: onPressed,
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22.r,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    final cubit = context.read<CustomerCubit>();
    int? statusId;
    if (_selectedStatus != null && _selectedStatus != 'الكل') {
      final statusMatches = cubit.state.problemStatusList.where(
        (element) => element.name == _selectedStatus,
      );
      if (statusMatches.isNotEmpty) {
        statusId = statusMatches.first.id;
      }
    }

    String? engineerId;
    if (_selectedEngineerName != null && _selectedEngineerName != 'الكل') {
      final engState = context.read<EngineerCubit>().state;
      final engMatches = engState.engineers.where(
        (element) => element.name == _selectedEngineerName,
      );
      if (engMatches.isNotEmpty) {
        engineerId = engMatches.first.id;
      }
    }

    cubit.fetchTechSupportIssues(
      date: _selectedDate != null
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : null,
      address: _problemLocation.isNotEmpty ? _problemLocation : null,
      problem: statusId,
      engineerId: engineerId,
      isSearch: true,
    );
  }

  Widget _buildFilterTag(String label, VoidCallback onClear) {
    return Container(
      margin: EdgeInsets.only(left: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: TechColors.accentCyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: TechColors.accentCyan.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 16.r,
              color: TechColors.accentCyan,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: TechColors.primaryMid,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSearchBar() {
    final List<Widget> tags = [];
    if (_searchQuery.isNotEmpty) {
      tags.add(_buildFilterTag('البحث: $_searchQuery', () {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
        _applyFilters();
      }));
    }
    if (_doctorPhone.isNotEmpty) {
      tags.add(_buildFilterTag('الهاتف: $_doctorPhone', () {
        setState(() {
          _doctorPhone = '';
        });
        _applyFilters();
      }));
    }
    if (_problemLocation.isNotEmpty) {
      tags.add(_buildFilterTag('الموقع: $_problemLocation', () {
        setState(() {
          _problemLocation = '';
        });
        _applyFilters();
      }));
    }
    if (_selectedStatus != null && _selectedStatus != 'الكل') {
      tags.add(_buildFilterTag('الحالة: $_selectedStatus', () {
        setState(() {
          _selectedStatus = null;
        });
        _applyFilters();
      }));
    }
    if (_selectedEngineerName != null && _selectedEngineerName != 'الكل') {
      tags.add(_buildFilterTag('المهندس: $_selectedEngineerName', () {
        setState(() {
          _selectedEngineerName = null;
        });
        _applyFilters();
      }));
    }
    if (_selectedDate != null) {
      final formattedDate =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      tags.add(_buildFilterTag('التاريخ: $formattedDate', () {
        setState(() {
          _selectedDate = null;
        });
        _applyFilters();
      }));
    }

    final hasActiveFilters = tags.isNotEmpty;

    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: TechColors.primaryDark.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(
            Icons.search_rounded,
            color:
                hasActiveFilters ? TechColors.accentCyan : Colors.grey.shade400,
            size: 24.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: hasActiveFilters
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tags,
                    ),
                  )
                : GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                    child: Text(
                      'ابحث عن مشكلة أو فلتر النتائج...',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Container(
            height: 30.h,
            width: 1,
            color: Colors.grey.shade200,
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? TechColors.accentCyan.withOpacity(0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: hasActiveFilters
                      ? TechColors.accentCyan
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: hasActiveFilters ? TechColors.accentCyan : Colors.grey,
                size: 22.r,
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildIssuesList() {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        final List<ProblemModel> allIssues = state.techSupportIssues;

        if (state.status == CustomerStatus.loading && allIssues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(TechColors.accentCyan),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'جاري تحميل البيانات...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Apply filters
        List<ProblemModel> filteredIssues = allIssues;

        // 1. General search filter
        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.trim().toLowerCase();
          filteredIssues = filteredIssues.where((issue) {
            final customerName =
                (issue.customerName ?? '').trim().toLowerCase();
            if (customerName.contains(lowerQuery)) return true;
            final phone =
                (issue.customerPhone ?? issue.phone ?? '').trim().toLowerCase();
            if (phone.contains(lowerQuery)) return true;
            final problemAddress =
                (issue.problemAddress ?? '').trim().toLowerCase();
            if (problemAddress.contains(lowerQuery)) return true;
            final address = (issue.adderss ?? '').trim().toLowerCase();
            if (address.contains(lowerQuery)) return true;
            final details = (issue.problemDetails ?? '').trim().toLowerCase();
            if (details.contains(lowerQuery)) return true;
            return false;
          }).toList();
        }

        // 2. Doctor phone filter
        if (_doctorPhone.isNotEmpty) {
          final phoneQuery = _doctorPhone.trim().toLowerCase();
          filteredIssues = filteredIssues.where((issue) {
            final customerPhone =
                (issue.customerPhone ?? '').trim().toLowerCase();
            final phone = (issue.phone ?? '').trim().toLowerCase();
            return customerPhone.contains(phoneQuery) ||
                phone.contains(phoneQuery);
          }).toList();
        }

        // 3. Location/address filter
        if (_problemLocation.isNotEmpty) {
          final locQuery = _problemLocation.trim().toLowerCase();
          filteredIssues = filteredIssues.where((issue) {
            final problemAddress =
                (issue.problemAddress ?? '').trim().toLowerCase();
            final address = (issue.adderss ?? '').trim().toLowerCase();
            return problemAddress.contains(locQuery) ||
                address.contains(locQuery);
          }).toList();
        }

        // 4. Status filter
        if (_selectedStatus != null && _selectedStatus != 'الكل') {
          final lowerStatus = _selectedStatus!.trim().toLowerCase();
          filteredIssues = filteredIssues
              .where((issue) =>
                  (issue.problemtype ?? '').trim().toLowerCase() == lowerStatus)
              .toList();
        }

        // 5. Engineer filter
        if (_selectedEngineerName != null && _selectedEngineerName != 'الكل') {
          final lowerEngName = _selectedEngineerName!.trim().toLowerCase();
          filteredIssues = filteredIssues.where((issue) {
            // Check main engineerName
            final mainEng = (issue.enginnerName ?? '').trim().toLowerCase();
            if (mainEng == lowerEngName || mainEng.contains(lowerEngName))
              return true;

            // Check customerSupport list
            if (issue.customerSupport != null) {
              for (var support in issue.customerSupport!) {
                if (support is Map) {
                  final engName = (support['engName'] ?? '')
                      .toString()
                      .trim()
                      .toLowerCase();
                  final createdUser = (support['createdUser'] ?? '')
                      .toString()
                      .trim()
                      .toLowerCase();
                  if (engName == lowerEngName ||
                      engName.contains(lowerEngName) ||
                      createdUser == lowerEngName ||
                      createdUser.contains(lowerEngName)) {
                    return true;
                  }
                }
              }
            }

            // Check underTransactions list
            if (issue.underTransactions != null) {
              for (var transaction in issue.underTransactions!) {
                if (transaction is Map) {
                  final engName = (transaction['engName'] ?? '')
                      .toString()
                      .trim()
                      .toLowerCase();
                  if (engName == lowerEngName ||
                      engName.contains(lowerEngName)) {
                    return true;
                  }
                }
              }
            }

            return false;
          }).toList();
        }

        // 6. Date filter
        if (_selectedDate != null) {
          filteredIssues = filteredIssues.where((issue) {
            final issueDate = DateTime.tryParse(issue.problemDate ?? '');
            if (issueDate == null) return false;
            return issueDate.year == _selectedDate!.year &&
                issueDate.month == _selectedDate!.month &&
                issueDate.day == _selectedDate!.day;
          }).toList();
        }

        // Sort by date
        final sortedIssues = List<ProblemModel>.from(filteredIssues);
        sortedIssues.sort((a, b) {
          final dateA =
              DateTime.tryParse(a.problemDate ?? '') ?? DateTime(1970);
          final dateB =
              DateTime.tryParse(b.problemDate ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });

        if (sortedIssues.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refreshIssues,
          color: TechColors.accentCyan,
          backgroundColor: Colors.white,
          strokeWidth: 2.5,
          child: ListView.builder(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 20.h,
              bottom: 100.h,
            ),
            itemCount: sortedIssues.length,
            itemBuilder: (context, index) {
              final issue = sortedIssues[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: TechCardContent(
                  issue: issue,
                  onDetailsPressed: () async {
                    final cubit = context.read<CustomerCubit>();
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProblemDetailsScreen(issue: issue),
                      ),
                    );

                    if (result == true && mounted) {
                      cubit.refreshAllData();
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: TechColors.accentCyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : _selectedStatus != null
                      ? Icons.filter_alt_off_rounded
                      : Icons.inbox_rounded,
              size: 56.r,
              color: TechColors.accentCyan,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'لا توجد نتائج'
                : _selectedStatus != null
                    ? 'لا توجد مشكلات بهذه الحالة'
                    : 'لا توجد مشكلات حالياً',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: TechColors.primaryDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'ستظهر المشكلات الجديدة هنا',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [TechColors.accentCyan, TechColors.primaryMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: TechColors.accentCyan.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: _navigateToAddProblemScreen,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'إضافة مشكلة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
