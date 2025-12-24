import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/adhkar_info_card.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/daily_motivation_dialog.dart';

class AdhkarGlobalOverlay extends StatefulWidget {
  final Widget child;

  const AdhkarGlobalOverlay({super.key, required this.child});

  static bool _hasShownDailyMotivation = false;

  @override
  State<AdhkarGlobalOverlay> createState() => _AdhkarGlobalOverlayState();
}

class _AdhkarGlobalOverlayState extends State<AdhkarGlobalOverlay>
    with TickerProviderStateMixin {
  Timer? _adhkarTimer;
  Timer? _dismissAdhkarTimer;
  bool _showAdhkar = false;
  String _currentAdhkar = '';
  Map<String, dynamic>? _jsonData;

  // Motivation Dialog State
  bool _showMotivation = false;
  String _motivationMessage = '';

  // Animation controllers for Adhkar
  late AnimationController _adhkarSlideController;
  late Animation<Offset> _adhkarSlideAnimation;

  @override
  void initState() {
    super.initState();
    _loadJsonData();

    // Setup Adhkar Animation
    _adhkarSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _adhkarSlideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0), // Start slightly off-screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _adhkarSlideController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    ));

    // Schedule Daily Motivation Popup & First Adhkar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AdhkarGlobalOverlay._hasShownDailyMotivation) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _jsonData != null) {
            _prepareDailyMotivation();
            AdhkarGlobalOverlay._hasShownDailyMotivation = true;
          } else if (mounted) {
            // Retry shortly if data isn't ready
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                _prepareDailyMotivation();
                AdhkarGlobalOverlay._hasShownDailyMotivation = true;
              }
            });
          }
        });
      }

      // Trigger first Adhkar after 15 seconds
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && !_showAdhkar && _jsonData != null) {
          _triggerAdhkarPopup();
        }
      });
    });

    // Schedule Adhkar Popup every 3 minutes
    _adhkarTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (mounted) {
        _triggerAdhkarPopup();
      }
    });

    // Handle motivation shown state update (if needed) to avoid showing it multiple times
    // We use a static variable, so it persists as long as the app is running.
  }

  @override
  void dispose() {
    _adhkarTimer?.cancel();
    _dismissAdhkarTimer?.cancel();
    _adhkarSlideController.dispose();
    super.dispose();
  }

  Future<void> _loadJsonData() async {
    try {
      final String response = await rootBundle
          .loadString('assets/images/svgs/daily-motivation.json');
      setState(() {
        _jsonData = json.decode(response);
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  void _triggerAdhkarPopup() {
    if (_jsonData == null) return;
    final List<dynamic> adhkarList = _jsonData!['adhkar'] ?? [];
    if (adhkarList.isEmpty) return;

    final random = Random();
    setState(() {
      _currentAdhkar = adhkarList[random.nextInt(adhkarList.length)];
      _showAdhkar = true;
    });
    _adhkarSlideController.forward();

    // Auto dismiss after 10 seconds
    _dismissAdhkarTimer?.cancel();
    _dismissAdhkarTimer = Timer(const Duration(seconds: 10), () {
      _dismissAdhkar();
    });
  }

  void _dismissAdhkar() {
    if (!mounted) return;
    _adhkarSlideController.reverse().then((_) {
      setState(() {
        _showAdhkar = false;
      });
    });
  }

  void _prepareDailyMotivation() {
    if (_jsonData == null) return;

    final rawRoles = CacheHelper.getString(key: 'userRoles');
    final userRoles = (rawRoles.isNotEmpty) ? rawRoles.split(',') : <String>[];

    String category = 'Engineer'; // Default
    if (userRoles.contains('SALSE')) {
      category = 'Sales';
    } else if (userRoles.contains('PROGRAMMER')) {
      category = 'Programmer';
    } else if (userRoles.contains('TRACKER')) {
      category = 'FollowUp';
    } else if (userRoles.contains('SUPPORT')) {
      category = 'Engineer';
    } else if (userRoles.contains('MANAGEMENT')) {
      category = 'CallCenter';
    }

    final Map<String, dynamic> motivations = _jsonData!['dailyMotivation'];
    if (!motivations.containsKey(category)) {
      final keys = motivations.keys.toList();
      category = keys[Random().nextInt(keys.length)];
    }

    final List<dynamic> messages = motivations[category] ?? [];
    if (messages.isEmpty) return;

    setState(() {
      _motivationMessage = messages[Random().nextInt(messages.length)];
      _showMotivation = true;
    });
  }

  void _closeMotivation() {
    setState(() {
      _showMotivation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Ensure RTL if needed, or inherit. Usually App sets it.
      // We will assume the passed child handles its directionality,
      // but the overlays might need explicit RTL if they contain Arabic.
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // The main app content
          widget.child,

          // Motivation Dialog Overlay (simulating showDialog)
          if (_showMotivation)
            Positioned.fill(
              child: Stack(
                children: [
                  // Barrier
                  GestureDetector(
                    onTap: _closeMotivation,
                    child: Container(
                      color: Colors.black54,
                    ),
                  ),
                  // Dialog
                  Center(
                    child: DailyMotivationDialog(
                      message: _motivationMessage,
                      onClose: _closeMotivation,
                    ),
                  ),
                ],
              ),
            ),

          // sliding Adhkar Popup
          if (_showAdhkar)
            Positioned(
              top: 150, // Adjustable position
              right: 0,
              child: SlideTransition(
                position: _adhkarSlideAnimation,
                child: AdhkarInfoCard(
                  currentAdhkar: _currentAdhkar,
                  onDismiss: _dismissAdhkar,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
