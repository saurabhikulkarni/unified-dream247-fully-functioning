import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:unified_dream247/features/shop/components/gradient_button.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/features/shop/services/msg91_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/services/wishlist_service.dart';
import 'package:unified_dream247/features/shop/services/cart_service.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

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
    
    // Check if it's test user - bypass OTP
    final authService = AuthService();
    if (authService.isTestUser(phone)) {
      setState(() {
        _otpSent = true;
        _otpController.text = "0000"; // Auto-fill with dummy OTP
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🧪 Test user detected - OTP bypassed (use 0000)'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
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

    // Check if user exists in database
    try {
      final UserService userService = UserService();
      final existingUser = await userService.getUserByMobileNumber(phone);
      
      if (existingUser == null) {
        // User doesn't exist
        if (mounted) {
          Navigator.of(context).pop(); // Hide loading dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unregistered Number'),
              content: const Text('This mobile number is not registered. Please sign up first to create an account.'),
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
                    Navigator.pushReplacementNamed(context, signUpScreenRoute);
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
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking user: ${e.toString()}'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'OTP sent to your mobile number.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to send OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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

    // Check if it's test user - bypass OTP verification
    final authService = AuthService();
    if (authService.isTestUser(phone)) {
      if (otp == "0000") {
        return true; // Accept any OTP for test user
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test user OTP should be 0000'),
          backgroundColor: Colors.orange,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> saveLoginSession() async {
    try {
      final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      final name = _nameController.text.trim();
      
      debugPrint('💾 Saving unified session for phone: $phone');

      // Get or create user in Hygraph
      final graphQLClient = GraphQLService.getClient();
      
      final QueryOptions queryOptions = QueryOptions(
        document: gql(GraphQLQueries.getUserByMobileNumber),
        variables: {'mobileNumber': phone},
        fetchPolicy: FetchPolicy.networkOnly,
      );
      
      final QueryResult queryResult = await graphQLClient.query(queryOptions);
      
      String? userId;
      String? existingName;
      String? email;
      
      if (queryResult.data != null && 
          queryResult.data!['userDetails'] != null && 
          queryResult.data!['userDetails'].isNotEmpty) {
        final userData = queryResult.data!['userDetails'][0];
        userId = userData['id']?.toString();
        existingName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
        email = userData['email'];
        debugPrint('✅ Found existing user: $userId');
      } else {
        debugPrint('📝 Creating new user...');
        final nameParts = name.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : name;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final MutationOptions createOptions = MutationOptions(
          document: gql(GraphQLQueries.createUser),
          variables: {
            'firstName': firstName,
            'lastName': lastName,
            'username': phone,
            'mobileNumber': phone,
          },
        );
        
        final QueryResult createResult = await graphQLClient.mutate(createOptions);
        
        if (createResult.hasException) {
          throw Exception('Failed to create user: ${createResult.exception}');
        }
        
        userId = createResult.data?['createUserDetail']?['id']?.toString();
        
        if (userId != null && userId.isNotEmpty) {
          try {
            final publishOptions = MutationOptions(
              document: gql(GraphQLQueries.publishUser),
              variables: {'id': userId},
            );
            await graphQLClient.mutate(publishOptions);
            debugPrint('✅ User published');
          } catch (e) {
            debugPrint('⚠️ Publish failed: $e');
          }
        }
      }
      
      if (userId == null || userId.isEmpty) {
        throw Exception('Failed to get/create user ID');
      }
      
      // Save unified session
      final authServiceInstance = AuthService();
      await authServiceInstance.saveUnifiedLoginSession(
        phone: phone,
        name: existingName ?? name,
        phoneVerified: true,
        userId: userId,
        email: email,
        authToken: userId,
      );
      
      // Sync services
      await wishlistService.syncWithBackend();
      await cartService.syncWithBackend();
      
      debugPrint('✅ Unified session saved - Shop & Fantasy ready!');
    } catch (e) {
      debugPrint('❌ Error saving session: $e');
      rethrow;
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
