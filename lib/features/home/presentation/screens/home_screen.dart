import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/nav_bar/settings.dart';
import 'package:tabib_soft_company/features/management/presentation/screens/management_screen.dart';
import 'package:tabib_soft_company/features/programmers/presentation/screens/programmers_screen.dart';
import 'package:tabib_soft_company/features/sales/presentation/screens/sales_home_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_screen.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const Color primaryColor = Color(0xFF56C7F1);
  static const Color secondaryColor = Color(0xFF75D6A9);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const navBarHeight = 60.0;
    final userName = CacheHelper.getString(key: 'userName');
    final userRoles = CacheHelper.getString(key: 'userRoles').isNotEmpty
        ? CacheHelper.getString(key: 'userRoles').split(',')
        : [];

    String appBarTitle;
    if (userRoles.contains('ADMIN') || userRoles.contains('MANAGEMENT')) {
      appBarTitle =
          'المدير مدير بردو ${userName.isNotEmpty ? userName : 'المستخدم'}';
    } else if (userRoles.contains('SALSE')) {
      appBarTitle =
          'الفرخه اللي مش بتبيض بتتعمل شاورما يا ${userName.isNotEmpty ? userName : 'المستخدم'}';
    } else if (userRoles.contains('PROGRAMMERS')) {
      appBarTitle =
          'قهوتك وولع الدنيا يا${userName.isNotEmpty ? userName : 'المستخدم'}';
    } else if (userRoles.contains('SUPPORT')) {
      appBarTitle = 'وحش الدعم  ${userName.isNotEmpty ? userName : 'المستخدم'}';
    } else {
      appBarTitle =
          'شوف شغلك يا ${userName.isNotEmpty ? userName : 'المستخدم'}';
    }

    final jokes = [
      "اجمد كدا مفيش مهندس بيعيط 😎",
      'الtester لما بيغرق بيقول Bug Bug Bug 🐛',
      'ليه المبرمج مش بيخاف؟ لأنه متعود على الكراش 💥',
      'الدعم الفني دايمًا بيحلها... حتى لو بالكلام بس 😎',
      'لو التطبيق وقع؟ قوله قوم اشتغل هيبقا زي الفل  👀',
      'المبيعات؟ دول بيبيعوا الهوا في قزايز 🧃',
      'المبرمج بيصحى من النوم يفتح Git 😴',
      'لو الدنيا لخبطة، اعمل Clean Project 🧹',
      'المبيعات من شطارتهم باعونا 😡',
      'لو مش لاقي Bug، يبقى هو مستخبي 🐞',
      'فيه زر بيعمل كل حاجة... بس محدش عارف هو فين 🤷‍♂️',
      'المبيعات: “وقعنا العميل... في حب المنتج” 💘',
      'الدعم بيحلها بالحب ❤️',
      'المبرمج لما يسمع كلمة "Deadline" بيعرق 😰',
      'عايز تعيش مرتاح؟ خليك بعيد عن الكود 💻',
      'المدير قالك روح بدري؟ أكيد في حاجة غلط 😨',
    ];
    final randomJoke = (jokes..shuffle()).first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFloatingJoke(context, randomJoke);
    });

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
                logoAsset: 'assets/images/pngs/tabibLogo.png',
                title: appBarTitle,
                height: 480,
              ),
            ),
            Positioned.fill(
              top: 0,
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * 0.35,
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    bottom: navBarHeight - 59.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 95, 93, 93)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.4,
                    left: size.width * 0.1,
                    right: size.width * 0.1,
                    bottom: navBarHeight + 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/manager.png',
                          'الإدارة',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManagementScreen(),
                              ),
                            );
                          },
                          userRoles.contains('MANAGEMENT') ||
                              userRoles.contains('ADMIN'),
                        ),
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/developers.png',
                          'المبرمجين',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProgrammersScreen(),
                              ),
                            );
                          },
                          userRoles.contains('PROGRAMMERS') ||
                              userRoles.contains('ADMIN'),
                        ),
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/technical_support.png',
                          'الدعم الفني',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TechnicalSupportScreen(),
                              ),
                            );
                          },
                          userRoles.contains('SUPPORT') ||
                              userRoles.contains('ADMIN'),
                        ),
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/sales.png',
                          'مبيعات',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SalesHomeScreen(),
                              ),
                            );
                          },
                          userRoles.contains('SALSE') ||
                              userRoles.contains('ADMIN'),
                        ),
                      ],
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
              child: Image.asset(
                'assets/images/pngs/list.png',
                width: 33,
                height: 33,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              ),
              child: Image.asset(
                'assets/images/pngs/settings.png',
                width: 33,
                height: 33,
              ),
            ),
          ],
          alignment: MainAxisAlignment.spaceBetween,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onTap,
    bool enabled,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width * 0.60,
      child: HomeButton(
        iconPath: iconPath,
        label: label,
        onTap: onTap,
        enabled: enabled,
      ),
    );
  }

  void _showFloatingJoke(BuildContext context, String joke) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    final entry = OverlayEntry(
      builder: (context) {
        return _FloatingJokeBubble(joke: joke);
      },
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 5), () {
      entry.remove();
    });
  }
}

class _FloatingJokeBubble extends StatefulWidget {
  final String joke;

  const _FloatingJokeBubble({required this.joke});

  @override
  State<_FloatingJokeBubble> createState() => _FloatingJokeBubbleState();
}

class _FloatingJokeBubbleState extends State<_FloatingJokeBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                )
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              widget.joke,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HomeButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const HomeButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  static const Color primaryColor = HomeScreen.primaryColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: enabled ? onTap : () => _showToast(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[300],
          border: Border.all(color: primaryColor, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: size.width * 0.1,
              height: size.width * 0.1,
              color: enabled ? null : Colors.grey,
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: enabled ? Colors.grey[800] : Colors.grey,
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToast(BuildContext context) {
    final responses = [
      'إنت بتعمل إيه هنا؟ 😅',
      'لو ضغطت تاني هنبلغ الإدارة 😂',
      'ده مش ليك يا نجم 🤭',
      'حاول في مكان تاني يا بطل 🕵️‍♂️',
    ];
    final random = Random().nextInt(responses.length);
    Fluttertoast.showToast(
      msg: responses[random],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
