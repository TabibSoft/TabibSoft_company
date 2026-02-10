// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_features_grid.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_header.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_notification_button.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_settings_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = AppColor.primaryColor;
  static const Color accentColor = AppColor.accentColor;
  static const Color lightBg = AppColor.lightBg;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = CacheHelper.getString(key: 'userName');
    final rawRoles = CacheHelper.getString(key: 'userRoles');
    final userRoles = (rawRoles.isNotEmpty) ? rawRoles.split(',') : <String>[];

    final bool isAdmin = userRoles.contains('ADMIN');
    final bool isModerator = userRoles.contains('MODERATOR');
    final bool isTracker = userRoles.contains('TRACKER');

    // تحديد العنوان بناءً على الصلاحيات مع المسميات المطلوبة
    final name = userName.isNotEmpty ? userName : 'المستخدم';
    final seed =
        DateTime.now().day + DateTime.now().month * 31 + DateTime.now().year;
    String title;

    if (isAdmin || userRoles.contains('MANAGEMENT')) {
      final msgs = [
        'صباح الفلوس يا $name 👑💰',
        'الكبير كبير يا $name 👑',
        'الإدارة نورت يا $name 🌟',
        'يا مدير الدنيا $name 🚀👑',
        'الباشا $name وصل 🎩👑',
        'أهلاً بصاحب القرار $name 💎',
      ];
      title = msgs[seed % msgs.length];
    } else if (userRoles.contains('SALESADMIN')) {
      final msgs = [
        'مدير المبيعات $name نور 🚀👑',
        'كابتن السيلز $name جاهز 🏆',
        'أبو الخطط $name.. يلا نكسر التارجت 📈👑',
        'مايسترو المبيعات $name وصل 🎵🤑',
        'يا $name النهارده فريقك هيكسرها 🔥🚀',
        'يا $name.. خلي الأرقام تتكلم 🎯💼',
      ];
      title = msgs[seed % msgs.length];
    } else if (userRoles.contains('SALSE')) {
      final msgs = [
        'السيلز اللعيب $name جاهز يكسر الدنيا 🎯',
        'يلا يا $name ورينا الشطارة 💪🔥',
        'ملك الديلز $name وصل 🤑',
        'البياع الشاطر $name يلا بينا 🚀',
        'يا $name النهارده هنكسر التارجت 📈',
        '$name.. كل عميل بيحلم بيك 😂🎯',
        'سيلز الأحلام $name جاهز 💰',
        'يا $name خليك كده حلو وبيع كتير 😎🤝',
        'النهارده يومك يا $name.. يلا نبيع 🏅',
        'عم الديلات $name.. يلا الشغل مستنيك 🎯💼',
      ];
      title = msgs[seed % msgs.length];
    } else if (userRoles.contains('PROGRAMMER')) {
      final msgs = [
        'وحش الكودينج $name جاهز 💻🔥',
        'يلا يا $name نكتب كود يهز الدنيا 🚀',
        'الديفلوبر الخطير $name وصل 👨‍💻',
        '$name.. البج اللي هربت مستنياك 🐛😂',
        'يا $name النهارده من غير bugs إن شاء الله 🙏💻',
        'الهاكر الطيب $name نور 😎⌨️',
        'يلا يا $name.. compile and conquer 🏆💻',
        'أسطورة الـ Stack Overflow  يا $name 🤓',
        'سوبرمان الكود $name.. يلا بينا 🦸‍♂️💻',
      ];
      title = msgs[seed % msgs.length];
    } else if (userRoles.contains('SUPPORT')) {
      final msgs = [
        'بطل الدعم $name جاهز ينقذ الموقف 🛠️',
        'يا $name عكننت ع المبرمجين النهارده!!🦸‍♂️',
        'سوبر سابورت $name وصل 💪',
        '$name.. حامي حمى العملاء 🛡️',
        
        'يلا يا $name نخلّي كل عميل مبسوط 😊🛠️',
        'دكتور المشاكل $name حاضر 🩺',
        'يا $name.. أنت الخط الأول للدفاع 🏰',
        '$name سابورت هيرو اليوم 🎖️🛠️',
        'يلا يا $name نعكنن ع المبرمجين!🤝',
       
      ];
      title = msgs[seed % msgs.length];
    } else if (isModerator) {
      final msgs = [
        'الوسيط الدبلوماسي $name وصل 🤝',
        'يا $name يلا نظبّط الأمور 💼',
        '$name .. الميزان بتاع الشغل ⚖️',
        'أبو الحلول $name حاضر 🧠🤝',
        'يلا يا $name نوصّل كل حاجة لبر الأمان 🚢',
        'المحترم $name نور المكان 🌟🤝',
        '$name ماسك الخيوط كلها 🎭',
        'يا $name.. بدونك الدنيا تتلخبط 😂🤝',
        'صانع السلام $name وصل ☮️',
        'أهلاً بالوسيط الذهبي $name 🏅',
      ];
      title = msgs[seed % msgs.length];
    } else if (isTracker) {
      final msgs = [
        'ملك المتابعة $name جاهز 🚀',
        'يا $name مفيش حاجة بتفوتك 🔍',
        'العين الساهرة $name وصلت 👁️',
        '$name.. GPS بشري ما شاء الله 📡😂',
        'يلا يا $name تابع وهات النتيجة 📊',
        'المتابع الأسطورة $name حاضر 🏆',
        '$name شغّال رادار النهارده 📡🔥',
        'يا $name خليك ورا كل حاجة 🎯',
        'أبو المتابعة $name.. يلا بينا 🚀📋',
        'الكل تحت عينك يا $name 👀🔥',
      ];
      title = msgs[seed % msgs.length];
    } else {
      final msgs = [
        'أهلاً $name.. يوم جميل يا رب 👋',
        'نورت يا $name 🌟',
        'يلا يا $name نبدأ يومنا 💪',
        'صباح الخير يا $name ☀️',
        '$name.. مبسوطين إنك معانا 🤗',
        'أهلاً وسهلاً يا $name 🎉',
        'يومك حلو يا $name إن شاء الله 🌸',
        'حمد لله على السلامة يا $name 👋😊',
      ];
      title = msgs[seed % msgs.length];
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: HomeScreen.lightBg,
        body: Stack(
          children: [
            // Subtle Animated Background Elements
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: 100 + (20 * _bgController.value),
                      left: -50 + (10 * _bgController.value),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: TechColors.accentCyan.withOpacity(0.04),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 200 - (30 * _bgController.value),
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: TechColors.primaryMid.withOpacity(0.03),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            Stack(
              children: [
                // الخلفية العلوية
                HomeHeader(title: title),

                // زر الإعدادات
                const HomeSettingsButton(),

                // زر الإشعارات مع النقطة الحمراء
                const HomeNotificationButton(),

                // Grid الأزرار //
                HomeFeaturesGrid(userRoles: userRoles),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
