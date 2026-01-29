import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/features/shop/screens/auth/views/components/sign_up_form.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  dynamic _signUpFormState;

  @override
  void initState() {
    super.initState();
    // Preload the welcome image to avoid loading delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/images/welcome-min.webp'),
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top hero image: render within SafeArea and avoid fixed cache sizes
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              child: Image.asset(
                'assets/images/welcome-min.webp',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 720, // Limit decoded image size to reduce memory
                cacheHeight: 720,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ [SIGNUP] Image load error: $error');
                  return Container(
                    color: const Color(0xFF6B4099),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s get started!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    'Please enter your valid data in order to create an account.',
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    formKey: _formKey,
                    onFormCreated: (form) {
                      _signUpFormState = form;
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (!_signUpFormState.isTermsAgreed()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please agree to the terms and privacy policy',
                            ),
                          ),
                        );
                        return;
                      }

                      // First verify OTP (backend also creates user in Hygraph)
                      final otpVerified = await _signUpFormState.verifyOtp();
                      if (!mounted) return;

                      if (!otpVerified) {
                        return; // Error message already shown in verifyOtp
                      }

                      final name = _signUpFormState.getUserName();
                      final phone = _signUpFormState.getVerifiedPhone();

                      // Get userId, token, and fantasy_token from backend response
                      final userId = _signUpFormState.getVerifiedUserId();
                      final authToken = _signUpFormState.getVerifiedToken();
                      final fantasyToken = _signUpFormState.getFantasyToken();
                      final fantasyUserId = _signUpFormState.getFantasyUserId();
                      final isNewUser = _signUpFormState.isNewUser();

                      debugPrint('📝 [SIGNUP] OTP verified. Backend response:');
                      debugPrint('📝 [SIGNUP] userId: $userId');
                      debugPrint(
                          '📝 [SIGNUP] authToken: ${authToken != null ? "present (${authToken.length} chars)" : "null"}');
                      debugPrint(
                          '📝 [SIGNUP] fantasyToken: ${fantasyToken != null ? "present (${fantasyToken.length} chars)" : "null"}');
                      debugPrint('📝 [SIGNUP] fantasyUserId: $fantasyUserId');
                      debugPrint('📝 [SIGNUP] isNewUser: $isNewUser');

                      if (phone == null || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please verify your phone number with OTP'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        // User already created by backend during OTP verification
                        // No need to call Hygraph directly - backend handles this!

                        if (userId == null || userId.isEmpty) {
                          debugPrint('❌ [SIGNUP] No userId from backend!');
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Error: Backend did not return user ID. Please try again or contact support.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        debugPrint(
                            '✅ [SIGNUP] User created by backend. UserId: $userId');

                        // Initialize services
                        final authService = AuthService();
                        final prefs = await SharedPreferences.getInstance();
                        const initialShopTokens = 0;
                        await prefs.setInt('shop_tokens', initialShopTokens);
                        debugPrint(
                            '💰 [SIGNUP] Stored initial shopTokens: $initialShopTokens');

                        // Initialize core AuthService
                        final coreAuthService = core_auth.AuthService();
                        await coreAuthService.initialize();

                        // Use authToken as primary (should work for both Shop & Fantasy APIs)
                        // This matches login flow which uses unified token from backend
                        String? finalToken = authToken;
                        
                        debugPrint('🔑 [SIGNUP] Using token for session:');
                        debugPrint('   - Primary token (authToken): ${authToken != null ? "present" : "null"}');
                        debugPrint('   - Fantasy token field: ${fantasyToken != null ? "present" : "null"}');

                        // Save login session
                        await authService.saveLoginSession(
                          phone: phone,
                          name: name,
                          phoneVerified: true,
                          userId: userId,
                          fantasyToken:
                              finalToken, // Will be null if Shop backend doesn't provide it
                        );

                        // Save to core AuthService
                        await coreAuthService.saveUserSession(
                          userId: userId,
                          authToken: finalToken ?? '',
                          mobileNumber: phone,
                          name: name,
                          fantasyUserId: fantasyUserId,
                          shopEnabled: true,
                          fantasyEnabled: true,
                          modules: ['shop', 'fantasy'],
                        );

                        // ✅ FORCE SET ALL LOGIN FLAGS - Critical for session persistence
                        await prefs.setBool('is_logged_in', true);
                        await prefs.setBool('is_logged_in_fantasy', true);
                        await prefs.setString('user_id', userId);
                        await prefs.setString('userId', userId);
                        await prefs.setString('shop_user_id', userId);
                        await prefs.setString('user_id_fantasy', userId);
                        await prefs.setString('mobile_number', phone);
                        if (finalToken != null && finalToken.isNotEmpty) {
                          await prefs.setString('token', finalToken);
                          await prefs.setString('auth_token', finalToken);
                        }

                        // Debug: Verify flags were saved
                        debugPrint('🔐 [SIGNUP] Session flags after save:');
                        debugPrint('   - is_logged_in: ${prefs.getBool('is_logged_in')}');
                        debugPrint('   - is_logged_in_fantasy: ${prefs.getBool('is_logged_in_fantasy')}');
                        debugPrint('   - user_id: ${prefs.getString('user_id')}');
                        debugPrint('   - token: ${prefs.getString('token') != null ? "present" : "null"}');

                        debugPrint('✅ [SIGNUP] User session saved - persistent login enabled');

                        // ✅ FINAL VALIDATION: Verify session is complete before navigation
                        final savedToken = prefs.getString('token');
                        final savedAuthToken = prefs.getString('auth_token');
                        final savedIsLoggedIn = prefs.getBool('is_logged_in');
                        final savedUserId = prefs.getString('user_id');

                        debugPrint('🔐 [SIGNUP] FINAL SESSION VALIDATION:');
                        debugPrint('   - is_logged_in: $savedIsLoggedIn');
                        debugPrint(
                            '   - is_logged_in_fantasy: ${prefs.getBool('is_logged_in_fantasy')}');
                        debugPrint('   - user_id: $savedUserId');
                        debugPrint(
                            '   - token present: ${savedToken != null && savedToken.isNotEmpty}');
                        debugPrint(
                            '   - auth_token present: ${savedAuthToken != null && savedAuthToken.isNotEmpty}');

                        // Verify userId is saved (token is optional for Shop-only mode)
                        if (savedUserId == null || savedUserId.isEmpty) {
                          debugPrint(
                              '❌ [SIGNUP] UserId not saved properly! Aborting navigation.');
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Session error. Please try logging in again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Debug: Verify flags were saved
                        debugPrint('🔐 [SIGNUP] Session flags after save:');
                        debugPrint(
                            '   - is_logged_in: ${prefs.getBool('is_logged_in')}');
                        debugPrint(
                            '   - is_logged_in_fantasy: ${prefs.getBool('is_logged_in_fantasy')}');
                        debugPrint(
                            '   - user_id: ${prefs.getString('user_id')}');
                        debugPrint(
                            '   - token: ${prefs.getString('token') != null ? "present" : "null"}');

                        debugPrint(
                            '✅ [SIGNUP] User session saved - persistent login enabled');

                        if (!mounted) return;
                        Navigator.of(context).pop(); // Hide loading

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Account created successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );

                        context.go(RouteNames.home);
                      } catch (e, stackTrace) {
                        debugPrint('❌ [SIGNUP] Exception during signup: $e');
                        debugPrint('❌ [SIGNUP] Stack trace: $stackTrace');
                        if (mounted) {
                          Navigator.of(context).pop(); // Hide loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Continue'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Do you have an account?'),
                      TextButton(
                        onPressed: () {
                          context.go(RouteNames.login);
                        },
                        child: const Text('Log in'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
