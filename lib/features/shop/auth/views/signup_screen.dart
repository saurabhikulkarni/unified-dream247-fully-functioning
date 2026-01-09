import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/services/user_service.dart';
import 'package:shop/services/wishlist_service.dart';
import 'package:shop/services/cart_service.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  dynamic _signUpFormState;
  bool _privacyAccepted = false;
  
  final WishlistService wishlistService = WishlistService();
  final CartService cartService = CartService();

  @override
  void initState() {
    super.initState();
    // Preload the welcome image to avoid loading delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage("assets/images/welcome-min.jpg"),
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
                "assets/images/welcome-min.jpg",
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let’s get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Please enter your valid data in order to create an account.",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    formKey: _formKey,
                    onFormCreated: (form) {
                      _signUpFormState = form;
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            _privacyAccepted = value ?? false;
                          });
                        },
                        value: _privacyAccepted,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, termsOfServicesScreenRoute);
                                  },
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& privacy policy.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (!_privacyAccepted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please accept the terms and privacy policy'),
                          ),
                        );
                        return;
                      }

                      // First verify OTP
                      final otpVerified = await _signUpFormState.verifyOtp();
                      if (!mounted) return;
                      
                      if (!otpVerified) {
                        return; // Error message already shown in verifyOtp
                      }

                      final name = _signUpFormState.getUserName();
                      final phone = _signUpFormState.getVerifiedPhone();
                      
                      if (phone == null || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please verify your phone number with OTP'),
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

                      try {
                        // Check if user already exists with this phone number
                        final UserService userService = UserService();
                        final existingUser = await userService.getUserByMobileNumber(phone);
                        
                        if (existingUser != null) {
                          if (mounted) {
                            Navigator.of(context).pop(); // Hide loading dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Already Registered'),
                                content: const Text('An account already exists with this mobile number. Please log in instead.'),
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
                                      Navigator.pushReplacementNamed(context, logInScreenRoute);
                                    },
                                    child: const Text('Login'),
                                  ),
                                ],
                              ),
                            );
                          }
                          return;
                        }

                        // Extract first and last name from full name
                        final nameParts = name.split(' ');
                        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
                        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
                        
                        // Clean phone number (remove non-digit characters)
                        final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
                        
                        // Call GraphQL mutation to create user and get their ID
                        final graphQLClient = GraphQLService.getClient();
                        final MutationOptions options = MutationOptions(
                          document: gql(GraphQLQueries.createUser),
                          variables: {
                            'firstName': firstName,
                            'lastName': lastName,
                            'username': phone, // Use phone as username
                            'mobileNumber': cleanPhone, // Use cleaned phone as String
                          },
                        );
                        
                        final QueryResult result = await graphQLClient.mutate(options);
                        
                        if (result.hasException) {
                          if (mounted) {
                            Navigator.of(context).pop(); // Hide loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${result.exception}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        
                        // Extract userId from response
                        final userId = result.data?['createUserDetail']?['id']?.toString();

                        if (userId != null && userId.isNotEmpty) {
                          // Publish user (required for Hygraph)
                          try {
                            final publishOptions = MutationOptions(
                              document: gql(GraphQLQueries.publishUser),
                              variables: {'id': userId},
                            );
                            await graphQLClient.mutate(publishOptions);
                          } catch (e) {
                            // Publishing failed, but user is created
                          }
                          // Save login session with userId from Hygraph
                          final authService = AuthService();
                          await authService.saveLoginSession(
                            phone: phone,
                            name: name,
                            phoneVerified: true,
                            userId: userId,
                          );
                          
                          // Sync wishlist and cart from backend after successful signup
                          await wishlistService.syncWithBackend();
                          await cartService.syncWithBackend();
                          
                          if (!mounted) return;
                          Navigator.of(context).pop(); // Hide loading
                          Navigator.pushReplacementNamed(
                              context, entryPointScreenRoute);
                        } else {
                          if (mounted) {
                            Navigator.of(context).pop(); // Hide loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Could not create user account'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
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
                    child: const Text("Continue"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("Log in"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
