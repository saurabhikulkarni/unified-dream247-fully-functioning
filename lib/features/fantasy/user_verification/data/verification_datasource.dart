// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_keys.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:unified_dream247/features/fantasy/features/user_verification/data/models/kyc_detail_model.dart';
import 'package:unified_dream247/features/fantasy/features/user_verification/domain/repositories/verification_repositories.dart';
import 'package:unified_dream247/features/fantasy/features/user_verification/presentation/providers/kyc_details_provider.dart';

class VerificationDatasource implements VerificationRepositories {
  ApiImplWithAccessToken clientWithToken;
  VerificationDatasource(this.clientWithToken);

  @override
  Future<bool?> socialLogin(
      BuildContext context, String email, String deviceId) async {
    final url = APIServerUrl.kycServerUrl + APIServerUrl.socialAuthentication;
    final body = {
      ApiServerKeys.email: email,
      ApiServerKeys.deviceToken: deviceId
    };

    final response = await clientWithToken.post(url, body: body);
    var res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
        return true;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>?> submitAadharDetails(
      BuildContext context, String aadhaarNumber) async {
    final url = APIServerUrl.kycServerUrl + APIServerUrl.sendAadhaarOTP;

    final body = {ApiServerKeys.aadharNumber: aadhaarNumber};

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<bool?> verifyAadharOtp(BuildContext context, String refId, String otp,
      String aadhaarNumber) async {
    final url = APIServerUrl.kycServerUrl + APIServerUrl.verifyAadhaarOTP;

    final body = {
      ApiServerKeys.refId: refId,
      ApiServerKeys.otp: otp,
      ApiServerKeys.aadharNumber: aadhaarNumber
    };

    final response = await clientWithToken.post(url, body: body);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);

        if (context.mounted) {
          Provider.of<KycDetailsProvider>(context, listen: false)
              .kycData
              ?.aadharVerify = 1;
          Navigator.pop(context, '1');
        }
        return true;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<bool?> submitPANDetails(
      BuildContext context, String panNumber, String userName) async {
    final url = APIServerUrl.kycServerUrl + APIServerUrl.verifyPanRequest;

    final body = {
      ApiServerKeys.panNumber: panNumber,
      ApiServerKeys.name: userName
    };

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);

        return true;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);

        if (context.mounted) {
          Provider.of<KycDetailsProvider>(context, listen: false)
              .kycData!
              .panVerify = -1;
          Provider.of<KycDetailsProvider>(context, listen: false)
              .panVerifiedStatus
              .value = -1;
        }
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<bool?> submitBankDetails(
      BuildContext context,
      String name,
      String accountNumber,
      String ifsc,
      String cityName,
      String bankName) async {
    final url = APIServerUrl.kycServerUrl + APIServerUrl.verifyBankRequest;

    final body = {
      ApiServerKeys.accHolder: name,
      ApiServerKeys.accNo: accountNumber,
      ApiServerKeys.confirmAccNo: accountNumber,
      ApiServerKeys.ifscCode: ifsc,
      ApiServerKeys.type: "bank",
      ApiServerKeys.cityName: cityName,
      ApiServerKeys.bankName: bankName
    };

    final response = await clientWithToken.post(url, body: body);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
        if (context.mounted) {
          Provider.of<KycDetailsProvider>(context, listen: false)
              .kycData!
              .bankVerify = -1;
          Provider.of<KycDetailsProvider>(context, listen: false)
              .bankVerifiedStatus
              .value = -1;
          Provider.of<WalletDetailsProvider>(context, listen: false)
              .walletData!
              .allverify = 1;
        }
        return true;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<KycDetailsModel?> getKycDetails(BuildContext context) async {
    final url = APIServerUrl.kycServerUrl + APIServerUrl.getKycDetails;

    final response = await clientWithToken.get(url);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final kycDetails =
            KycDetailsModel.fromJson(res[ApiResponseString.data]);
        Provider.of<KycDetailsProvider>(context, listen: false)
            .setkycData(kycDetails);
        return kycDetails;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }
}
