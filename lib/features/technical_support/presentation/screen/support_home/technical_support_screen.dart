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
  String? _selectedStatus;
  List<String?> _statuses = [];
  final GlobalKey _statusKey = GlobalKey();

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

  void _onStatusSelected(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    final cubit = context.read<CustomerCubit>();
    cubit.emit(cubit.state.copyWith(selectedStatus: status));
  }

  Future<void> _showStatusMenu() async {
    final renderBox =
        _statusKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final selected = await showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 8,
        offset.dx + renderBox.size.width,
        offset.dy,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      elevation: 12,
      shadowColor: TechColors.primaryMid.withOpacity(0.3),
      items: _statuses.map((status) {
        final label = status ?? 'جميع الحالات';
        final isSelected = status == _selectedStatus;
        return PopupMenuItem<String?>(
          value: status,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? TechColors.accentCyan.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TechColors.accentCyan
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.r)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? TechColors.primaryDark
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (selected != null || (_statuses.isNotEmpty && selected == null)) {
      _onStatusSelected(selected);
    }
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
                            SizedBox(width: 48.w), // Balance the row
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

  Widget _buildPremiumSearchBar() {
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
          // Filter button
          GestureDetector(
            key: _statusKey,
            onTap: _showStatusMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: _selectedStatus != null
                    ? TechColors.accentCyan.withOpacity(0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _selectedStatus != null
                      ? TechColors.accentCyan
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: _selectedStatus != null
                    ? TechColors.accentCyan
                    : Colors.grey,
                size: 22.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Divider
          Container(
            height: 30.h,
            width: 1,
            color: Colors.grey.shade200,
          ),
          SizedBox(width: 12.w),
          // Search input
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: TechColors.primaryDark,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن مشكلة...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          // Clear button with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _searchQuery.isNotEmpty
                ? IconButton(
                    key: const ValueKey('clear'),
                    icon: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade600,
                        size: 16.r,
                      ),
                    ),
                    onPressed: () => _searchController.clear(),
                  )
                : Icon(
                    Icons.search_rounded,
                    key: const ValueKey('search'),
                    color: Colors.grey.shade400,
                    size: 24.r,
                  ),
          ),
          SizedBox(width: 8.w),
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

        // Apply search filter
        List<ProblemModel> searchedIssues = allIssues;
        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.toLowerCase();
          searchedIssues = allIssues.where((issue) {
            final customerName = (issue.customerName ?? '').toLowerCase();
            if (customerName.contains(lowerQuery)) return true;
            final phone =
                (issue.customerPhone ?? issue.phone ?? '').toLowerCase();
            if (phone.contains(lowerQuery)) return true;
            final problemAddress = (issue.problemAddress ?? '').toLowerCase();
            if (problemAddress.contains(lowerQuery)) return true;
            final address = (issue.adderss ?? '').toLowerCase();
            if (address.contains(lowerQuery)) return true;
            final details = (issue.problemDetails ?? '').toLowerCase();
            if (details.contains(lowerQuery)) return true;
            return false;
          }).toList();
        }

        // Sort by date
        final sortedIssues = List<ProblemModel>.from(searchedIssues);
        sortedIssues.sort((a, b) {
          final dateA =
              DateTime.tryParse(a.problemDate ?? '') ?? DateTime(1970);
          final dateB =
              DateTime.tryParse(b.problemDate ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });

        // Filter by status
        final filteredIssues = _selectedStatus == null
            ? sortedIssues
            : sortedIssues
                .where((issue) => issue.problemtype == _selectedStatus)
                .toList();

        if (filteredIssues.isEmpty) {
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
            itemCount: filteredIssues.length,
            itemBuilder: (context, index) {
              final issue = filteredIssues[index];
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
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProblemDetailsScreen(issue: issue),
                      ),
                    );

                    if (result == true && mounted) {
                      context.read<CustomerCubit>().refreshAllData();
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
