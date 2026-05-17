import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/requirements_cubit.dart';
import '../cubit/requirements_state.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/requirement_data_table.dart';
import '../widgets/edit_note_dialog.dart';
import '../../data/models/requirement_model.dart';
import '../widgets/requirement_images_sheet.dart';
import '../../../Sales_home/presentation/screens/notes/notes_screen.dart';
import '../../../../../core/services/locator/get_it_locator.dart';
import '../../../Sales_home/presentation/cubits/notes/sales_details_cubit.dart';
import '../widgets/adminSales_loader.dart';

class SalesAdminRequirementsScreen extends StatefulWidget {
  const SalesAdminRequirementsScreen({super.key});

  @override
  State<SalesAdminRequirementsScreen> createState() =>
      _SalesAdminRequirementsScreenState();
}

class _SalesAdminRequirementsScreenState
    extends State<SalesAdminRequirementsScreen>
    with SingleTickerProviderStateMixin {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedSalesPersonId;
  String? selectedStatusName;
  String? selectedName;
  final Set<String> _selectedStatusFilters = {};
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RequirementsCubit>();
    cubit.fetchSalesPersons();
    cubit.fetchRequirements(page: 1, pageSize: 25);
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const threshold = 200.0;

    if (currentScroll >= (maxScroll - threshold)) {
      final cubit = context.read<RequirementsCubit>();
      final state = cubit.state;

      if (state.status != RequirementsStatus.loadingMore &&
          state.status != RequirementsStatus.loading &&
          state.currentPage < state.totalPages) {
        cubit.fetchRequirements(
          page: state.currentPage + 1,
          pageSize: 25,
          fromDate: fromDate != null ? _formatDateForApi(fromDate!) : null,
          toDate: toDate != null ? _formatDateForApi(toDate!) : null,
          salesPersonId: selectedSalesPersonId,
          statusName: selectedStatusName,
          name: selectedName,
        );
      }
    }
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showFilterDialog() async {
    final state = context.read<RequirementsCubit>().state;
    final salesPersons = state.salesPersons;
    final statusCounts = state.statusCounts;

    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return FilterDialog(
          salesPersons: salesPersons,
          statusCounts: statusCounts,
          currentFromDate: fromDate,
          currentToDate: toDate,
          currentSalesPersonId: selectedSalesPersonId,
          currentStatusName: selectedStatusName,
          currentName: selectedName,
        );
      },
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        fromDate = result['fromDate'];
        toDate = result['toDate'];
        selectedSalesPersonId = result['salesPersonId'];
        selectedStatusName = result['statusName'];
        selectedName = result['name'];
        _selectedStatusFilters.clear();
        if (result['statusName'] != null) {
          _selectedStatusFilters.add(result['statusName']);
        }
      });

      context.read<RequirementsCubit>().fetchRequirements(
            page: 1,
            pageSize: 25,
            fromDate: fromDate != null ? _formatDateForApi(fromDate!) : null,
            toDate: toDate != null ? _formatDateForApi(toDate!) : null,
            salesPersonId: selectedSalesPersonId,
            statusName: selectedStatusName,
            name: selectedName,
            isRefresh: true,
          );
    }
  }

  void _onStatusBoxTapped(String statusName) {
    setState(() {
      if (_selectedStatusFilters.contains(statusName)) {
        _selectedStatusFilters.remove(statusName);
      } else {
        _selectedStatusFilters.clear();
        _selectedStatusFilters.add(statusName);
      }
      selectedStatusName = _selectedStatusFilters.isNotEmpty
          ? _selectedStatusFilters.first
          : null;
    });

    context.read<RequirementsCubit>().fetchRequirements(
          page: 1,
          pageSize: 25,
          fromDate: fromDate != null ? _formatDateForApi(fromDate!) : null,
          toDate: toDate != null ? _formatDateForApi(toDate!) : null,
          salesPersonId: selectedSalesPersonId,
          statusName: selectedStatusName,
          name: selectedName,
          isRefresh: true,
        );
  }

  void _showEditNoteDialog(
      String requirementId, String measurementId, String? currentNote) async {
    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return EditNoteDialog(currentNote: currentNote);
      },
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
    );

    if (result != null) {
      context.read<RequirementsCubit>().updateAdminNote(
            requirementId: requirementId,
            measurementId: measurementId,
            note: result,
          );
    }
  }

  void _viewRequirementImages(RequirementReport req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => RequirementImagesSheet(
          requirement: req,
        ),
      ),
    );
  }

  void _navigateToDealDetails(RequirementReport req) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ServicesLocator.locator<SalesDetailsCubit>(),
          child: NotesScreen(
            measurementId: req.measurementId ?? req.id,
            customerName: req.customerName,
            isFromNotification: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Requirements Report',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF104D9D), Color(0xFF20AAC9)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
                onPressed: _showFilterDialog,
              ),
            ),
          ],
        ),
        body: BlocBuilder<RequirementsCubit, RequirementsState>(
          builder: (context, state) {
            if (state.status == RequirementsStatus.loading &&
                state.requirements.isEmpty) {
              return const Center(child: CodingLoader());
            }

            if (state.status == RequirementsStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'حدث خطأ غير متوقع',
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF104D9D),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        context.read<RequirementsCubit>().fetchRequirements(
                              page: 1,
                              pageSize: 25,
                              isRefresh: true,
                            );
                      },
                      child: const Text('إعادة المحاولة',
                          style: TextStyle(
                              fontFamily: 'Amiri', color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<RequirementsCubit>().fetchRequirements(
                          page: 1,
                          pageSize: 25,
                          fromDate: fromDate != null
                              ? _formatDateForApi(fromDate!)
                              : null,
                          toDate: toDate != null
                              ? _formatDateForApi(toDate!)
                              : null,
                          salesPersonId: selectedSalesPersonId,
                          statusName: selectedStatusName,
                          name: selectedName,
                          isRefresh: true,
                        );
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildSummaryHeader(state),
                      ),
                      if (state.requirements.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_rounded,
                                    size: 60, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  'لا توجد طلبات حالياً',
                                  style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 16,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return RequirementDataTable.buildCardStatic(
                                  context: context,
                                  req: state.requirements[index],
                                  onEditNote: _showEditNoteDialog,
                                  onViewImages: _viewRequirementImages,
                                  onCustomerTap: _navigateToDealDetails,
                                );
                              },
                              childCount: state.requirements.length,
                            ),
                          ),
                        ),
                      if (state.status == RequirementsStatus.loadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(RequirementsState state) {
    if (state.statusCounts.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.statusCounts.length,
        itemBuilder: (context, index) {
          final status = state.statusCounts[index];
          final isSelected = _selectedStatusFilters.contains(status.statusName);
          final statusColor =
              Color(int.parse(status.statusColor.replaceFirst('#', '0xFF')));
          return GestureDetector(
            onTap: () => _onStatusBoxTapped(status.statusName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? statusColor.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? statusColor : Colors.transparent,
                  width: isSelected ? 2 : 0,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status.statusName,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${status.count}',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
