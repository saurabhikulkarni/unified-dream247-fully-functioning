import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/api_config.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/core/constants/api_constants.dart';
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
  String? _hygraphUserId; // Store Hygraph user ID from existing user check

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
              content: const Text('No account exists with this mobile number. Please sign up first.'),
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
      
      // ✅ Store Hygraph userId for later use when saving session
      _hygraphUserId = existingUser.id;
      debugPrint('📝 [LOGIN] Found existing user with Hygraph ID: $_hygraphUserId');
    } catch (e) {
      // If user check fails, continue with OTP anyway (fallback)
      print('⚠️ [LOGIN] Error checking user existence: $e');
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
  }

  String? getVerifiedPhone() {
    if (_otpSent && _otpController.text.isNotEmpty && _otpController.text.length >= 4) {
      return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    }
    return null;
  }

  String getUserName() {
    return _nameController.text.trim();
  }

  /// Verify OTP using unified backend endpoint
  Future<Map<String, dynamic>> verifyOtpUnified() async {
    try {
      final phone = _phoneController.text.trim();
      final otp = _otpController.text.trim();
      final name = _nameController.text.trim();
      
      // Call unified verify-otp endpoint
      final response = await http.post(
        Uri.parse('${ApiConstants.shopBackendUrl}${ApiConstants.verifyOtpEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': phone,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 15));
      
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        final user = data['user'];
        final token = data['token'];
        final refreshToken = data['refreshToken'];
        
        // Store shopTokens balance BEFORE saving session
        final prefs = await SharedPreferences.getInstance();
        final shopTokens = user['shopTokens'] ?? 0;
        await prefs.setInt('shop_tokens', shopTokens);
        debugPrint('💰 [OTP_VERIFY] Stored shopTokens: $shopTokens');
        
        // Store all unified auth data using core auth service
        final coreAuthService = core_auth.AuthService();
        await coreAuthService.initialize();
        await coreAuthService.saveUserSession(
          userId: user['id'],                                        // Hygraph ID
          authToken: token,
          mobileNumber: phone,
          name: name,
          fantasyUserId: user['fantasy_user_id'],                   // MongoDB ID
          shopEnabled: user['shop_enabled'] ?? true,
          fantasyEnabled: user['fantasy_enabled'] ?? true,
          modules: List<String>.from(user['modules'] ?? ['shop', 'fantasy']),
          refreshToken: refreshToken,
        );
        
        debugPrint('✅ [OTP_VERIFY] User session saved with shopTokens');
        return {'success': true, 'message': 'Login successful'};
      }
      
      return {'success': false, 'message': data['message'] ?? 'OTP verification failed'};
    } catch (e) {
      debugPrint('❌ [OTP_VERIFY] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<bool> verifyOtp() async {
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

    print('📱 [LOGIN] OTP Verification result: ${result['success']}');
    print('📱 [LOGIN] OTP Verification message: ${result['message']}');

    if (result['success'] == true) {
      return true;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Invalid OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> saveLoginSession() async {
    final phone = getVerifiedPhone();
    if (phone == null) return;

    final name = getUserName();
    
    // For web platform, skip GraphQL/Hive operations and use simple session storage
    try {
      final authService = AuthService();
      final prefs = await SharedPreferences.getInstance();
      
      // NEW: Fetch shopTokens balance from backend after MSG91 OTP verification
      try {
        // Get auth token if available
        final authToken = prefs.getString('token') ?? prefs.getString('auth_token');
        
        // If we have auth token, fetch shopTokens from backend
        if (authToken != null && authToken.isNotEmpty) {
          final response = await http.get(
            Uri.parse(ApiConfig.fantasyWalletBalanceEndpoint),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 8));
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final walletData = data['data'] ?? data;
            final shopTokens = (walletData['shopTokens'] as num?)?.toInt() ?? 0;
            await prefs.setInt('shop_tokens', shopTokens);
            debugPrint('💰 [LOGIN] Stored shopTokens after MSG91 verification: $shopTokens');
          }
        }
      } catch (e) {
        debugPrint('⚠️ [LOGIN] Could not fetch shopTokens from backend: $e');
        // Fallback: initialize with 0
        await prefs.setInt('shop_tokens', 0);
      }
      
      // Fetch fantasy authentication token from backend
      String? fantasyToken;
      String? storedUserId;
      try {
        // ✅ Use Hygraph userId from existing user check, fallback to stored
        storedUserId = _hygraphUserId ?? prefs.getString('user_id');
        debugPrint('📝 [LOGIN] Using userId for Fantasy token: $storedUserId');
        
        final authService = AuthService();
        fantasyToken = await authService.fetchFantasyToken(
          phone: phone,
          name: name,
          userId: storedUserId, // ✅ Pass Hygraph userId for user sync
        );
        
        if (fantasyToken == null) {
          print('⚠️ [LOGIN] Failed to fetch fantasy token, continuing without it');
        }
      } catch (e) {
        print('❌ [LOGIN] Error fetching fantasy token: $e');
        // Continue with login even if fantasy token fetch fails
      }
      
      // Save basic session info with fantasy token
      // ✅ Use Hygraph userId (not phone) for unified user identity
      final userIdToSave = _hygraphUserId ?? storedUserId ?? phone;
      debugPrint('📝 [LOGIN] Saving session with userId: $userIdToSave');
      
      await authService.saveLoginSession(
        phone: phone,
        name: name,
        phoneVerified: true,
        userId: userIdToSave, // ✅ Use Hygraph userId for unified identity
        fantasyToken: fantasyToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Logged in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ [LOGIN] Error saving session: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful but session save failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
              padding: const EdgeInsets.symmetric(vertical: defaultPadding / 1.5),
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
                onPressed: _secondsLeft == 0 ? () async {
                  await _sendOtp();
                } : null,
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
