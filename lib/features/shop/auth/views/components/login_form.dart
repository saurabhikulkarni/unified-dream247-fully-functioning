import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/components/gradient_button.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/services/msg91_service.dart';
import 'package:shop/services/user_service.dart';
import 'package:shop/services/wishlist_service.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/route/route_constants.dart';

import '../../../../constants.dart';


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
    final phone = getVerifiedPhone();
    if (phone != null) {
      final authService = AuthService();
      
      // Check if it's test user - use direct login
      if (authService.isTestUser(phone)) {
        final success = await authService.loginTestUser();
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🧪 Test user logged in successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }
      
      final name = getUserName();
      
      try {
        // First, try to find existing user by mobile number
        final graphQLClient = GraphQLService.getClient();
        
        // Clean phone number (remove non-digit characters)
        final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
        
        print('📱 [LOGIN] Original phone: $phone');
        print('📱 [LOGIN] Cleaned phone: $cleanPhone');
        print('📱 [LOGIN] Phone length: ${cleanPhone.length}');
        
        // Validate phone number is exactly 10 digits
        if (cleanPhone.length != 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid phone number. Must be exactly 10 digits. Got: ${cleanPhone.length} digits'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Query for existing user
        final QueryOptions queryOptions = QueryOptions(
          document: gql(GraphQLQueries.getUserByMobileNumber),
          variables: {'mobileNumber': cleanPhone},
        );
        
        QueryResult queryResult = await graphQLClient.query(queryOptions);
        String? userId;

        if (!queryResult.hasException && queryResult.data != null) {
          final users = queryResult.data?['userDetails'] as List?;
          if (users != null && users.isNotEmpty) {
            userId = users[0]?['id']?.toString();
          }
        }

        // If user doesn't exist, create new user
        if (userId == null) {
          print('📝 [LOGIN] Creating new user with:');
          print('   firstName: $name');
          print('   lastName: (empty)');
          print('   username: $name');
          print('   mobileNumber: $cleanPhone');
          
          final MutationOptions options = MutationOptions(
            document: gql(GraphQLQueries.createUser),
            variables: {
              'firstName': name,
              'lastName': '',
              'username': name, // Use name as username, not phone!
              'mobileNumber': cleanPhone, // Use cleaned phone as String
            },
          );
          
          print('📤 [LOGIN] Sending GraphQL mutation with variables: ${options.variables}');
          
          final QueryResult result = await graphQLClient.mutate(options);
          
          if (result.hasException) {
            print('❌ [LOGIN] Error creating user: ${result.exception}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating account: ${result.exception?.toString() ?? "Unknown error"}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          
          userId = result.data?['createUserDetail']?['id']?.toString();
          
          // Publish user (required for Hygraph)
          if (userId != null) {
            try {
              final publishOptions = MutationOptions(
                document: gql(GraphQLQueries.publishUser),
                variables: {'id': userId},
              );
              await graphQLClient.mutate(publishOptions);
            } catch (e) {
              // Publishing failed, but user is created
            }
          }
        }
        
        if (userId != null && userId.isNotEmpty) {
          // Save login session with userId from Hygraph
          await authService.saveLoginSession(
            phone: phone,
            name: name,
            phoneVerified: true,
            userId: userId,
          );
          
          // Sync wishlist and cart from backend after successful login
          await wishlistService.syncWithBackend();
          await cartService.syncWithBackend();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error during login. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
