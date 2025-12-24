import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_state.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/sales_content_card_home_widget.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/filter_widget.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/home_skeltonizer_widget.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/screens/taday_calls_screen.dart';

class SalesHomeScreen extends StatefulWidget {
  const SalesHomeScreen({super.key});

  static const double horizontalPadding = 16.0;

  @override
  State<SalesHomeScreen> createState() => _SalesHomeScreenState();
}

class _SalesHomeScreenState extends State<SalesHomeScreen> {
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
    final cubit = context.read<SalesCubit>();

    cubit.fetchProducts();
    cubit.fetchStatuses();
    cubit.fetchMeasurements(page: 1, pageSize: 20);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      _refreshMeasurements();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const threshold = 200.0;

    if (currentScroll >= (maxScroll - threshold)) {
      final cubit = context.read<SalesCubit>();
      final state = cubit.state;

      if (state.status != SalesStatus.loadingMore &&
          state.status != SalesStatus.loading &&
          state.currentPage < state.totalPages) {
        cubit.fetchMeasurements(
          page: state.currentPage + 1,
          pageSize: 20,
          statusId: selectedStatusId,
          productId: selectedProductId,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          fromDate: fromDate != null ? _formatDateForApi(fromDate!) : null,
          toDate: toDate != null ? _formatDateForApi(toDate!) : null,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> showFilterBottomSheet() async {
    final cubit = context.read<SalesCubit>();

    // These calls are now idempotent
    await cubit.fetchStatuses();
    await cubit.fetchProducts();

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
      final bool changed = selectedStatusId != result['status'] ||
          selectedProductId != result['productId'] ||
          fromDate != result['from'] ||
          toDate != result['to'];

      if (changed) {
        setState(() {
          selectedStatusId = result['status'];
          selectedProductId = result['productId'];
          fromDate = result['from'];
          toDate = result['to'];
        });
        _refreshMeasurements();
      }
    }
  }

  void _refreshMeasurements() {
    context.read<SalesCubit>().fetchMeasurements(
          page: 1,
          pageSize: 20,
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
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
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
                                  return SalesContactCard(
                                    measurement: measurements[index],
                                    products: state.products,
                                    statuses: state.statuses,
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
