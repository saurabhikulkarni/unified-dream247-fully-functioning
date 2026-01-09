import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/features/user_verification/data/models/kyc_detail_model.dart';

abstract class VerificationRepositories {
  Future<bool?> socialLogin(
      BuildContext context, String email, String deviceId);

  Future<Map<String, dynamic>?> submitAadharDetails(
      BuildContext context, String aadhaarNumber);

  Future<bool?> verifyAadharOtp(
      BuildContext context, String refId, String otp, String aadhaarNumber);

  Future<bool?> submitPANDetails(
      BuildContext context, String panNumber, String userName);

  Future<bool?> submitBankDetails(
      BuildContext context, String name, String accountNumber, String ifsc, String cityName, String bankName );

  Future<KycDetailsModel?> getKycDetails(BuildContext context);
}
