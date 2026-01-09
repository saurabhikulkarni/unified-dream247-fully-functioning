// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/app_toast.dart';
import 'package:Dream247/core/global_widgets/common_widgets.dart';
import 'package:Dream247/core/global_widgets/main_button.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/menu_items/data/user_datasource.dart';
import 'package:Dream247/features/menu_items/domain/use_cases/user_usecases.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPage();
}

class _SupportPage extends State<SupportPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _messagingController = TextEditingController();

  List<String> reasonList = Strings.supportReasons;
  String selectedReason = 'Select Your Reason';
  UserUsecases userUsecases = UserUsecases(
    UserDatasource(ApiImplWithAccessToken()),
  );
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _emailController.text =
        Provider.of<UserDataProvider>(context, listen: false).userData!.email!;
    _mobileController.text = Provider.of<UserDataProvider>(
          context,
          listen: false,
        ).userData?.mobile?.toString() ??
        "";
  }

  void submitData() {
    if (valid()) {
      userUsecases.submitSupportRequest(
          context,
          _emailController.text,
          _mobileController.text,
          selectedReason,
          _messagingController.text,
          _selectedImage!);
      setState(() {
        Navigator.of(context).pop();
      });
    }
  }

  bool valid() {
    if (!AppUtils.isValidEmailAddress(_emailController.text)) {
      appToast('Please enter valid email address', context);
      return false;
    }

    if (!AppUtils.isValidMobileNumber(_mobileController.text)) {
      appToast('Please enter valid mobile number', context);
      return false;
    }

    if (_messagingController.text.length < 5) {
      appToast('Please enter valid message', context);
      return false;
    }

    if (selectedReason == 'Select Your Reason') {
      appToast('Please select your reason', context);
      return false;
    }

    return true;
  }

  void imageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    chooseImage(ImageSource.camera, context);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    chooseImage(ImageSource.gallery, context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> chooseImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Instantly show selected image
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      debugPrint('Image picking canceled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.support,
      addPadding: false,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9FC), Color(0xFFE9EEF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Support Info Card ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mainColor,
                      AppColors.mainColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _supportRow(
                      icon: Image.asset(
                        Images.imageEmail,
                        width: 28,
                        height: 28,
                        color: AppColors.white,
                      ),
                      text: AppSingleton.singleton.appData.supportemail ??
                          "support@Dream247.com",
                    ),
                    const SizedBox(height: 12),
                    _supportRow(
                      icon: const Icon(
                        Icons.call,
                        color: AppColors.white,
                        size: 28,
                      ),
                      text: AppSingleton.singleton.appData.supportmobile ??
                          "9876543210",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- Support Form Card ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightGrey.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Email"),
                    const SizedBox(height: 8),
                    customTextField(
                      _emailController,
                      "Enter Email",
                      TextInputType.emailAddress,
                      0,
                      1,
                    ),
                    const SizedBox(height: 20),
                    _label("Mobile Number"),
                    const SizedBox(height: 8),
                    customTextField(
                      _mobileController,
                      "Enter Mobile Number",
                      TextInputType.number,
                      10,
                      1,
                    ),
                    const SizedBox(height: 20),
                    _label("Reason for Support"),
                    const SizedBox(height: 8),
                    DropdownMenu<String>(
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: selectedReason,
                      onSelected: (String? value) {
                        setState(() {
                          selectedReason = value ?? '';
                        });
                      },
                      dropdownMenuEntries: reasonList.map((String item) {
                        return DropdownMenuEntry<String>(
                          value: item,
                          label: item,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _label("Message"),
                    const SizedBox(height: 8),
                    customTextField(
                      _messagingController,
                      "Enter Message",
                      TextInputType.text,
                      999,
                      3,
                    ),
                    const SizedBox(height: 20),
                    _label("Add Image"),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        imageDialog(context);
                      },
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightCard),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined,
                                      size: 32, color: AppColors.lightGrey),
                                  SizedBox(height: 6),
                                  Text(
                                    "Tap to upload image",
                                    style: TextStyle(
                                      color: AppColors.lightGrey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: MainButton(
                        onTap: () {
                          submitData();
                        },
                        margin: const EdgeInsets.only(top: 10),
                        text: Strings.submit,
                        color: AppColors.mainColor,
                        textColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportRow({required Widget icon, required String text}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.greyColor,
      ),
    );
  }
}
