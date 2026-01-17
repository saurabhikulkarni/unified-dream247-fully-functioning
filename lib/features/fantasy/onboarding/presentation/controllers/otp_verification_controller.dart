import 'dart:async';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/screens/landing_page.dart';
import 'package:unified_dream247/features/fantasy/onboarding/data/onboarding_datasource.dart';
import 'package:unified_dream247/features/fantasy/onboarding/domain/use_cases/onboarding_usecases.dart';

// ⚠️ DEPRECATED: Fantasy no longer has OTP verification
// All authentication is now handled by Shop's MSG91 OTP system
// This controller is kept for backward compatibility but should not be used
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
    String temp = '',
    String fromWhere = 'login',
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
    // ⚠️ DEPRECATED: Use Shop's authentication instead
    // Fantasy should not handle OTP verification
    Get.snackbar(
      'Error',
      'Failed to verify OTP. Please try again.',
      backgroundGradient: AppColors.mainGradient,
      backgroundColor: AppColors.mainColor,
      colorText: AppColors.white,
    );
    return false;
  }

  Future<void> resendOtp() async {
    if (!isResendEnabled.value) return;

    try {
      String? ftoken = await AppStorage.getStorageValueString('ftoken');

      await onboardingUsecases.sendOtp(
        Get.context!,
        mobileNumber,
        '',
        ftoken ?? '',
        'login',
      );

      Get.snackbar(
        'OTP Sent',
        'A new OTP has been sent to your number.',
        backgroundGradient: AppColors.mainGradient,
        backgroundColor: AppColors.mainColor,
        colorText: AppColors.white,
      );

      otpController.clear();
      otp.value = '';
      startResendCountdown();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP. Please try again.',
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
