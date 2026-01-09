import 'package:flutter/material.dart';
import 'package:Dream247/features/landing/data/models/banners_get_set.dart';

abstract class OnboardingRepositories {
  Future<Map<String, dynamic>?> sendOtp(
    BuildContext context,
    String mobileNumber,
    String referCode,
    String ftoken,
    String from,
  );

  Future<bool?> verifyLoginOtp(
    BuildContext context,
    String tempUser,
    String otp,
    String mobileNumber,
    String ftoken,
  );

  Future<bool?> getAppData(BuildContext context);

  Future<List<BannersGetSet>?>? getMainBanner(BuildContext context);
}
