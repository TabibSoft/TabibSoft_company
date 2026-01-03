import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/visit_card.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_state.dart';

class VisitsAndInstallsScreen extends StatelessWidget {
  const VisitsAndInstallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TechColors.surfaceLight,
        body: Stack(
          children: [
            // Premium Header Background
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: TechColors.premiumGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
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
                    bottom: 20,
                    left: 20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // AppBar Area
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const Text(
                          "الزيارات والتركيبات",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Placeholder for balance layout
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),

                  // Logo and Summary Area
                  SizedBox(
                    height: 90,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/pngs/TS_Logo0.png',
                              width: 45,
                              height: 45,
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Main Content Container
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: TechColors.surfaceLight,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: TechColors.primaryDark.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: BlocProvider(
                          create: (_) =>
                              ServicesLocator.visitCubit..loadVisits(),
                          child: BlocBuilder<VisitCubit, VisitState>(
                            builder: (context, state) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  context.read<VisitCubit>().loadVisits();
                                  await context
                                      .read<VisitCubit>()
                                      .stream
                                      .firstWhere((s) =>
                                          s.status != VisitStatus.loading);
                                },
                                color: TechColors.accentCyan,
                                backgroundColor: Colors.white,
                                child: _buildBody(state),
                              );
                            },
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
      ),
    );
  }

  Widget _buildBody(VisitState state) {
    if (state.status == VisitStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == VisitStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TechColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 40, color: TechColors.errorRed),
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? "حدث خطأ غير متوقع",
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {}, // Trigger generic retry if possible
              icon: const Icon(Icons.refresh),
              label: const Text("حاول مرة أخرى"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: TechColors.primaryMid,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            )
          ],
        ),
      );
    }

    if (state.visits.isEmpty) {
      return SingleChildScrollView(
        // Allow scroll for refresh
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400, // Approximate height to center
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1), blurRadius: 10)
                      ]),
                  child: Icon(Icons.assignment_turned_in_outlined,
                      size: 60, color: TechColors.accentCyan.withOpacity(0.5)),
                ),
                const SizedBox(height: 20),
                Text(
                  "لا توجد زيارات حالياً",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "اسحب للأسفل للتحديث",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      // Changed to builder for better performance
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 80),
      itemCount: state.visits.length,
      itemBuilder: (context, index) {
        final visit = state.visits[index];
        // Add animation
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration:
              Duration(milliseconds: 300 + (index * 50)), // Staggered animation
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: VisitCard(visit: visit),
        );
      },
    );
  }
}
