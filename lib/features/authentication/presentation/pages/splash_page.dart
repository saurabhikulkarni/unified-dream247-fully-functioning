import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/auth_local_datasource.dart';

/// Splash screen with DREAM247 typing animation and gradient background
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _displayText = '';
  final String _fullText = 'DREAM247';
  int _currentCharIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _startTypingAnimation();
    _checkAuthAndNavigate();
  }

  void _startTypingAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _typeNextCharacter();
    });
  }

  void _typeNextCharacter() {
    if (_currentCharIndex < _fullText.length) {
      setState(() {
        _displayText = _fullText.substring(0, _currentCharIndex + 1);
        _currentCharIndex++;
      });
      
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          _typeNextCharacter();
        }
      });
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for typing animation and fade animation to complete
    print('🔍 SPLASH: Starting auth check');
    await Future.delayed(const Duration(milliseconds: 2500));
    print('🔍 SPLASH: Delay completed');

    if (!mounted) {
      print('🔍 SPLASH: Widget not mounted after delay, returning');
      return;
    }

    try {
      // Check if user is logged in
      print('🔍 SPLASH: Getting AuthLocalDataSource');
      final authLocalDataSource = getIt<AuthLocalDataSource>();
      print('🔍 SPLASH: Checking isLoggedIn');
      final isLoggedIn = await authLocalDataSource.isLoggedIn();
      print('🔍 SPLASH: isLoggedIn = $isLoggedIn');

      if (!mounted) {
        print('🔍 SPLASH: Widget not mounted after auth check, returning');
        return;
      }

      if (isLoggedIn) {
        print('🔍 SPLASH: Navigating to home (${RouteNames.home})');
        context.go(RouteNames.home);
        print('🔍 SPLASH: Navigation to home completed');
      } else {
        print('🔍 SPLASH: Navigating to login (${RouteNames.login})');
        context.go(RouteNames.login);
        print('🔍 SPLASH: Navigation to login completed');
      }
    } catch (e, stackTrace) {
      print('❌ SPLASH ERROR: $e');
      print('❌ SPLASH STACK: $stackTrace');
      // Fallback navigation to login if there's any error
      if (mounted) {
        print('🔍 SPLASH: Error occurred, navigating to login as fallback');
        context.go(RouteNames.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6441A5), // Primary purple
              Color(0xFF472575), // Medium purple
              Color(0xFF2A0845), // Dark purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Typing text animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _displayText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          // Blinking cursor
                          if (_currentCharIndex < _fullText.length)
                            _BlinkingCursor(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Shop & Play',
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Blinking cursor widget for typing animation
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _blinkController,
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _blinkAnimation,
      child: Container(
        width: 3,
        height: 48,
        margin: const EdgeInsets.only(left: 4),
        color: Colors.white,
      ),
    );
  }
}
