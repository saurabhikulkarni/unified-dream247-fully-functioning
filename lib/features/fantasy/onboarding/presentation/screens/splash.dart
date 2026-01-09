// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'package:unified_dream247/features/fantasy/core/utils/apk_referral_helper.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/onboarding/presentation/screens/onboard_banner_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/landing/data/home_datasource.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/landing/domain/use_cases/home_usecases.dart';
import 'package:unified_dream247/features/fantasy/onboarding/data/onboarding_datasource.dart';
import 'package:unified_dream247/features/fantasy/onboarding/domain/use_cases/onboarding_usecases.dart';
import 'package:unified_dream247/features/fantasy/onboarding/presentation/widgets/app_update_dialog.dart';
import 'package:unified_dream247/features/fantasy/onboarding/presentation/widgets/maintenance_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String? loginToken;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final OnboardingUsecases onboardingUsecases = OnboardingUsecases(
    OnboardingDatasource(ApiImpl()),
  );
  final HomeUsecases homeUsecases = HomeUsecases(
    HomeDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(milliseconds: 700), () async {
    //   await _handleApkReferralTest();
    // });

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    getAppData();
  }

  Future<void> _handleApkReferralTest() async {
    debugPrint("REQUESTING ALL FILES PERMISSION");

    final granted = await ApkReferralHelper.requestAllFilesPermission();

    debugPrint("PERMISSION GRANTED: $granted");

    if (!granted) return;

    final referral = await ApkReferralHelper.getReferralFromApkName();

    debugPrint("APK SCAN RESULT: $referral");

    if (referral != null && referral.isNotEmpty) {
      await AppStorage.saveToStorageString(
        "referral_code",
        referral,
      );
      debugPrint("REFERRAL SAVED: $referral");
    }
  }

  Future<void> getSessionData() async {
    loginToken = await AppStorage.getStorageValueString(
      AppStorageKeys.authToken,
    );

    // 🔴 IMPORTANT: Only scan APK if user is NOT logged in
    if (loginToken == null || loginToken!.isEmpty) {
      debugPrint("USER NOT LOGGED IN → START APK SCAN");
      await _handleApkReferralTest();
    } else {
      debugPrint("USER LOGGED IN → SKIP APK SCAN");
    }
  }

  Future<void> getAppData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await getSessionData();
    if (loginToken != null && (loginToken ?? "").isNotEmpty) {
      await homeUsecases.getAppDataWithHeader(context);
    } else {
      await onboardingUsecases.getAppData(context);
    }

    int maintenanceAndroid = AppSingleton.singleton.appData.maintenance ?? 0;
    int maintenanceIOS = AppSingleton.singleton.appData.maintenanceIos ?? 0;

    if ((Platform.isAndroid && maintenanceAndroid == 1) ||
        (Platform.isIOS && maintenanceIOS == 1)) {
      showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return const PopScope(canPop: false, child: MaintenanceDialog());
        },
      );
      return;
    }

    int liveVersion = Platform.isAndroid
        ? AppSingleton.singleton.appData.version ?? 1
        : AppSingleton.singleton.appData.iosVersion ?? 1;

    int currentVersion = int.parse(packageInfo.buildNumber);

    if (currentVersion >= liveVersion) {
      AppStorage.getStorageValueBool(AppStorageKeys.logedIn).then((value) {
        Timer(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardBannerScreen(isLoggedIn: value == true),
            ),
          ),
        );
      });
    } else {
      showModalBottomSheet<void>(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return const PopScope(canPop: false, child: AppUpdateBottomSheet());
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // UI with Fade + Scale Animation (Logo Only)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.blackColor),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                Images.nameLogo,
                width: 260,
                height: 260,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
