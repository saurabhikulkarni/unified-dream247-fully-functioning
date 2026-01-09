import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Sepide");
    _emailController = TextEditingController(text: "theflutterway@gmail.com");
    _phoneController = TextEditingController(text: "9876543210");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
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
                  const SnackBar(content: Text("Change photo")),
                );
              },
              child: const Text("Change Photo"),
            ),
          ),
          const SizedBox(height: defaultPadding * 1.5),
          Text(
            "Full Name",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: "Enter your full name",
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            "Email",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: "Enter your email",
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            "Phone Number",
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
              hintText: "Enter your phone number (e.g., 9876543210)",
              errorText: _phoneError,
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton(
            onPressed: () {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated")),
              );
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }
}
