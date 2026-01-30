import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;
import 'package:unified_dream247/features/shop/components/gradient_button.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';
import 'package:unified_dream247/features/shop/services/msg91_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/constants.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
    this.onFormCreated,
  });
  final GlobalKey<FormState> formKey;
  final Function(_LogInFormState)? onFormCreated;

  @override
  State<LogInForm> createState() {
    final state = _LogInFormState();
    onFormCreated?.call(state);
    return state;
  }
}

class _LogInFormState extends State<LogInForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  Timer? _resendTimer;
  int _secondsLeft = 0;
  static const int _resendDuration = 30;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsLeft = _resendDuration;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
      } else {
        setState(() {
          _secondsLeft -= 1;
        });
      }
    });
  }

  String? _sessionId; // Store session ID from OTP send response

  Future<void> _sendOtp() async {
    // Validate Indian mobile number before sending OTP
    String phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Indian mobile number (10 digits, starts with 6-9)
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Indian mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Check if user exists with this phone number
    try {
      final UserService userService = UserService();
      final existingUser = await userService.getUserByMobileNumber(phone);

      if (existingUser == null) {
        if (mounted) {
          Navigator.of(context).pop(); // Hide loading dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Account Not Found'),
              content: const Text(
                'No account exists with this mobile number. Please sign up first.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(RouteNames.register);
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          );
        }
        return;
      }
    } catch (e) {
      // If user check fails, show error and stop
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error checking account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Send OTP via MSG91 service (backend API)
    final result = await msg91Service.sendOtp(phone);

    // Hide loading indicator
    if (mounted) {
      Navigator.of(context).pop();
    }

    if (result['success'] == true) {
      setState(() {
        _otpSent = true;
        _sessionId = result['sessionId'];
        _otpController.clear(); // Clear previous OTP if any
      });

      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? 'OTP sent to your mobile number.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to send OTP. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? getVerifiedPhone() {
    if (_otpSent &&
        _otpController.text.isNotEmpty &&
        _otpController.text.length >= 4) {
      return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    }
    return null;
  }

  String getUserName() {
    return _nameController.text.trim();
  }

  Future<bool> verifyOtp() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final otp = _otpController.text.trim();
    final name = _nameController.text.trim();

    if (otp.isEmpty || otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Verify OTP via MSG91 service - backend handles everything:
    // - Validates OTP
    // - Returns user data, tokens, etc.
    final result = await msg91Service.verifyOtp(
      mobileNumber: phone,
      otp: otp,
      sessionId: _sessionId,
    );

    // Hide loading indicator
    if (mounted) {
      Navigator.of(context).pop();
    }

    if (result['success'] == true) {
      // Extract data from backend response
      final user = result['user'] ?? {};
      final userId = result['userId']?.toString() ??
          result['id']?.toString() ??
          user['id']?.toString() ??
          user['userId']?.toString();

      final authToken = result['authToken']?.toString() ??
          result['token']?.toString() ??
          user['token']?.toString();

      final fantasyUserId = result['fantasy_user_id']?.toString() ??
          result['fantasyUserId']?.toString() ??
          user['fantasy_user_id']?.toString();

      if (userId == null || userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed: No user ID received'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      // Save session locally
      try {
        final authService = AuthService();
        final coreAuthService = core_auth.AuthService();
        final prefs = await SharedPreferences.getInstance();

        await coreAuthService.initialize();

        // Save to Shop AuthService
        await authService.saveLoginSession(
          phone: phone,
          name: name.isNotEmpty ? name : (user['name'] ?? ''),
          phoneVerified: true,
          userId: userId,
          fantasyToken: authToken,
        );

        // Save to core AuthService
        await coreAuthService.saveUserSession(
          userId: userId,
          authToken: authToken ?? '',
          mobileNumber: phone,
          name: name.isNotEmpty ? name : (user['name'] ?? ''),
          fantasyUserId: fantasyUserId,
          shopEnabled: true,
          fantasyEnabled: true,
          modules: ['shop', 'fantasy'],
        );

        // Set login flags
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('is_logged_in_fantasy', true);
        await prefs.setString('user_id', userId);
        await prefs.setString('userId', userId);
        await prefs.setString('mobile_number', phone);

        if (authToken != null && authToken.isNotEmpty) {
          await prefs.setString('token', authToken);
          await prefs.setString('auth_token', authToken);
        }

        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? 'Invalid OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Full name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Mobile number',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your mobile number';
              }
              // Remove non-numeric characters for validation
              String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

              // Validate Indian mobile number (10 digits, starts with 6-9)
              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanPhone)) {
                return 'Enter a valid Indian mobile number (10 digits starting with 6-9)';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          if (!_otpSent)
            GradientButton(
              onPressed: () async {
                if (widget.formKey.currentState!.validate()) {
                  await _sendOtp();
                }
              },
              padding:
                  const EdgeInsets.symmetric(vertical: defaultPadding / 1.5),
              child: const Text('Send OTP'),
            ),
          if (_otpSent) ...[
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the OTP';
                }
                if (value.length < 4) {
                  return 'OTP must be at least 4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: defaultPadding),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _secondsLeft == 0
                    ? () async {
                        await _sendOtp();
                      }
                    : null,
                child: Text(
                  _secondsLeft == 0
                      ? 'Resend OTP'
                      : 'Resend OTP (${_secondsLeft}s)',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
