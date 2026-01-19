import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;
import 'package:unified_dream247/core/services/token_service.dart';

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
      // ✅ PERSISTENT SESSION CHECK
      // Check if user has a valid saved session - DO NOT require OTP again
      final isLoggedIn = await _checkPersistentSession();

      if (!mounted) return;

      if (isLoggedIn) {
        debugPrint('🚀 [SPLASH] Navigating to home (persistent session active)');
        context.go(RouteNames.home);
      } else {
        debugPrint('🔐 [SPLASH] No active session - redirecting to login');
        context.go(RouteNames.login);
      }
    } catch (e) {
      debugPrint('⚠️ [SPLASH] Navigation error: $e');
      // On error, fallback to checking SharedPreferences directly
      if (mounted) {
        final fallbackLoggedIn = await _fallbackSessionCheck();
        if (fallbackLoggedIn) {
          context.go(RouteNames.home);
        } else {
          context.go(RouteNames.login);
        }
      }
    }
  }

  /// Check for persistent session - user should stay logged in until explicit logout
  Future<bool> _checkPersistentSession() async {
    try {
      final authService = core_auth.AuthService();
      await authService.initialize();
      
      // Check login status from SharedPreferences
      final isLoggedIn = await authService.isLoggedIn();
      final userId = authService.getUserId();
      final token = authService.getAuthToken();

      debugPrint('🔍 [SPLASH] Session check:');
      debugPrint('   - isLoggedIn: $isLoggedIn');
      debugPrint('   - userId: ${userId != null ? "${userId.substring(0, userId.length > 10 ? 10 : userId.length)}..." : "null"}');
      debugPrint('   - hasToken: ${token != null && token.isNotEmpty}');

      // ✅ User is logged in if they have a valid session
      // Only require: isLoggedIn flag AND userId
      // Token can be refreshed later if missing
      if (isLoggedIn && userId != null && userId.isNotEmpty) {
        debugPrint('✅ [SPLASH] Valid session found - user stays logged in');
        
        // Start token refresh timer if token exists (background task)
        if (token != null && token.isNotEmpty) {
          debugPrint('🔑 [SPLASH] Token present - starting refresh timer');
          final tokenService = TokenService();
          tokenService.startTokenRefreshTimer(token);
          
          // Try to refresh token in background (non-blocking)
          _refreshTokenInBackground(authService, token);
        } else {
          debugPrint('⚠️ [SPLASH] No token but session exists - will refresh on next API call');
        }
        
        return true;
      }

      debugPrint('❌ [SPLASH] No valid session found');
      return false;
    } catch (e) {
      debugPrint('❌ [SPLASH] Error checking session: $e');
      return false;
    }
  }

  /// Fallback session check using SharedPreferences directly
  Future<bool> _fallbackSessionCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check all possible login keys (for compatibility)
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final userId = prefs.getString('user_id');
      final altUserId = prefs.getString('userId');
      
      debugPrint('🔍 [SPLASH] Fallback session check:');
      debugPrint('   - is_logged_in: $isLoggedIn');
      debugPrint('   - user_id: $userId');
      debugPrint('   - userId: $altUserId');
      
      // User is logged in if flag is set AND we have some user ID
      final hasValidSession = isLoggedIn && 
          ((userId != null && userId.isNotEmpty) || 
           (altUserId != null && altUserId.isNotEmpty));
      
      if (hasValidSession) {
        debugPrint('✅ [SPLASH] Fallback: Valid session found');
      } else {
        debugPrint('❌ [SPLASH] Fallback: No valid session');
      }
      
      return hasValidSession;
    } catch (e) {
      debugPrint('❌ [SPLASH] Fallback check error: $e');
      return false;
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
