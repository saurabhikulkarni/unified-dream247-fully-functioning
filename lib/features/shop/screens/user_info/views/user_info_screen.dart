import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/user_datasource.dart';
import 'package:unified_dream247/features/fantasy/menu_items/domain/use_cases/user_usecases.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _phoneError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserDataFromBackend();
  }

  /// Load user data from backend API
  Future<void> _loadUserDataFromBackend() async {
    try {
      // Fetch fresh user data from backend
      final userUsecases = UserUsecases(UserDatasource(ApiImplWithAccessToken()));
      await userUsecases.getUserDetails(context);
      
      // Get user data from provider (which was updated by getUserDetails)
      if (mounted) {
        final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
        final userData = userDataProvider.userData;
        
        if (userData != null) {
          setState(() {
            _nameController.text = userData.name ?? userData.team ?? '';
            _emailController.text = userData.email ?? '';
            _phoneController.text = userData.mobile?.toString() ?? '';
            _isLoading = false;
          });
          
          debugPrint('📱 [EDIT_PROFILE] Loaded user data from backend:');
          debugPrint('   Name: ${userData.name}');
          debugPrint('   Email: ${userData.email}');
          debugPrint('   Phone: ${userData.mobile}');
        } else {
          setState(() {
            _isLoading = false;
          });
          debugPrint('⚠️ [EDIT_PROFILE] No user data available from backend');
        }
      }
    } catch (e) {
      debugPrint('❌ [EDIT_PROFILE] Error loading user data from backend: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateIndianMobileNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(cleanPhone);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change photo')),
                );
              },
              child: const Text('Change Photo'),
            ),
          ),
          const SizedBox(height: defaultPadding * 1.5),
          Text(
            'Full Name',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: 'Enter your full name',
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            'Email',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: 'Enter your email',
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            'Phone Number',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _phoneError = null;
                } else if (!_validateIndianMobileNumber(value)) {
                  _phoneError = 'Enter a valid Indian mobile number (10 digits starting with 6-9)';
                } else {
                  _phoneError = null;
                }
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: 'Enter your phone number (e.g., 9876543210)',
              errorText: _phoneError,
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton(
            onPressed: () async {
              if (_phoneController.text.isNotEmpty &&
                  !_validateIndianMobileNumber(_phoneController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid Indian mobile number'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Save user data to backend
              try {
                final userUsecases = UserUsecases(UserDatasource(ApiImplWithAccessToken()));
                
                // Get current user data to preserve other fields
                final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
                final currentUserData = userDataProvider.userData;
                
                // Call backend API to update profile
                final result = await userUsecases.updateProfile(
                  context,
                  currentUserData?.team ?? _nameController.text, // teamName
                  _nameController.text, // name
                  currentUserData?.state ?? '', // state
                  currentUserData?.gender ?? '', // gender
                  currentUserData?.city ?? '', // city
                  currentUserData?.address ?? '', // address
                  currentUserData?.dob ?? '', // dob
                  currentUserData?.pincode?.toString() ?? '', // pincode
                );
                
                if (result == true) {
                  debugPrint('✅ [EDIT_PROFILE] User data saved to backend successfully');
                  
                  // Refresh user data from backend
                  await userUsecases.getUserDetails(context);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update profile'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                debugPrint('❌ [EDIT_PROFILE] Error saving user data: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update profile'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
