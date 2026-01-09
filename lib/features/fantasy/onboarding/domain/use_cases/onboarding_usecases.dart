// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/models/banners_get_set.dart';
import 'package:unified_dream247/features/fantasy/features/onboarding/domain/repositories/onboarding_repositories.dart';

class OnboardingUsecases {
  OnboardingRepositories onboardingRepositories;
  OnboardingUsecases(this.onboardingRepositories);
  Future<bool?> getAppData(BuildContext context) async {
    var res = await onboardingRepositories.getAppData(context);
    if (res != null) {
      return true;
    }
    return null;
  }

  Future<Map<String, dynamic>?> sendOtp(
    BuildContext context,
    String mobileNumber,
    String referCode,
    String ftoken,
    String from,
  ) async {
    var res = await onboardingRepositories.sendOtp(
      context,
      mobileNumber,
      referCode,
      ftoken,
      from,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<bool> verifyLoginOtp(
    BuildContext context,
    String tempUser,
    String otp,
    String mobileNumber,
    String ftoken,
  ) async {
    var res = await onboardingRepositories.verifyLoginOtp(
      context,
      tempUser,
      otp,
      mobileNumber,
      ftoken,
    );
    if (res ?? false) {
      return true;
    }
    return false;
  }

  Future<List<BannersGetSet>?>? getMainBanner(BuildContext context) async {
    var res = await onboardingRepositories.getMainBanner(context);
    return res;
  }
}
