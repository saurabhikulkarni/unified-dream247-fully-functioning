import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _displayedText = '';
  bool _typingDone = false;
  bool _isHoldingD = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation - fades in from 0 to 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Scale animation - scales from 0.8 to 1.0
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation
    _animationController.forward();

    // Typing animation for DREAM 247
    _typeText();

    // Check for existing session and navigate accordingly
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for typing to complete, then hold a little longer for tagline
    while (!_typingDone) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final authService = AuthService();
      // 🔗 UNIFIED AUTH: Check unified login for Shop & Fantasy
      final isLoggedIn = await authService.isUnifiedLoggedIn();
      final userId = await authService.getUnifiedUserId();

      if (!mounted) return;

      if (isLoggedIn && userId != null && userId.isNotEmpty) {
        debugPrint('✅ User already logged in with unified auth');
        debugPrint('👤 User ID: $userId');
        debugPrint('🚀 Navigating to unified home');
        context.go(RouteNames.home);
      } else {
        debugPrint('❌ No active session - redirecting to login');
        context.go(RouteNames.login);
      }
    } catch (e) {
      debugPrint('⚠️ Navigation error: $e');
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  void _typeText() async {
    const String fullText = 'DREAM247';
    const int holdFirstMs = 1200; // longer hold on "D"
    const int perCharMs = 140; // slower reveal for remaining letters

    // Show D immediately and highlight while holding
    setState(() {
      _displayedText = 'D';
      _isHoldingD = true;
    });
    await Future.delayed(const Duration(milliseconds: holdFirstMs));

    if (!mounted) return;
    setState(() {
      _isHoldingD = false;
    });

    // Continue typing the remaining letters
    for (int i = 1; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: perCharMs));
      if (!mounted) return;
      setState(() {
        _displayedText = fullText.substring(0, i + 1);
      });
    }

    if (!mounted) return;
    setState(() {
      _typingDone = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6441A5),
              Color(0xFF472575),
              Color(0xFF2A0845),
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // DREAM 247 Typing Animation with Racing Hard font
                  AnimatedScale(
                    scale: _isHoldingD ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Text(
                      _displayedText,
                      style: TextStyle(
                        fontFamily: 'Racing Hard',
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3.0,
                        shadows: [
                          Shadow(
                            blurRadius: _isHoldingD ? 18 : 10,
                            color: Colors.black.withOpacity(0.35),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tagline appears only after typing completes
                  Visibility(
                    visible: _typingDone,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: const Text(
                      'Premium Shopping Experience',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta',
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Loading indicator
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 3,
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
}
