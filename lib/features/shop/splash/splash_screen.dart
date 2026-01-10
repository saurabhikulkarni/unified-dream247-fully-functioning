import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';

/// Shop splash screen - checks authentication and navigates accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    try {
      final authService = AuthService();
      final isLoggedIn = await authService.isUnifiedLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        // User is logged in, navigate to shop home
        context.go('/shop/home');
      } else {
        // User not logged in, navigate to shop login (keeping it simple for now)
        // In a full implementation, this would go to onboarding first
        context.go('/shop/home'); // For now, go to home which has its own entry point
      }
    } catch (e) {
      // On error, navigate to shop home
      if (mounted) {
        context.go('/shop/home');
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
                          Icons.shopping_bag,
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
                        style: const TextStyle(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
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
