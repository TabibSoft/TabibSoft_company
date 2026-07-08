import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

class GuestPromoScreen extends StatefulWidget {
  const GuestPromoScreen({super.key});

  @override
  State<GuestPromoScreen> createState() => _GuestPromoScreenState();
}

class _GuestPromoScreenState extends State<GuestPromoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String urlString,
      {bool isPhone = false, bool isWhatsapp = false}) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: (isPhone || isWhatsapp)
              ? LaunchMode.platformDefault
              : LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching $urlString: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F8FA),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 280.h,
                floating: false,
                pinned: true,
                backgroundColor: AppColor.primaryColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient Overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primaryColor,
                              Color(0xFF104D9D),
                              Color(0xFF20AAC9),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                      ),
                      // Decorative background bubbles
                      Positioned(
                        top: -50.h,
                        left: -50.w,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child:
                                  Opacity(opacity: 0.05 * value, child: child),
                            );
                          },
                          child: Container(
                            width: 200.w,
                            height: 200.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30.h,
                        right: -30.w,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child:
                                  Opacity(opacity: 0.07 * value, child: child),
                            );
                          },
                          child: Container(
                            width: 150.w,
                            height: 150.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Center Logo & Title
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40.h),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Hero(
                              tag: 'company_logo_promo',
                              child: Container(
                                height: 100.h,
                                padding: EdgeInsets.all(8.r),
                                child: Image.asset(
                                  'assets/images/pngs/TS_Logo0.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'طبيب سوفت - TabibSoft',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'شريكك الذكي في التحول الرقمي الطبي والمؤسسي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColor.secondaryColor,
                    indicatorWeight: 3.h,
                    labelColor: AppColor.primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: 'منتجاتنا'),
                      Tab(text: 'خدماتنا'),
                      Tab(text: 'تواصل معنا'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildProductsTab(),
              _buildServicesTab(),
              _buildContactTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    final products = [
      {
        'title': 'طبيب سوفت للعيادات والمراكز الطبية',
        'desc':
            'نظام متكامل لإدارة العيادات والمستوصفات الطبية، يشمل الملف الطبي الإلكتروني للمريض (EHR)، الحجوزات والمواعيد، الفواتير والتأمين الطبي، وتقارير أداء الأطباء.',
        'image': 'assets/images/pngs/tabibLogo.png',
        'tag': 'الأكثر طلباً',
      },
      {
        'title': 'نظام إدارة علاقات العملاء CRM',
        'desc':
            'أداة ذكية لمتابعة العملاء والمبيعات وطلبات الدعم الفني، وربط أقسام الشركة المختلفة لتحسين تجربة العملاء وزيادة الإنتاجية.',
        'image': 'assets/images/pngs/TabibSoft CRM.png',
        'tag': 'ذكي ومتكامل',
      },
      {
        'title': 'طبيب سوفت للصيدليات ومستودعات الأدوية',
        'desc':
            'إدارة كاملة للمخازن والبيع بالتجزئة، تنبيهات لتواريخ الصلاحية، الجرد التلقائي، وإدارة حسابات الموردين والعملاء.',
        'image': 'assets/images/pngs/specialization.png',
        'tag': 'سريع ودقيق',
      },
      {
        'title': 'نظام المعامل ومراكز الأشعة LIS / RIS',
        'desc':
            'ربط أجهزة التحليل المخبرية والأشعة، إصدار النتائج المباشرة مع الباركود، وإرسال التقارير والنتائج للمرضى إلكترونياً.',
        'image': 'assets/images/pngs/technical_support.png',
        'tag': 'تكنولوجيا متطورة',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      physics: const BouncingScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return FadeInSlide(
          index: index,
          child: Card(
            margin: EdgeInsets.only(bottom: 16.h),
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Image.asset(
                          prod['image'] as String,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color:
                                    AppColor.secondaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                prod['tag'] as String,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD48100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: Colors.grey[200]),
                  SizedBox(height: 8.h),
                  Text(
                    prod['desc'] as String,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.5.sp,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    final services = [
      {
        'title': 'تخصيص وتطوير الأنظمة',
        'desc':
            'نقوم بتعديل وبناء الميزات البرمجية خصيصاً لتناسب دورة العمل الخاصة بمؤسستك الطبية أو التجارية.',
        'image': 'assets/images/pngs/developers.png',
      },
      {
        'title': 'الدعم الفني المباشر 24/7',
        'desc':
            'فريق دعم فني متكامل متواجد على مدار الساعة لحل المشكلات وضمان استمرارية العمل دون انقطاع.',
        'image': 'assets/images/pngs/technical_support.png',
      },
      {
        'title': 'التدريب والاستشارات الفنية',
        'desc':
            'جلسات تدريبية شاملة للموظفين والأطباء على استخدام الأنظمة مع تقديم استشارات لتحسين الكفاءة التشغيلية.',
        'image': 'assets/images/pngs/manager.png',
      },
      {
        'title': 'النسخ الاحتياطي والأمان',
        'desc':
            'حفظ بياناتك بشكل دوري وتأمينها بأعلى معايير التشفير لحمايتها من الفقدان أو الاختراق.',
        'image': 'assets/images/pngs/earth.png',
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final serv = services[index];
        return FadeInSlide(
          index: index,
          child: Card(
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppColor.secondaryColor.withOpacity(0.08),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Image.asset(
                        serv['image'] as String,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    serv['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: Text(
                      serv['desc'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          FadeInSlide(
            index: 0,
            child: Card(
              elevation: 0,
              color: AppColor.primaryColor.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                    color: AppColor.primaryColor.withOpacity(0.1), width: 1),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Icon(Icons.contact_support,
                        color: AppColor.primaryColor, size: 40.r),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'يسعدنا دائماً تواصلك معنا',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'اختر وسيلة التواصل المناسبة لك وسنقوم بالرد عليك في أسرع وقت.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          FadeInSlide(
            index: 1,
            child: Text(
              'قنوات التواصل المباشر',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Contact Items List
          FadeInSlide(
            index: 2,
            child: _buildContactButton(
              label: 'اتصال هاتفي مباشر',
              subtitle: '+201143377263',
              icon: Image.asset(
                'assets/images/pngs/icons/mobile.png',
                width: 22.w,
                height: 22.h,
                fit: BoxFit.contain,
              ),
              color: const Color(0xFF104D9D),
              onTap: () => _launchURL('tel:+201143377263', isPhone: true),
            ),
          ),
          FadeInSlide(
            index: 3,
            child: _buildContactButton(
              label: 'واتساب - WhatsApp',
              subtitle: 'راسلنا مباشرة عبر واتساب',
              icon: Image.asset(
                'assets/images/pngs/icons/social.png',
                width: 22.w,
                height: 22.h,
                fit: BoxFit.contain,
              ),
              color: const Color(0xFF25D366),
              onTap: () =>
                  _launchURL('https://wa.me/201143377263', isWhatsapp: true),
            ),
          ),

          SizedBox(height: 20.h),
          FadeInSlide(
            index: 4,
            child: Text(
              'موقعنا وحساباتنا الاجتماعية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Social icons / grid
          FadeInSlide(
            index: 5,
            child: Row(
              children: [
                Expanded(
                  child: _buildSocialCard(
                    imagePath: 'assets/images/pngs/icons/web-link.png',
                    title: 'موقعنا الإلكتروني',
                    onTap: () => _launchURL('https://tabibsoft.com/'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSocialCard(
                    imagePath: 'assets/images/pngs/icons/facebook.png',
                    title: 'فيسبوك',
                    onTap: () =>
                        _launchURL('https://www.facebook.com/tabibsoft'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          FadeInSlide(
            index: 6,
            child: Row(
              children: [
                Expanded(
                  child: _buildSocialCard(
                    imagePath: 'assets/images/pngs/icons/instagram.png',
                    title: 'إنستغرام',
                    onTap: () =>
                        _launchURL('https://www.instagram.com/tabibsoft'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSocialCard(
                    imagePath: 'assets/images/pngs/location.png',
                    title: 'موقعنا على الخريطة',
                    onTap: () =>
                        _launchURL('https://maps.app.goo.gl/wqN12thW4DPmQxjg8'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required String label,
    required String subtitle,
    required Widget icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: icon,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        trailing:
            Icon(Icons.arrow_back_ios_new, size: 16.r, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildSocialCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 40.w,
              height: 40.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FadeInSlide extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeInSlide({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 120)),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
