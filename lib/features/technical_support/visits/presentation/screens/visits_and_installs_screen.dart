import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/visit_card.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_state.dart';

class VisitsAndInstallsScreen extends StatelessWidget {
  const VisitsAndInstallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const mainBlueColor = Color(0xFF16669E);
    const sheetColor = Color(0xFFF5F7FA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: mainBlueColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: sheetColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: BlocProvider(
                    create: (_) => ServicesLocator.visitCubit..loadVisits(),
                    child: BlocBuilder<VisitCubit, VisitState>(
                      builder: (context, state) {
                        // Pull to Refresh
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<VisitCubit>().loadVisits();
                            // ننتظر حتى يكتمل التحميل (اختياري)
                            await context.read<VisitCubit>().stream.firstWhere(
                                (s) => s.status != VisitStatus.loading);
                          },
                          color: mainBlueColor,
                          backgroundColor: Colors.white,
                          child: _buildBody(state),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        child: Text(
          state.errorMessage ?? "حدث خطأ",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.visits.isEmpty) {
      return const Center(child: Text("لا توجد زيارات حالياً"));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 80),
      itemCount: state.visits.length,
      itemBuilder: (context, index) {
        final visit = state.visits[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 12.0), // مسافات أكبر بين الكروت
          child: VisitCard(visit: visit),
        );
      },
    );
  }
}
