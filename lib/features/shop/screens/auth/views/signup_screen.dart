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

                      // Verify OTP - Backend handles everything:
                      // - Creates user in Hygraph
                      // - Creates user in Fantasy MongoDB
                      // - Links fantasy_user_id back to Hygraph
                      // - Returns all tokens and IDs
                      final otpVerified = await _signUpFormState.verifyOtp();
                      if (!mounted) return;

                      if (!otpVerified) {
                        return; // Error message already shown in verifyOtp
                      }

                      final name = _signUpFormState.getUserName();
                      final phone = _signUpFormState.getVerifiedPhone();

                      // Get all data from backend response
                      final userId = _signUpFormState.getVerifiedUserId();
                      final authToken = _signUpFormState.getVerifiedToken();
                      final fantasyUserId = _signUpFormState.getFantasyUserId();

                      if (phone == null || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please verify your phone number with OTP'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (userId == null || userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: No user ID received from backend'),
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
                        // Save session locally
                        final authService = AuthService();
                        final coreAuthService = core_auth.AuthService();
                        final prefs = await SharedPreferences.getInstance();

                        // Initialize services
                        await coreAuthService.initialize();

                        // Save to Shop AuthService
                        await authService.saveLoginSession(
                          phone: phone,
                          name: name,
                          phoneVerified: true,
                          userId: userId,
                          fantasyToken: authToken,
                        );

                        // Save to core AuthService
                        await coreAuthService.saveUserSession(
                          userId: userId,
                          authToken: authToken ?? '',
                          mobileNumber: phone,
                          name: name,
                          fantasyUserId: fantasyUserId,
                          shopEnabled: true,
                          fantasyEnabled: true,
                          modules: ['shop', 'fantasy'],
                        );

                        // Set all login flags for persistent session
                        await prefs.setBool('is_logged_in', true);
                        await prefs.setBool('is_logged_in_fantasy', true);
                        await prefs.setString('user_id', userId);
                        await prefs.setString('userId', userId);
                        await prefs.setString('mobile_number', phone);
                        
                        if (authToken != null && authToken.isNotEmpty) {
                          await prefs.setString('token', authToken);
                          await prefs.setString('auth_token', authToken);
                        }

                        if (!mounted) return;
                        Navigator.of(context).pop(); // Hide loading

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account created successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        context.go(RouteNames.home);
                      } catch (e) {
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
