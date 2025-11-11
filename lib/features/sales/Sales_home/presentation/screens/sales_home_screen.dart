import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_state.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/content_card_home_widget.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/filter_widget.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/home_skeltonizer_widget.dart';
import 'package:tabib_soft_company/features/sales/notifications/presentation/screens/notification_screen.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/screens/taday_calls_screen.dart';

class SalesHomeScreen extends StatefulWidget {
  const SalesHomeScreen({super.key});

  static const double horizontalPadding = 16.0;

  @override
  State<SalesHomeScreen> createState() => _SalesHomeScreenState();
}

class _SalesHomeScreenState extends State<SalesHomeScreen> {
  late ApiService _apiService;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? selectedStatusId;
  String? selectedProductId;
  DateTime? fromDate;
  DateTime? toDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _apiService = ServicesLocator.locator<ApiService>();
    final cubit = context.read<SalesCubit>();
    if (cubit.state.products.isEmpty || cubit.state.statuses.isEmpty) {
      cubit.fetchProducts().then((_) {
        cubit.fetchStatuses().then((_) {
          cubit.fetchMeasurements(page: 1, pageSize: 10);
        });
      });
    } else {
      cubit.fetchMeasurements(page: 1, pageSize: 10);
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      _refreshMeasurements();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<SalesCubit>().state.currentPage <
              context.read<SalesCubit>().state.totalPages) {
        context.read<SalesCubit>().fetchMeasurements(
              page: context.read<SalesCubit>().state.currentPage + 1,
              pageSize: 10,
              statusId: selectedStatusId,
              productId: selectedProductId,
              search: _searchQuery.isNotEmpty ? _searchQuery : null,
              fromDate: fromDate != null ? _formatDateForApi(fromDate!) : null,
              toDate: toDate != null ? _formatDateForApi(toDate!) : null,
            );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> showFilterBottomSheet() async {
    final cubit = context.read<SalesCubit>();
    if (cubit.state.statuses.isEmpty) {
      await cubit.fetchStatuses();
    }
    if (cubit.state.products.isEmpty) {
      await cubit.fetchProducts();
    }
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => FilterBottomSheet(
        currentStatusId: selectedStatusId,
        currentProductId: selectedProductId,
        currentFrom: fromDate,
        currentTo: toDate,
        products: cubit.state.products,
        statuses: cubit.state.statuses,
      ),
    );

    if (result != null) {
      setState(() {
        selectedStatusId = result['status'];
        selectedProductId = result['productId'];
        fromDate = result['from'];
        toDate = result['to'];
      });
      _refreshMeasurements();
    }
  }

  void _refreshMeasurements() {
    context.read<SalesCubit>().fetchMeasurements(
          page: 1,
          pageSize: 10,
          statusId: selectedStatusId,
          productId: selectedProductId,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          fromDate: fromDate != null ? _formatDateForApi(fromDate!) : null,
          toDate: toDate != null ? _formatDateForApi(toDate!) : null,
          isRefresh: true,
        );
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<bool?> _showLogoutDialog() {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'تأكيد تسجيل الخروج',
      barrierColor: Colors.black54.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = Curves.easeOutBack.transform(animation.value);
        return Transform.scale(
          scale: curved,
          child: Opacity(
            opacity: animation.value,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 110,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  size: 34,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ' تسجيل الخروج',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 18),
                        child: Column(
                          children: [
                            Text(
                              'هل أنت متأكد أنك تريد تسجيل الخروج الآن؟',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color(0xFF1976D2), width: 1.4),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close, color: Color(0xFF1976D2)),
                                    SizedBox(width: 8),
                                    Text(
                                      'لا، إلغاء',
                                      style: TextStyle(
                                          color: Color(0xFF1976D2),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 6,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'نعم، تسجيل الخروج',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TodayCallsScreen()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                final shouldLogout = await _showLogoutDialog();
                if (shouldLogout == true) {
                  await CacheHelper.removeData(key: 'loginToken');
                  await CacheHelper.removeData(key: 'userName');
                  await CacheHelper.removeData(key: 'userRoles');
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
        body: Container(
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
                      horizontal: SalesHomeScreen.horizontalPadding),
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
                          onTap: showFilterBottomSheet,
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
                    child: BlocBuilder<SalesCubit, SalesState>(
                      builder: (context, state) {
                        if (state.status == SalesStatus.loading) {
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: SalesHomeScreen.horizontalPadding,
                                vertical: 8),
                            itemCount: 3,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 20),
                            itemBuilder: (_, __) => SkeletonCard(),
                          );
                        } else if (state.status == SalesStatus.loaded ||
                            state.status == SalesStatus.loadingMore) {
                          final measurements = state.measurements;
                          return RefreshIndicator(
                            onRefresh: () async {
                              _refreshMeasurements();
                            },
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: SalesHomeScreen.horizontalPadding,
                                  vertical: 8),
                              itemCount: measurements.length +
                                  (state.status == SalesStatus.loadingMore
                                      ? 1
                                      : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                if (index == measurements.length) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                try {
                                  return ContactCard(
                                    measurement: measurements[index],
                                    products: state.products,
                                    statuses: state.statuses, // Added statuses
                                  );
                                } catch (e) {
                                  debugPrint(e.toString());
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          );
                        } else if (state.status == SalesStatus.error) {
                          return Center(
                            child:
                                Text(state.failure?.errMessages ?? 'حدث خطأ'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
