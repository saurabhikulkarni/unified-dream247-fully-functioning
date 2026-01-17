import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';
import 'package:unified_dream247/features/shop/services/msg91_service.dart';

import 'package:unified_dream247/features/shop/constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    this.onFormCreated,
  });

  final GlobalKey<FormState> formKey;
  final Function(_SignUpFormState)? onFormCreated;

  @override
  State<SignUpForm> createState() {
    final state = _SignUpFormState();
    onFormCreated?.call(state);
    return state;
  }
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  Timer? _resendTimer;
  int _secondsLeft = 0;
  static const int _resendDuration = 30;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  bool _isValidIndianMobile(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsLeft = _resendDuration;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
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
      }
    });
  }

  String? _sessionId; // Store session ID from OTP send response

  Future<void> _sendOtp({bool isResend = false}) async {
    if (!isResend && !widget.formKey.currentState!.validate()) return;

    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Send OTP via MSG91 service (backend API)
      final result = await msg91Service.sendOtp(phone);
      
      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            _otpSent = true;
            _sessionId = result['sessionId'];
            _otpController.clear(); // Clear previous OTP if any
          });
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'OTP sent to your mobile number.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to send OTP. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> verifyOtp() async {
    if (!_otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please send OTP first'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final otp = _otpController.text.trim();

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

    // Verify OTP via MSG91 service (backend API)
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
      // Mark phone as verified in AuthService
      await AuthService().markPhoneVerified(phone);
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  String? getVerifiedPhone() {
    if (_otpSent && _otpController.text.isNotEmpty) {
      return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    }
    return null;
  }

  String getUserName() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    return '$firstName $lastName'.trim();
  }

  bool isTermsAgreed() {
    return _agreeToTerms;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              hintText: 'First name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              if (value.length < 2) {
                return 'First name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              hintText: 'Last name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
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
              if (!_isValidIndianMobile(value)) {
                return 'Enter a valid Indian mobile number (10 digits starting with 6-9)';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          if (!_otpSent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _sendOtp();
                },
                child: const Text('Send OTP'),
              ),
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
                onPressed: _secondsLeft == 0 ? () async {
                  await _sendOtp(isResend: true);
                } : null,
                child: Text(
                  _secondsLeft == 0
                      ? 'Resend OTP'
                      : 'Resend OTP (${_secondsLeft}s)',
                ),
              ),
            ),
          ],
          const SizedBox(height: defaultPadding),
          // Terms and Privacy Policy Agreement
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                    children: [
                      const TextSpan(text: 'I agree with '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.push('/shop/terms-and-conditions');
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.push('/shop/privacy-policy');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
