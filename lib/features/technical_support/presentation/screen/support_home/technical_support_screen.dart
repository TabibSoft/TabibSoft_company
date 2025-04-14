import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/problem/add_problem_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/customer_list_widget.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/search_bar_widget.dart';

class TechnicalSupportScreen extends StatefulWidget {
  const TechnicalSupportScreen({super.key});

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      context.read<CustomerCubit>().fetchProblemStatus();
      context.read<CustomerCubit>().fetchTechSupportIssues();
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    context.read<CustomerCubit>().stream.listen((state) {
      if (state.problemStatusList.isNotEmpty) {
        if (mounted) {
          setState(() {
            _statuses = [
              null,
              ...state.problemStatusList.map((status) => status.name)
            ];
          });
        }
      }
    });
  }

  void _onStatusSelected(String? status) {
    setState(() => _selectedStatus = status);
    context.read<CustomerCubit>().emit(
          context.read<CustomerCubit>().state.copyWith(selectedStatus: status),
        );
  }

  void _showStatusMenu() async {
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

 
  void _navigateToAddProblemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddProblemScreen()),
    );
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
                title: 'الدعم الفني',
                height: 480,
                leading: IconButton(
                  icon: Image.asset('assets/images/pngs/back.png',
                      width: 30, height: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AddProblemScreen()),
                          ),
                          child: Image.asset('assets/images/pngs/plus.png',
                              width: 30, height: 30),
                        ),
                     
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              top: 0,
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * 0.33,
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 95, 93, 93)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor, width: 3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SearchBarWidget(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: CustomerListWidget(
                                searchQuery: _searchQuery,
                                selectedStatus: _selectedStatus,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.25,
                    left: size.width * 0.20,
                    right: size.width * 0.20,
                    child: InkWell(
                      key: _statusKey,
                      onTap: _showStatusMenu,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedStatus ?? 'حالة مشكلة',
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Image.asset('assets/images/pngs/filter.png',
                                width: size.width * 0.08,
                                height: size.width * 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
