import 'dart:async';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/features/landing/presentation/screens/landing_page.dart';
import 'package:unified_dream247/features/fantasy/features/onboarding/data/onboarding_datasource.dart';
import 'package:unified_dream247/features/fantasy/features/onboarding/domain/use_cases/onboarding_usecases.dart';

class OtpVerificationController extends GetxController {
  final OtpFieldController otpController = OtpFieldController();

  RxString otp = ''.obs;
  RxBool isResendEnabled = false.obs;
  RxInt remainingSeconds = 20.obs;
  RxBool isLoading = false.obs;

  Timer? _timer;

  final OnboardingUsecases onboardingUsecases = OnboardingUsecases(
    OnboardingDatasource(ApiImpl()),
  );

  late String mobileNumber;
  late String tempUser;
  late String from;

  // Isko OTP screen pe Get.arguments se populate karenge
  void initData({
    required String mobile,
    String temp = "",
    String fromWhere = "login",
  }) {
    mobileNumber = mobile;
    tempUser = temp;
    from = fromWhere;
  }

  @override
  void onInit() {
    startResendCountdown();
    super.onInit();
  }

  void onOtpCompleted(String pin) {
    otp.value = pin;
    verifyOtp();
  }

  Future<bool> verifyOtp() async {
    // if (otp.value.length != 6) {
    //   Get.snackbar(
    //     "Invalid OTP",
    //     "Please enter the 6-digit OTP.",
    //     backgroundGradient: AppColors.mainGradient,
    //     backgroundColor: AppColors.mainColor,
    //     colorText: AppColors.white,
    //   );
    //   return;
    // }

    // isLoading.value = true;

    try {
      String? ftoken = await AppStorage.getStorageValueString('ftoken');

      var response = await onboardingUsecases.verifyLoginOtp(
        Get.context!,
        tempUser,
        otp.value,
        mobileNumber,
        ftoken ?? "",
      );

      // If verification is successful, show success snackbar (you may need to handle success inside verifyLoginOtp)
      if (response) {
        Get.snackbar(
          "Success",
          "OTP Verified!",
          backgroundGradient: AppColors.mainGradient,
          backgroundColor: AppColors.mainColor,
          colorText: AppColors.white,
        );
        isLoading.value = true;
        Get.offAll(() => LandingPage());
      } else {
        Get.snackbar(
          "Invalid OTP",
          "Please enter the 6-digit OTP.",
          backgroundGradient: AppColors.mainGradient,
          backgroundColor: AppColors.mainColor,
          colorText: AppColors.white,
        );
        isLoading.value = false;
      }
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to verify OTP. Please try again.",
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!isResendEnabled.value) return;

    try {
      String? ftoken = await AppStorage.getStorageValueString('ftoken');

      await onboardingUsecases.sendOtp(
        Get.context!,
        mobileNumber,
        "",
        ftoken ?? "",
        "login",
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

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
