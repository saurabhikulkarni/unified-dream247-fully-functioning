import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/components/gradient_button.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/services/address_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAddressScreen extends StatefulWidget {
  final String? addressId;
  final String? fullName;
  final String? emailId;
  final String? phoneNumber;
  final String? houseNumber;
  final String? roadName;
  final String? landmark;
  final String? pincode;
  final String? city;
  final String? state;

  const AddAddressScreen({
    super.key,
    this.addressId,
    this.fullName,
    this.emailId,
    this.phoneNumber,
    this.houseNumber,
    this.roadName,
    this.landmark,
    this.pincode,
    this.city,
    this.state,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController houseNumberController;
  late TextEditingController roadNameController;
  late TextEditingController landmarkController;
  late TextEditingController pincodeController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  
  bool _isLoading = false;
  bool _isFetchingPincode = false;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.fullName ?? '');
    emailController = TextEditingController(text: widget.emailId ?? '');
    phoneController = TextEditingController(text: widget.phoneNumber ?? '');
    houseNumberController = TextEditingController(text: widget.houseNumber ?? '');
    roadNameController = TextEditingController(text: widget.roadName ?? '');
    landmarkController = TextEditingController(text: widget.landmark ?? '');
    pincodeController = TextEditingController(text: widget.pincode ?? '');
    cityController = TextEditingController(text: widget.city ?? '');
    stateController = TextEditingController(text: widget.state ?? '');
    
    // Add listener to pincode field
    pincodeController.addListener(_onPincodeChanged);
    
    // If editing, load address data from service
    if (widget.addressId != null && widget.addressId!.isNotEmpty) {
      _loadAddressData();
    }
  }

  void _onPincodeChanged() {
    final pincode = pincodeController.text.trim();
    // Indian pincode is 6 digits
    if (pincode.length == 6 && RegExp(r'^\d{6}$').hasMatch(pincode)) {
      _fetchLocationFromPincode(pincode);
    }
  }

  Future<void> _fetchLocationFromPincode(String pincode) async {
    if (_isFetchingPincode) return;
    
    setState(() {
      _isFetchingPincode = true;
    });

    try {
      // Using India Post Office API - free and reliable
      final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final result = data[0];
          if (result['Status'] == 'Success' && result['PostOffice'] != null) {
            final postOffice = result['PostOffice'][0];
            final city = postOffice['District'] ?? postOffice['Block'] ?? '';
            final state = postOffice['State'] ?? '';
            
            if (mounted) {
              setState(() {
                cityController.text = city;
                stateController.text = state;
                _isFetchingPincode = false;
              });
              
              // Show success feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location detected: $city, $state'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            return;
          }
        }
      }
      
      // If API fails or returns no data
      if (mounted) {
        setState(() {
          _isFetchingPincode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid pincode or location not found'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingPincode = false;
        });
        print('Error fetching pincode data: $e');
        // Silently fail - user can still enter city/state manually
      }
    }
  }

  Future<void> _loadAddressData() async {
    if (widget.addressId == null) return;
    
    try {
      final address = await addressService.getAddressById(widget.addressId!);
      if (address != null && mounted) {
        setState(() {
          fullNameController.text = address.fullName;
          phoneController.text = address.phoneNumber;
          houseNumberController.text = address.addressLine1;
          roadNameController.text = address.addressLine2 ?? '';
          pincodeController.text = address.pincode;
          cityController.text = address.city;
          stateController.text = address.state;
        });
      }
    } catch (e) {
      // Silently fail - user can still edit manually
      print('Error loading address: $e');
    }
  }

  @override
  void dispose() {
    pincodeController.removeListener(_onPincodeChanged);
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    houseNumberController.dispose();
    roadNameController.dispose();
    landmarkController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveAddress() async {
    // Validate required fields
    if (fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        houseNumberController.text.trim().isEmpty ||
        pincodeController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Save address using service
      AddressModel? savedAddress;
      if (widget.addressId != null) {
        // Update existing address
        savedAddress = await addressService.updateAddress(
          addressId: widget.addressId!,
          fullName: fullNameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          pincode: pincodeController.text.trim(),
          addressLine1: houseNumberController.text.trim(),
          addressLine2: roadNameController.text.trim().isNotEmpty 
              ? roadNameController.text.trim() 
              : null,
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          country: 'India',
          isDefault: false, // You can add a checkbox for this if needed
        );
      } else {
        // Create new address
        print('[ADD_ADDRESS_SCREEN] Creating new address...');
        savedAddress = await addressService.createAddress(
          userId: userId,
          fullName: fullNameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          pincode: pincodeController.text.trim(),
          addressLine1: houseNumberController.text.trim(),
          addressLine2: roadNameController.text.trim().isNotEmpty 
              ? roadNameController.text.trim() 
              : null,
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          country: 'India',
          isDefault: false, // You can add a checkbox for this if needed
        );
        print('[ADD_ADDRESS_SCREEN] Address created and published successfully');
      }

      if (savedAddress == null) {
        throw Exception('Failed to save address');
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.addressId == null 
              ? 'Address saved and published successfully' 
              : 'Address updated successfully',),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Return success after a brief delay
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.pop(context, {'success': true});
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow back button to work properly
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.addressId == null ? 'Add Address' : 'Edit Address'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Details Section
                Text(
                  'Basic Details',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: emailController,
                  label: 'Email ID',
                  hint: 'Enter your email id',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: defaultPadding * 1.5),
                // Address Section
                Text(
                  'Address',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: houseNumberController,
                  label: 'House No/ Building Name',
                  hint: 'Enter your House No/ Building Name',
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: roadNameController,
                  label: 'Road Name/ Area/ Colony',
                  hint: 'Enter your Road Name/ Area/ Colony',
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: landmarkController,
                  label: 'Landmark (Optional)',
                  hint: 'Enter your Landmark (Optional)',
                ),
                const SizedBox(height: defaultPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pincode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter your Pincode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: 12,
                        ),
                        suffixIcon: _isFetchingPincode
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                        helperText: 'City and State will be auto-filled',
                        helperStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: cityController,
                        label: 'City',
                        hint: 'Enter your City',
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: _buildTextField(
                        controller: stateController,
                        label: 'State',
                        hint: 'Enter State',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding * 2),
                // Save Button
                GradientButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(widget.addressId == null ? 'Save Address' : 'Update Address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
