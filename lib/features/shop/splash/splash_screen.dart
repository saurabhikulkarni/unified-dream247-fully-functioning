import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;
import 'package:unified_dream247/core/services/token_service.dart';
import 'package:unified_dream247/core/constants/api_constants.dart';

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
      final authService = core_auth.AuthService();
      await authService.initialize();
      
      // Check unified login status from local storage
      final isLoggedIn = await authService.isLoggedIn();
      final token = authService.getAuthToken();
      final userId = await authService.getUserId();

      if (!mounted) return;

      // ✅ PERSISTENT SESSION: User stays logged in unless they explicitly logout
      if (isLoggedIn && userId != null && userId.isNotEmpty) {
        debugPrint('✅ User session found - maintaining login');
        debugPrint('👤 User ID: ${userId.substring(0, userId.length > 10 ? 10 : userId.length)}...');
        
        // Start token refresh timer if token exists
        if (token != null && token.isNotEmpty) {
          debugPrint('🔑 Token present - starting refresh timer');
          final tokenService = TokenService();
          tokenService.startTokenRefreshTimer(token);
          
          // Try to validate/refresh token in background (non-blocking)
          _refreshTokenInBackground(authService, token);
        } else {
          debugPrint('⚠️ No token but user session exists - will refresh on next API call');
        }
        
        debugPrint('🚀 Navigating to home (persistent session)');
        context.go(RouteNames.home);
      } else {
        debugPrint('❌ No active session - redirecting to login');
        context.go(RouteNames.login);
      }
    } catch (e) {
      debugPrint('⚠️ Navigation error: $e');
      // Even on error, check if we have local session data
      try {
        final authService = core_auth.AuthService();
        await authService.initialize();
        final isLoggedIn = await authService.isLoggedIn();
        
        if (mounted) {
          if (isLoggedIn) {
            debugPrint('🔄 Error occurred but session exists - going to home');
            context.go(RouteNames.home);
          } else {
            context.go(RouteNames.login);
          }
        }
      } catch (_) {
        if (mounted) {
          context.go(RouteNames.login);
        }
      }
    }
  }

  /// Refresh token in background without blocking navigation
  Future<void> _refreshTokenInBackground(core_auth.AuthService authService, String token) async {
    try {
      debugPrint('🔄 [BACKGROUND] Attempting token refresh...');
      final newToken = await authService.refreshAccessToken();
      if (newToken != null) {
        debugPrint('✅ [BACKGROUND] Token refreshed successfully');
      } else {
        debugPrint('⚠️ [BACKGROUND] Token refresh returned null - will retry on next API call');
      }
    } catch (e) {
      debugPrint('⚠️ [BACKGROUND] Token refresh failed: $e - will retry on next API call');
      // Don't logout - let the API interceptor handle token refresh on demand
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
