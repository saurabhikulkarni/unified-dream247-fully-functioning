// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
// import 'package:Dream247/core/app_constants/app_colors.dart';
// import 'package:Dream247/core/utils/app_storage.dart';
// import 'package:Dream247/features/onboarding/data/onboarding_datasource.dart';
// import 'package:Dream247/features/onboarding/domain/use_cases/onboarding_usecases.dart';

// class LoginController extends GetxController {
//   final TextEditingController loginController = TextEditingController();
//   final TextEditingController referralCodeController = TextEditingController();

//   RxBool isChecked = false.obs;
//   RxBool isLoading = false.obs;
//   RxBool showReferralField = false.obs;
//   RxBool readOnly = false.obs;
//   RxBool isOtpScreen = false.obs;

//   bool get isMobileValid => loginController.text.trim().length == 10;

//   final OnboardingUsecases onboardingUsecases = OnboardingUsecases(
//     OnboardingDatasource(ApiImpl()),
//   );

//   void toggleCheckbox(bool? value) {
//     isChecked.value = value ?? false;
//   }

//   void toggleReferralField() {
//     showReferralField.value = !showReferralField.value;
//   }

//   Future<void> continueToOtp(BuildContext context) async {
//     FocusScope.of(context).unfocus();

//     if (!isChecked.value) {
//       Get.snackbar(
//         "Warning",
//         "Please confirm you're above 18 years.",
//         backgroundGradient: AppColors.mainGradient,
//         backgroundColor: AppColors.mainColor,
//         colorText: AppColors.white,
//       );
//       return;
//     }

//     if (!isMobileValid) {
//       Get.snackbar(
//         "Invalid Number",
//         "Please enter a valid 10-digit mobile number.",
//         backgroundGradient: AppColors.mainGradient,
//         backgroundColor: AppColors.mainColor,
//         colorText: AppColors.white,
//       );
//       return;
//     }

//     isLoading.value = true;

//     try {
//       String? ftoken = await AppStorage.getStorageValueString('ftoken');

//       await onboardingUsecases.sendOtp(
//         context,
//         loginController.text.trim(),
//         referralCodeController.text.trim(),
//         ftoken ?? "",
//         "login",
//       );
//     } catch (e) {
//       debugPrint("Error sending OTP: $e");
//       Get.snackbar(
//         "Error",
//         "Failed to send OTP. Please try again.",
//         backgroundGradient: AppColors.mainGradient,
//         backgroundColor: AppColors.mainColor,
//         colorText: AppColors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   @override
//   void onClose() {
//     loginController.dispose();
//     referralCodeController.dispose();
//     super.onClose();
//   }

//   void clearFields() {
//     loginController.clear();
//     referralCodeController.clear();
//     isChecked.value = false;
//   }
// }

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:Dream247/core/app_constants/app_storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/landing/presentation/screens/landing_page.dart';
import 'package:Dream247/features/onboarding/data/onboarding_datasource.dart';
import 'package:Dream247/features/onboarding/domain/use_cases/onboarding_usecases.dart';

class LoginController extends GetxController {
  // ------------------ Text Controllers ------------------
  final TextEditingController loginController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();
  final OtpFieldController otpController = OtpFieldController();

  // ------------------ Reactive Variables ------------------
  RxBool isChecked = false.obs;
  RxBool isLoading = false.obs;
  RxBool isOtpScreen = false.obs;
  RxBool showReferralField = false.obs;

  // OTP related
  RxString otp = ''.obs;
  RxBool isResendEnabled = false.obs;
  RxInt remainingSeconds = 30.obs;

  Timer? _timer;

  // ------------------ Extra Variables (keep these) ------------------
  late String mobileNumber;
  late String tempUser;
  late String from;
  // ------------------- For auto fill Referral Code -------------------
  @override
  void onInit() async {
    super.onInit();

    final savedReferral =
        await AppStorage.getStorageValueString("referral_code");

    if (savedReferral != null && savedReferral.isNotEmpty) {
      referralCodeController.text = savedReferral;
      showReferralField.value = true;
    }
  }

  // ------------------ API Setup ------------------
  final OnboardingUsecases onboardingUsecases = OnboardingUsecases(
    OnboardingDatasource(ApiImpl()),
  );

  bool get isMobileValid => loginController.text.trim().length == 10;

  // ------------------ Init Data (for OTP Screen) ------------------
  void initData({
    required String mobile,
    String temp = "",
    String fromWhere = "login",
  }) {
    mobileNumber = mobile;
    tempUser = temp;
    from = fromWhere;
  }

  // ------------------ Continue to OTP ------------------
  Future<void> continueToOtp(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!isChecked.value) {
      Get.snackbar(
        "Warning",
        "Please confirm you're above 18 years.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );
      return;
    }

    if (!isMobileValid) {
      Get.snackbar(
        "Invalid Number",
        "Please enter a valid 10-digit mobile number.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      String? ftoken =
          await AppStorage.getStorageValueString(AppStorageKeys.fcmToken);

      var response = await onboardingUsecases.sendOtp(
        context,
        loginController.text.trim(),
        referralCodeController.text.trim(),
        ftoken ?? "",
        "login",
      );

      // Check if data contains tempUser or userId
      var data = response?["data"];
      if (data != null) {
        if (data["userId"] != null && data["userId"].toString().isNotEmpty) {
          tempUser = "";
        } else if (data["tempUser"] != null &&
            data["tempUser"].toString().isNotEmpty) {
          tempUser = data["tempUser"];
        }
      }

      // Set values for OTP verification
      initData(
        mobile: loginController.text.trim(),
        temp: tempUser,
        fromWhere: "login",
      );

      // Switch to OTP screen
      isOtpScreen.value = true;
      startResendCountdown();
    } catch (e) {
      debugPrint("Error sending OTP: $e");
      Get.snackbar(
        "Error",
        "Failed to send OTP. Please try again.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------ Verify OTP ------------------
  Future<void> verifyOtp(String otpValue) async {
    otp.value = otpValue;

    if (otp.value.length != 6) {
      Get.snackbar(
        "Invalid OTP",
        "Please enter the 6-digit OTP.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      String? ftoken = await AppStorage.getStorageValueString('ftoken');

      var response = await onboardingUsecases.verifyLoginOtp(
        Get.context!,
        tempUser,
        otp.value,
        mobileNumber,
        ftoken ?? "",
      );

      if (response) {
        Get.snackbar(
          "Success",
          "OTP Verified!",
          backgroundGradient: AppColors.mainGradient,
          backgroundColor: AppColors.mainColor,
          colorText: AppColors.white,
        );

        Get.offAll(() => LandingPage());
      } else {
        Get.snackbar(
          "Invalid OTP",
          "Incorrect OTP entered.",
          backgroundGradient: AppColors.mainGradient,
          backgroundColor: AppColors.mainColor,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to verify OTP. Please try again.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------ Resend OTP ------------------
  Future<void> resendOtp() async {
    if (!isResendEnabled.value) return;

    try {
      String? ftoken = await AppStorage.getStorageValueString('ftoken');

      await onboardingUsecases.sendOtp(
        Get.context!,
        mobileNumber,
        tempUser,
        ftoken ?? "",
        from,
      );

      Get.snackbar(
        "OTP Sent",
        "A new OTP has been sent to your number.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );

      otpController.clear();
      otp.value = "";
      startResendCountdown();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to resend OTP. Please try again.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );
    }
  }

  // ------------------ Resend Countdown ------------------
  void startResendCountdown() {
    isResendEnabled.value = false;
    remainingSeconds.value = 30;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value == 0) {
        timer.cancel();
        isResendEnabled.value = true;
      } else {
        remainingSeconds.value--;
      }
    });
  }

  // ------------------ Misc ------------------
  void clearFields() {
    loginController.clear();
    referralCodeController.clear();
    isChecked.value = false;
    otpController.clear();
  }

  @override
  void onClose() {
    _timer?.cancel();
    loginController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }
}
