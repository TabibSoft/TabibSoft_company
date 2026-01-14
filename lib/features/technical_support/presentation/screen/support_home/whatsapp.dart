import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/whatsapp/whatsapp_models.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/whatsapp/whatsapp_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/whatsapp/whatsapp_state.dart';

class WhatsappPage extends StatelessWidget {
  const WhatsappPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WhatsappPageContent();
  }
}

class _WhatsappPageContent extends StatefulWidget {
  const _WhatsappPageContent();

  @override
  State<_WhatsappPageContent> createState() => _WhatsappPageContentState();
}

class _WhatsappPageContentState extends State<_WhatsappPageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedTab = 0; // 0: Individual, 1: Bulk

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSendMessageDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<WhatsAppCubit>(),
        child: SendMessageSheet(initialBulkMode: _selectedTab == 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WhatsAppColors.surfaceLight,
        body: Stack(
          children: [
            // Premium gradient background
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: const BoxDecoration(
                gradient: WhatsAppColors.primaryGradient,
              ),
              child: Stack(
                children: [
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
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeaderButton(
                              icon: Icons.refresh_rounded,
                              onPressed: () {
                                final cubit = context.read<WhatsAppCubit>();
                                if (cubit.state.status !=
                                        WhatsAppStatus.loading &&
                                    cubit.state.status !=
                                        WhatsAppStatus.loadingMessages) {
                                  if (_selectedTab == 0) {
                                    cubit.fetchMessages();
                                  } else {
                                    cubit.fetchBulkJobs();
                                  }
                                }
                              },
                            ),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/pngs/icons8-whatsapp-48 3.png',
                                    width: 32.w,
                                    height: 32.h,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'واتساب',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildHeaderButton(
                              icon: Icons.arrow_forward_ios_rounded,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Stats row
                        BlocBuilder<WhatsAppCubit, WhatsAppState>(
                          builder: (context, state) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildStatChip(
                                        icon: Icons.message_rounded,
                                        label: '${state.messageCount} رسالة',
                                      ),
                                      SizedBox(width: 16.w),
                                      _buildStatChip(
                                        icon: Icons.chat_bubble_outline_rounded,
                                        label:
                                            '${state.conversationCount} محادثة',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  // Instance stats row
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildStatChip(
                                          icon: Icons.devices_rounded,
                                          label:
                                              'إجمالي: ${state.totalInstances}',
                                        ),
                                        SizedBox(width: 12.w),
                                        _buildStatChip(
                                          icon: Icons.check_circle_outline,
                                          label:
                                              'نشط: ${state.activeInstances}',
                                        ),
                                        SizedBox(width: 12.w),
                                        _buildStatChip(
                                          icon: Icons.assignment_rounded,
                                          label:
                                              'مسموح: ${state.maxAllowedInstances}',
                                        ),
                                        SizedBox(width: 12.w),
                                        _buildStatChip(
                                          icon: Icons.add_circle_outline,
                                          label:
                                              'متاح: ${state.availableSlots}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Content area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: WhatsAppColors.surfaceLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.r),
                          topRight: Radius.circular(32.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildValuesTabs(),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32.r),
                                topRight: Radius.circular(32.r),
                              ),
                              child: _buildContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // FAB
            Positioned(
              bottom: 24.h,
              left: 24.w,
              child: _buildFAB(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
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
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18.r),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<WhatsAppCubit, WhatsAppState>(
      builder: (context, state) {
        if (state.status == WhatsAppStatus.loading ||
            state.status == WhatsAppStatus.initial) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      WhatsAppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'جاري تحميل الرسائل...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.status == WhatsAppStatus.error &&
            state.conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.error_outline_rounded,
                  //   size: 64.r,
                  //   color: Colors.red.shade300,
                  // ),
                  // SizedBox(height: 16.h),
                  // Text(
                  //   'حدث خطأ',
                  //   style: TextStyle(
                  //     fontSize: 18.sp,
                  //     fontWeight: FontWeight.bold,
                  //     color: WhatsAppColors.textPrimary,
                  //   ),
                  // ),
                  // SizedBox(height: 8.h),
                  // Text(
                  //   state.errorMessage ?? 'حدث خطأ غير متوقع',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 14.sp,
                  //     color: Colors.grey.shade600,
                  //   ),
                  // ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () => context.read<WhatsAppCubit>().initialize(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WhatsAppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Check for empty state based on selected tab
        if (_selectedTab == 0 && state.conversations.isEmpty) {
          return _buildEmptyState(
              'لا توجد رسائل جديدة', 'ابدأ محادثة جديدة بالضغط على الزر أدناه');
        }

        if (_selectedTab == 1 && state.bulkJobs.isEmpty) {
          return _buildEmptyState('لا توجد رسائل جماعية',
              'أرسل رسالة جماعية جديدة بالضغط على الزر أدناه');
        }

        return RefreshIndicator(
          onRefresh: () => _selectedTab == 0
              ? context.read<WhatsAppCubit>().fetchMessages()
              : context.read<WhatsAppCubit>().fetchBulkJobs(),
          color: WhatsAppColors.primaryGreen,
          child: _selectedTab == 0
              ? ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 20.h,
                    bottom: 100.h,
                  ),
                  itemCount: state.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = state.conversations[index];
                    return _buildAnimatedItem(
                      index: index,
                      child: _ConversationCard(conversation: conversation),
                    );
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 20.h,
                    bottom: 100.h,
                  ),
                  itemCount: state.bulkJobs.length,
                  itemBuilder: (context, index) {
                    final job = state.bulkJobs[index];
                    return _buildAnimatedItem(
                      index: index,
                      child: _BulkJobCard(job: job),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: WhatsAppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56.r,
              color: WhatsAppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: WhatsAppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child!,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildFAB() {
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
          gradient: WhatsAppColors.headerGradient,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: WhatsAppColors.primaryGreen.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: _showSendMessageDialog,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _selectedTab == 0 ? 'رسالة جديدة' : 'رسالة جماعية جديدة',
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

  Widget _buildValuesTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('رسائل فردية', 0)),
          Expanded(child: _buildTabItem('رسائل جماعية', 1)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        // تجنب الطلبات المتكررة إذا كنا بالفعل في نفس التاب
        if (_selectedTab == index) return;

        setState(() => _selectedTab = index);

        // التحقق من أن الحالة ليست في loading قبل عمل طلب جديد
        final cubit = context.read<WhatsAppCubit>();
        final currentState = cubit.state;

        if (currentState.status == WhatsAppStatus.loading ||
            currentState.status == WhatsAppStatus.loadingMessages) {
          return;
        }

        if (index == 0) {
          cubit.fetchMessages();
        } else {
          cubit.fetchBulkJobs();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color:
                isSelected ? WhatsAppColors.primaryGreen : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// Conversation Card Widget
class _ConversationCard extends StatelessWidget {
  final WhatsAppConversation conversation;

  const _ConversationCard({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final lastMessage =
        conversation.messages.isNotEmpty ? conversation.messages.last : null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<WhatsAppCubit>(),
                  child: ChatDetailScreen(conversation: conversation),
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: const BoxDecoration(
                    gradient: WhatsAppColors.headerGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(conversation.contactName ??
                          conversation.phoneNumber ??
                          '?'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.contactName ??
                                  _formatPhoneNumber(
                                      conversation.phoneNumber ?? ''),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: WhatsAppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.lastMessageTime != null)
                            Text(
                              _formatTime(conversation.lastMessageTime!),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage?.body ?? 'لا توجد رسائل',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.messageCount > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: WhatsAppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '${conversation.messageCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length > 10) {
      return '+${phone.substring(0, 3)} ${phone.substring(3)}';
    }
    return phone;
  }

  String _formatTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }
}

// Bulk Job Card Widget
class _BulkJobCard extends StatelessWidget {
  final WhatsAppBulkJob job;

  const _BulkJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BulkJobDetailScreen(job: job),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.jobName ?? 'رسالة جماعية',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: WhatsAppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(),
                  ],
                ),
                SizedBox(height: 12.h),
                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.people_outline,
                      label: 'المستلمين',
                      value: '${job.totalRecipients}',
                      color: WhatsAppColors.primaryGreen,
                    ),
                    SizedBox(width: 16.w),
                    _buildStatItem(
                      icon: Icons.check_circle_outline,
                      label: 'تم الإرسال',
                      value: '${job.sentCount}',
                      color: Colors.green,
                    ),
                    SizedBox(width: 16.w),
                    _buildStatItem(
                      icon: Icons.error_outline,
                      label: 'فشل',
                      value: '${job.failedCount}',
                      color: Colors.red,
                    ),
                    SizedBox(width: 16.w),
                    _buildStatItem(
                      icon: Icons.pending_outlined,
                      label: 'قيد الانتظار',
                      value: '${job.pendingCount}',
                      color: Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: job.totalRecipients > 0
                        ? job.sentCount / job.totalRecipients
                        : 0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(),
                    ),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 12.h),
                // Time Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (job.startedAt != null)
                      Text(
                        'بدأ: ${_formatDateTime(job.startedAt!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (job.completedAt != null)
                      Text(
                        'انتهى: ${_formatDateTime(job.completedAt!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        job.message ?? job.status ?? 'غير معروف',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: WhatsAppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (job.status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'running':
      case 'inprogress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return WhatsAppColors.primaryGreen;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

// Chat Detail Screen
class ChatDetailScreen extends StatefulWidget {
  final WhatsAppConversation conversation;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<WhatsAppCubit>().fetchChatMessages(
          widget.conversation.phoneNumber ?? '',
          contactName: widget.conversation.contactName,
        );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final success = await context.read<WhatsAppCubit>().sendMessage(
          toNumber: widget.conversation.phoneNumber ?? '',
          message: _messageController.text.trim(),
        );

    if (success && mounted) {
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال الرسالة بنجاح'),
          backgroundColor: WhatsAppColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WhatsAppColors.chatBackground,
        appBar: AppBar(
          backgroundColor: WhatsAppColors.darkGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () {
              context.read<WhatsAppCubit>().clearCurrentChat();
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(widget.conversation.contactName ??
                        widget.conversation.phoneNumber ??
                        '?'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.contactName ??
                        widget.conversation.phoneNumber ??
                        '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.conversation.phoneNumber != null)
                    Text(
                      widget.conversation.phoneNumber!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: BlocBuilder<WhatsAppCubit, WhatsAppState>(
                builder: (context, state) {
                  if (state.status == WhatsAppStatus.loadingMessages) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: WhatsAppColors.primaryGreen,
                      ),
                    );
                  }

                  final messages = state.currentChatMessages.isNotEmpty
                      ? state.currentChatMessages
                      : widget.conversation.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد رسائل',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _MessageBubble(message: message);
                    },
                  );
                },
              ),
            ),
            // Input area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  BlocBuilder<WhatsAppCubit, WhatsAppState>(
                    builder: (context, state) {
                      final isSending =
                          state.status == WhatsAppStatus.sendingMessage;
                      return Container(
                        decoration: const BoxDecoration(
                          color: WhatsAppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24.r),
                            onTap: isSending ? null : _sendMessage,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: isSending
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 22.r,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

class _MessageBubble extends StatelessWidget {
  final WhatsAppMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromMe = message.fromMe;

    return Align(
      alignment: isFromMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        constraints: BoxConstraints(maxWidth: 280.w),
        decoration: BoxDecoration(
          color: isFromMe ? WhatsAppColors.lightGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isFromMe ? 4.r : 16.r),
            bottomRight: Radius.circular(isFromMe ? 16.r : 4.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.messageDateTime),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (isFromMe) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.messageStatus == 'read'
                        ? Icons.done_all
                        : Icons.done,
                    size: 14.r,
                    color: message.messageStatus == 'read'
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

// Send Message Sheet
class SendMessageSheet extends StatefulWidget {
  final bool initialBulkMode;

  const SendMessageSheet({
    super.key,
    this.initialBulkMode = false,
  });

  @override
  State<SendMessageSheet> createState() => _SendMessageSheetState();
}

class _SendMessageSheetState extends State<SendMessageSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _phoneListController = TextEditingController();
  late bool _isBulkMode;

  @override
  void initState() {
    super.initState();
    _isBulkMode = widget.initialBulkMode;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _phoneListController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<WhatsAppCubit>();
    bool success;

    if (_isBulkMode) {
      final phoneNumbers = _phoneListController.text
          .split('\n')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      success = await cubit.sendBulkMessage(
        phoneNumbers: phoneNumbers.map(_formatPhoneForApi).toList(),
        message: _messageController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال الرسائل إلى ${phoneNumbers.length} شخص'),
            backgroundColor: WhatsAppColors.primaryGreen,
          ),
        );
      }
    } else {
      success = await cubit.sendMessage(
        toNumber: _formatPhoneForApi(_phoneController.text.trim()),
        message: _messageController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الرسالة بنجاح'),
            backgroundColor: WhatsAppColors.primaryGreen,
          ),
        );
      }
    }

    if (!success && mounted) {
      final state = cubit.state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'فشل إرسال الرسالة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatPhoneForApi(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // Egyptian numbers: 01xxxxxxxxx -> 201xxxxxxxxx
    if (cleanPhone.length == 11 && cleanPhone.startsWith('01')) {
      return '2$cleanPhone';
    }

    return cleanPhone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      color: WhatsAppColors.primaryGreen,
                      size: 24.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'إرسال رسالة جديدة',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: WhatsAppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isBulkMode = false),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: !_isBulkMode
                                  ? WhatsAppColors.primaryGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                'رسالة واحدة',
                                style: TextStyle(
                                  color: !_isBulkMode
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isBulkMode = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: _isBulkMode
                                  ? WhatsAppColors.primaryGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                'رسالة جماعية',
                                style: TextStyle(
                                  color: _isBulkMode
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Phone input
                if (!_isBulkMode)
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '201234567890',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: WhatsAppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _phoneListController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'أرقام الهواتف (رقم في كل سطر)',
                      hintText: '201234567890\n201234567891\n201234567892',
                      prefixIcon: const Icon(Icons.group),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: WhatsAppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال أرقام الهواتف';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 16.h),
                // Message input
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'الرسالة',
                    hintText: 'اكتب رسالتك هنا...',
                    prefixIcon: const Icon(Icons.message),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: WhatsAppColors.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الرسالة';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                // Send button
                BlocBuilder<WhatsAppCubit, WhatsAppState>(
                  builder: (context, state) {
                    final isSending =
                        state.status == WhatsAppStatus.sendingMessage;
                    return ElevatedButton(
                      onPressed: isSending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WhatsAppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: isSending
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 20.r),
                                SizedBox(width: 8.w),
                                Text(
                                  _isBulkMode ? 'إرسال للجميع' : 'إرسال',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bulk Job Detail Screen
// Bulk Job Detail Screen
class BulkJobDetailScreen extends StatefulWidget {
  final WhatsAppBulkJob job;

  const BulkJobDetailScreen({
    super.key,
    required this.job,
  });

  @override
  State<BulkJobDetailScreen> createState() => _BulkJobDetailScreenState();
}

class _BulkJobDetailScreenState extends State<BulkJobDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.job.jobId != null) {
      context.read<WhatsAppCubit>().fetchBulkJobDetails(widget.job.jobId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: WhatsAppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: WhatsAppColors.darkGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تفاصيل الرسالة الجماعية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<WhatsAppCubit, WhatsAppState>(
          builder: (context, state) {
            final job = state.currentBulkJobDetails?.job ?? widget.job;
            final recipients = state.currentBulkJobDetails?.recipients ?? [];
            final isLoading =
                state.status == WhatsAppStatus.loadingBulkJobDetails;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          WhatsAppColors.primaryGreen),
                    ),
                  // Job Info Card
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                gradient: WhatsAppColors.headerGradient,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.campaign_rounded,
                                color: Colors.white,
                                size: 24.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.jobName ?? 'رسالة جماعية',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: WhatsAppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _getStatusColor(job).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      job.status ?? 'غير معروف',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(job),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (job.message != null && job.message!.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Divider(color: Colors.grey.shade200),
                          SizedBox(height: 16.h),
                          Text(
                            'محتوى الرسالة:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              job.message!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: WhatsAppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Statistics Card
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإحصائيات',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: WhatsAppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            _buildDetailStatItem(
                              icon: Icons.people_outline,
                              label: 'إجمالي المستلمين',
                              value: '${job.totalRecipients}',
                              color: WhatsAppColors.primaryGreen,
                            ),
                            SizedBox(width: 12.w),
                            _buildDetailStatItem(
                              icon: Icons.check_circle_outline,
                              label: 'تم الإرسال',
                              value: '${job.sentCount}',
                              color: Colors.green,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildDetailStatItem(
                              icon: Icons.error_outline,
                              label: 'فشل',
                              value: '${job.failedCount}',
                              color: Colors.red,
                            ),
                            SizedBox(width: 12.w),
                            _buildDetailStatItem(
                              icon: Icons.pending_outlined,
                              label: 'قيد الانتظار',
                              value: '${job.pendingCount}',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: LinearProgressIndicator(
                            value: job.totalRecipients > 0
                                ? job.sentCount / job.totalRecipients
                                : 0,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(job),
                            ),
                            minHeight: 8.h,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'تم إرسال ${job.totalRecipients > 0 ? ((job.sentCount / job.totalRecipients) * 100).toStringAsFixed(1) : '0'}% من الرسائل',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Timing Information Card
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معلومات التوقيت',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: WhatsAppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        if (job.startedAt != null)
                          _buildTimeInfo(
                            icon: Icons.play_circle_outline,
                            label: 'وقت البدء',
                            value: _formatDateTime(job.startedAt!),
                          ),
                        if (job.completedAt != null) ...[
                          SizedBox(height: 12.h),
                          _buildTimeInfo(
                            icon: Icons.check_circle_outline,
                            label: 'وقت الانتهاء',
                            value: _formatDateTime(job.completedAt!),
                          ),
                        ],
                        SizedBox(height: 12.h),
                        _buildTimeInfo(
                          icon: Icons.timer_outlined,
                          label: 'التأخير بين الرسائل',
                          value: '${job.delayBetweenMessagesMs} ملي ثانية',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  if (recipients.isNotEmpty) ...[
                    Text(
                      'المستلمين (${recipients.length})',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: WhatsAppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipients.length,
                      itemBuilder: (context, index) {
                        final recipient = recipients[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.grey.shade600,
                                  size: 20.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipient.phoneNumber,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: WhatsAppColors.textPrimary,
                                      ),
                                    ),
                                    if (recipient.sentAt != null)
                                      Text(
                                        _formatDateTime(recipient.sentAt!),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _getRecipientStatusColor(recipient.status)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  recipient.status,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getRecipientStatusColor(
                                        recipient.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Job IDs Card
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.r, color: color),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: WhatsAppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(
            icon,
            color: WhatsAppColors.primaryGreen,
            size: 20.r,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: WhatsAppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: WhatsAppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(WhatsAppBulkJob job) {
    switch (job.status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'running':
      case 'inprogress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return WhatsAppColors.primaryGreen;
    }
  }

  Color _getRecipientStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
      case 'read':
      case 'delivered':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
      case 'queued':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
