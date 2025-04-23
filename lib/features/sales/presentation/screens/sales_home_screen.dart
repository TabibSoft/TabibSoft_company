import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/sales/data/model/sales_model.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/sales_cubit.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/sales_state.dart';
import 'package:tabib_soft_company/features/sales/presentation/screens/details/add_requirement_screen.dart';
import 'package:tabib_soft_company/features/sales/presentation/screens/details/sales_details_screen.dart';
import 'package:tabib_soft_company/features/sales/presentation/screens/instalization/instalization_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/technical_support_nav_bar/notification_screen.dart';

class SalesHomeScreen extends StatefulWidget {
  const SalesHomeScreen({super.key});

  @override
  State<SalesHomeScreen> createState() => _SalesHomeScreenState();
}

class _SalesHomeScreenState extends State<SalesHomeScreen> {
  String selectedPeriod = 'الكل ';
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ServicesLocator.locator<ApiService>();
    context.read<SalesCubit>().fetchMeasurements();
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
                title: 'Sales',
                height: 332,
                leading: IconButton(
                  icon: Image.asset(
                    'assets/images/pngs/back.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.18,
              left: size.width * 0.05,
              right: size.width * 0.05,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff178CBB), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPeriodButton('الكل '),
                    _buildPeriodButton('تم الحجز'),
                    _buildPeriodButton('تعليق'),
                    _buildPeriodButton('الغاء'),
                    _buildPeriodButton('جديد'),
                  ],
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.25,
              left: size.width * 0.05,
              right: size.width * 0.05,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF56C7F1), width: 3),
                ),
                child: BlocBuilder<SalesCubit, SalesState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case SalesStatus.loading:
                        return const Center(child: CircularProgressIndicator());
                      case SalesStatus.loaded:
                        final filteredMeasurements = selectedPeriod == 'الكل '
                            ? state.measurements!
                            : state.measurements!
                                .where((m) => m.statusName == selectedPeriod)
                                .toList();
                        return ListView.builder(
                          itemCount: filteredMeasurements.length,
                          itemBuilder: (context, index) {
                            final measurement = filteredMeasurements[index];
                            return EngineerCard(
                              measurement: measurement,
                              apiService: _apiService,
                            );
                          },
                        );
                      case SalesStatus.error:
                        return Center(child: Text(state.failure!.errMessages));
                      case SalesStatus.initial:
                      default:
                        return const Center(child: Text('No data'));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(
          items: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
              child: Image.asset('assets/images/pngs/push_notification.png',
                  width: 35, height: 35),
            ),
          ],
          alignment: MainAxisAlignment.spaceBetween,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedPeriod = period;
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          selectedPeriod == period ? const Color(0xFF178CBB) : Colors.grey,
        ),
        shape: WidgetStateProperty.all(const StadiumBorder()),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      ),
      child: Text(
        period,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class EngineerCard extends StatelessWidget {
  final SalesModel measurement;
  final ApiService apiService;

  const EngineerCard({
    super.key,
    required this.measurement,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AddRequirementPopup(
            measurementId: measurement.id,
            apiService: apiService,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 242,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF178CBB), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'اسم العميل: ',
                      style: TextStyle(
                        color: Color(0xff178CBB),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: measurement.customerName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'رقم التواصل: ',
                      style: TextStyle(
                        color: Color(0xff178CBB),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: measurement.customerTelephone,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'النشاط: ',
                      style: TextStyle(
                        color: Color(0xff178CBB),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: measurement.proudctName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'الحالة: ',
                      style: TextStyle(
                        color: Color(0xff178CBB),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: measurement.statusName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SalesDetailScreen(
                            measurement: measurement,
                            apiService: apiService,
                          ),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xFF178CBB)),
                      shape: WidgetStateProperty.all(const StadiumBorder()),
                    ),
                    child: const Text(
                      'تفاصيل',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InstalizationScreen(
                           
                          ),
                        ));
                      
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xFF178CBB)),
                      shape: WidgetStateProperty.all(const StadiumBorder()),
                    ),
                    child: const Text(
                      'تسطيب',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
