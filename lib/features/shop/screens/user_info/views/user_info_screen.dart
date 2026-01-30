import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/services/auth_service.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserDataFromShop();
  }

  /// Load user data from Shop backend (Hygraph)
  Future<void> _loadUserDataFromShop() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');
      
      if (_userId == null || _userId!.isEmpty) {
        debugPrint('⚠️ [EDIT_PROFILE_SHOP] No user_id found in SharedPreferences');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch user data from Hygraph
      final userService = UserService();
      final userData = await userService.getUserById(_userId!);
      
      if (mounted && userData != null) {
        setState(() {
          _firstNameController.text = userData.firstName;
          _lastNameController.text = userData.lastName;
          _emailController.text = ''; // Email not stored in Hygraph yet
          _phoneController.text = userData.mobileNumber;
          _isLoading = false;
        });
        
        debugPrint('📱 [EDIT_PROFILE_SHOP] Loaded user data from Hygraph:');
        debugPrint('   First Name: ${userData.firstName}');
        debugPrint('   Last Name: ${userData.lastName}');
        debugPrint('   Phone: ${userData.mobileNumber}');
        debugPrint('   User ID: $_userId');
      } else {
        setState(() {
          _isLoading = false;
        });
        debugPrint('⚠️ [EDIT_PROFILE_SHOP] No user data found in Hygraph');
      }
    } catch (e) {
      debugPrint('❌ [EDIT_PROFILE_SHOP] Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
            'First Name',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: 'Enter your first name',
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            'Last Name',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: 'Enter your last name',
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
            keyboardType: TextInputType.emailAddress,
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
            readOnly: true,  // ✅ Phone is authentication credential - cannot be changed
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: 'Phone number linked to your account',
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton(
            onPressed: () async {
              // Validate inputs
              if (_firstNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your first name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (_lastNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your last name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (_userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User ID not found. Please login again.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Save user data to Hygraph
              try {
                debugPrint('💾 [EDIT_PROFILE_SHOP] Saving profile to Hygraph...');
                
                final userService = UserService();
                final result = await userService.updateUserProfile(
                  userId: _userId!,
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                );
                
                if (result) {
                  debugPrint('✅ [EDIT_PROFILE_SHOP] Profile saved successfully');
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Reload data to show updated info
                    await _loadUserDataFromShop();
                  }
                } else {
                  debugPrint('❌ [EDIT_PROFILE_SHOP] Profile save failed');
                  
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
                debugPrint('❌ [EDIT_PROFILE_SHOP] Error saving profile: $e');
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
