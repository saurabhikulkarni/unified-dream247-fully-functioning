// ignore_for_file: constant_identifier_names, use_build_context_synchronously
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
import 'package:Dream247/features/menu_items/data/user_datasource.dart';
import 'package:Dream247/features/menu_items/domain/use_cases/user_usecases.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

enum Gender { Male, Female }

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  File? userImage;
  String profileImageName = "";
  Gender selectedGender = Gender.Male;
  UserUsecases userUsecases = UserUsecases(
    UserDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
  }

  void submitData() async {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    if (!AppUtils.isValidTeamName(_teamNameController.text)) {
      appToast('Please enter valid Team Name', context);
    } else {
      await userUsecases
          .updateProfile(
        context,
        _teamNameController.text.trim(),
        _userNameController.text,
        _stateController.text,
        selectedGender.name,
        _cityController.text,
        _addressController.text,
        _dobController.text,
        _pincodeController.text,
      )
          .then((value) {
        if (value != null) {
          setState(() {
            userData!.name = _userNameController.text;
            userData.team = _teamNameController.text;
            userData.state = _stateController.text;
            userData.gender = selectedGender.name;
            userData.city = _cityController.text;
            userData.address = _addressController.text;
            userData.dob = _dobController.text;
            userData.pincode = int.parse(_pincodeController.text);
            userData.teamNameUpdateStatus = true;
            Provider.of<UserDataProvider>(
              context,
              listen: false,
            ).updateUser(userData);
            Navigator.of(context).pop();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    _teamNameController.text = userData?.team ?? "";
    _userNameController.text = userData?.name ?? "";
    _emailController.text = userData?.email ?? "";
    _mobileController.text = userData?.mobile.toString() ?? "";
    _dobController.text = userData?.dob ?? "";
    _pincodeController.text = userData?.pincode.toString() ?? "";
    _addressController.text = userData?.address ?? "";
    _cityController.text = userData?.city ?? "";
    _stateController.text = userData?.state ?? "";
    selectedGender = userData?.gender == 'Male' ? Gender.Male : Gender.Female;

    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.editProfile,
      addPadding: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.mainColor.withValues(alpha: 0.05),
              AppColors.white,
              AppColors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Profile Avatar Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor:
                              AppColors.mainColor.withValues(alpha: 0.2),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: userImage != null
                                ? FileImage(userImage!)
                                : (userData?.image != null &&
                                            (userData?.image ?? "").isNotEmpty
                                        ? NetworkImage(userData?.image ?? "")
                                        : const AssetImage(
                                            Images.imageDefalutPlayer))
                                    as ImageProvider,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 70,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            imageDialog(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.mainColor,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Form Card Section
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightGrey.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      customTextFieldReadOnly(
                        _teamNameController,
                        "Enter Team Name",
                        TextInputType.name,
                        10,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _userNameController,
                        "Enter User Name",
                        TextInputType.name,
                        0,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _emailController,
                        "Enter Email Address",
                        TextInputType.emailAddress,
                        0,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _mobileController,
                        "Enter Mobile Number",
                        TextInputType.number,
                        10,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _dobController,
                        "Enter DOB",
                        TextInputType.name,
                        0,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _stateController,
                        "Enter State",
                        TextInputType.name,
                        0,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _pincodeController,
                        "Enter Pincode",
                        TextInputType.number,
                        6,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),

                      // Gender Selection
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<Gender>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tileColor: selectedGender == Gender.Male
                                  ? AppColors.mainColor.withValues(alpha: 0.1)
                                  : AppColors.transparent,
                              title: const Text(
                                'Male',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: AppColors.letterColor,
                                ),
                              ),
                              value: Gender.Male,
                              groupValue: selectedGender,
                              activeColor: AppColors.mainColor,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<Gender>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tileColor: selectedGender == Gender.Female
                                  ? AppColors.mainColor.withValues(alpha: 0.1)
                                  : AppColors.transparent,
                              title: const Text(
                                'Female',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: AppColors.letterColor,
                                ),
                              ),
                              value: Gender.Female,
                              groupValue: selectedGender,
                              activeColor: AppColors.mainColor,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _addressController,
                        "Enter address",
                        TextInputType.name,
                        0,
                        false,
                        1,
                      ),
                      const SizedBox(height: 18),
                      customTextFieldReadOnly(
                        _cityController,
                        "Enter City",
                        TextInputType.name,
                        0,
                        false,
                        1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                MainButton(
                  color: AppColors.mainColor,
                  textColor: Colors.white,
                  onTap: () {
                    submitData();
                  },
                  text: 'Submit',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget fieldTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: AppColors.letterColor,
        ),
      ),
    );
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
        userImage = File(pickedFile.path);
        profileImageName = pickedFile.name;
      });

      // Upload the same file
      uploadImage(userImage!);
    } else {
      debugPrint('Image picking canceled.');
    }
  }

  void uploadImage(File imageFile) async {
    try {
      final value = await userUsecases.uploadImage(context, imageFile);

      if (value != null && value.isNotEmpty) {
        final userData =
            Provider.of<UserDataProvider>(context, listen: false).userData;
        userData!.image = value;

        Provider.of<UserDataProvider>(
          context,
          listen: false,
        ).updateUser(userData);
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      appToast("Failed to upload image", context);
    }
  }

  // void uploadImage() {
  //   final userData =
  //       Provider.of<UserDataProvider>(context, listen: false).userData;
  //   if (userImage == null) {
  //   } else {
  //     String fileName = "${userData?.team}_$profileImageName";
  //     AccountsServices.uploadImageToS3(
  //       userImage!,
  //       "user_profiles",
  //       fileName,
  //     ).then((value) {
  //       String profileLoc = "user_profiles/$fileName";
  //       AccountsServices.uploadImage(context, profileLoc);
  //       userData!.image =
  //           "https://-store.s3.ap-south-1.amazonaws.com/$profileLoc";
  //       Provider.of<UserDataProvider>(
  //         context,
  //         listen: true,
  //       ).updateUser(userData);
  //     });
  //   }
  // }
}
