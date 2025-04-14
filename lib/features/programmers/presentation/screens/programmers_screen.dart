import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';

class ProgrammersScreen extends StatefulWidget {
  const ProgrammersScreen({super.key});

  @override
  State<ProgrammersScreen> createState() => _ProgrammersScreenState();
}

class _ProgrammersScreenState extends State<ProgrammersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'المبرمجين ',
                height: 332,
                leading: IconButton(
                  icon: Image.asset('assets/images/pngs/back.png',
                      width: 30, height: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.23,
              left: size.width * 0.05,
              right: size.width * 0.05,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF56C7F1), width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<EngineerCubit, EngineerState>(
                    builder: (context, state) {
                      if (state.status == EngineerStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.status == EngineerStatus.success) {
                        return ListView.builder(
                          itemCount: state.engineers.length,
                          itemBuilder: (context, index) {
                            final engineer = state.engineers[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  engineer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(engineer.address),
                                trailing: Text(engineer.telephone),
                              ),
                            );
                          },
                        );
                      } else if (state.status == EngineerStatus.failure) {
                        return Center(
                          child: Text(state.errorMessage ?? 'حدث خطأ أثناء جلب البيانات'),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(
          items: [
            GestureDetector(
              onTap: () {},
              child: Image.asset('assets/images/pngs/push_notification.png',
                  width: 35, height: 35),
            ),
            const SizedBox(),
            GestureDetector(
              onTap: () {},
              child: Image.asset('assets/images/pngs/calendar.png',
                  width: 35, height: 35),
            ),
          ],
          alignment: MainAxisAlignment.spaceBetween,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }
}
