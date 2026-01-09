// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/features/user_verification/data/models/kyc_detail_model.dart';
import 'package:unified_dream247/features/fantasy/features/user_verification/domain/repositories/verification_repositories.dart';

class VerificationUsecases {
  VerificationRepositories verificationRepositories;
  VerificationUsecases(this.verificationRepositories);

  Future<bool?> socialLogin(
      BuildContext context, String email, String deviceId) async {
    var res =
        await verificationRepositories.socialLogin(context, email, deviceId);
    if (res ?? false) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> submitAadharDetails(
      BuildContext context, String aadhaarNumber) async {
    var res = await verificationRepositories.submitAadharDetails(
        context, aadhaarNumber);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<bool> verifyAadharOtp(BuildContext context, String refId, String otp,
      String aadhaarNumber) async {
    var res = await verificationRepositories.verifyAadharOtp(
        context, refId, otp, aadhaarNumber);
    if (res ?? false) {
      return true;
    }
    return false;
  }
  

  Future<bool?> submitPANDetails(
      BuildContext context, String panNumber, String userName) async {
    var res = await verificationRepositories.submitPANDetails(
        context, panNumber, userName);
    if (res ?? false) {
      return res;
    }
    return null;
  }

  Future<bool?> submitBankDetails(BuildContext context, String name,
      String accountNumber, String ifsc,
      String cityName,
      String bankName ) async {
    var res = await verificationRepositories.submitBankDetails(
        context, name, accountNumber, ifsc, cityName, bankName );
    if (res ?? false) {
      return res;
    }
    return null;
  }

  Future<KycDetailsModel?> getKycDetails(BuildContext context) async {
    var res = await verificationRepositories.getKycDetails(context);
    if (res != null) {
      return res;
    }
    return null;
  }
}
