import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/technical_support/export.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/problem/problem_details_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/new/tech_card_content.dart';

class TechnicalSupportScreen extends StatefulWidget {
  const TechnicalSupportScreen({super.key});
  static const double horizontalPadding = 16.0;

  @override
  State<TechnicalSupportScreen> createState() => _TechnicalSupportScreenState();
}

class _TechnicalSupportScreenState extends State<TechnicalSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatus;
  static const Color primaryColor = Color(0xFF56C7F1);
  List<String?> _statuses = [];
  final GlobalKey _statusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final token = CacheHelper.getString(key: 'loginToken');
    if (token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    } else {
      // تحميل البيانات الأساسية
      context.read<CustomerCubit>().fetchProblemStatus();
      context.read<CustomerCubit>().refreshAllData();
    }

    // مراقبة التغييرات في البحث
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    // مراقبة تغييرات الحالة
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
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      elevation: 8,
      items: _statuses.map((status) {
        final label = status ?? 'جميع الحالات';
        final isSelected = status == _selectedStatus;
        return PopupMenuItem<String?>(
          value: status,
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green : Colors.black87,
                ),
              ),
            ],
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
      MaterialPageRoute(builder: (_) => const AddProblemScreen()),
    );

    // عند الرجوع من صفحة الإضافة، نحدث البيانات
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const SizedBox.shrink(),
          leading: IconButton(
            icon: const Icon(Icons.headset, color: Colors.transparent),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xff104D9D),
                    Color(0xFF20AAC9),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Image.asset(
                        'assets/images/pngs/TS_Logo0.png',
                        width: 140,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TechnicalSupportScreen.horizontalPadding),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, 6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            GestureDetector(
                              key: _statusKey,
                              onTap: _showStatusMenu,
                              child: Image.asset(
                                'assets/images/pngs/filter.png',
                                width: 28,
                                height: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'البحث...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            // زر مسح البحث
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F5F6),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: BlocBuilder<CustomerCubit, CustomerState>(
                          builder: (context, state) {
                            final List<ProblemModel> allIssues =
                                state.techSupportIssues;

                            if (state.status == CustomerStatus.loading &&
                                allIssues.isEmpty) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            // تطبيق البحث المحلي
                            List<ProblemModel> searchedIssues = allIssues;
                            if (_searchQuery.isNotEmpty) {
                              final lowerQuery = _searchQuery.toLowerCase();
                              searchedIssues = allIssues.where((issue) {
                                // البحث في اسم العميل
                                final customerName =
                                    (issue.customerName ?? '').toLowerCase();
                                if (customerName.contains(lowerQuery))
                                  return true;

                                // البحث في رقم الهاتف
                                final phone =
                                    (issue.customerPhone ?? issue.phone ?? '')
                                        .toLowerCase();
                                if (phone.contains(lowerQuery)) return true;

                                // البحث في عنوان المشكلة
                                final problemAddress =
                                    (issue.problemAddress ?? '').toLowerCase();
                                if (problemAddress.contains(lowerQuery))
                                  return true;

                                // البحث في العنوان
                                final address =
                                    (issue.adderss ?? '').toLowerCase();
                                if (address.contains(lowerQuery)) return true;

                                // البحث في تفاصيل المشكلة
                                final details =
                                    (issue.problemDetails ?? '').toLowerCase();
                                if (details.contains(lowerQuery)) return true;

                                return false;
                              }).toList();
                            }

                            // ترتيب حسب التاريخ
                            final sortedIssues =
                                List<ProblemModel>.from(searchedIssues);
                            sortedIssues.sort((a, b) {
                              final dateA =
                                  DateTime.tryParse(a.problemDate ?? '') ??
                                      DateTime(1970);
                              final dateB =
                                  DateTime.tryParse(b.problemDate ?? '') ??
                                      DateTime(1970);
                              return dateB.compareTo(dateA);
                            });

                            // تصفية حسب الحالة المختارة
                            final filteredIssues = _selectedStatus == null
                                ? sortedIssues
                                : sortedIssues
                                    .where((issue) =>
                                        issue.problemtype == _selectedStatus)
                                    .toList();

                            if (filteredIssues.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'لا توجد نتائج للبحث عن "$_searchQuery"'
                                          : _selectedStatus != null
                                              ? 'لا توجد مشكلات بهذه الحالة'
                                              : 'لا توجد مشكلات حالياً',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                await _refreshIssues();
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      TechnicalSupportScreen.horizontalPadding,
                                  vertical: 8,
                                ),
                                itemCount: filteredIssues.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 20),
                                itemBuilder: (context, index) {
                                  final issue = filteredIssues[index];
                                  return TechCardContent(
                                    issue: issue,
                                    onDetailsPressed: () async {
                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProblemDetailsScreen(
                                              issue: issue),
                                        ),
                                      );

                                      // تحديث البيانات عند الرجوع
                                      if (result == true && mounted) {
                                        context
                                            .read<CustomerCubit>()
                                            .refreshAllData();
                                      }
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: -6,
              child: GestureDetector(
                onTap: _navigateToAddProblemScreen,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pngs/Ellipse_3.png',
                      width: 70,
                      height: 70,
                    ),
                    const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
