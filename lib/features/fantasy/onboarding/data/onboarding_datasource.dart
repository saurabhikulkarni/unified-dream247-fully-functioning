// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_keys.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/home_datasource.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/models/app_data.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/models/banners_get_set.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/features/landing/domain/use_cases/home_usecases.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/data/user_datasource.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/domain/use_cases/user_usecases.dart';
import 'package:unified_dream247/features/fantasy/features/onboarding/domain/repositories/onboarding_repositories.dart';

class OnboardingDatasource implements OnboardingRepositories {
  ApiImpl client;
  OnboardingDatasource(this.client);
  static final headers = {
    ApiServerKeys.contentType: ApiServerKeys.applicationJson,
  };

  @override
  Future<bool?> getAppData(BuildContext context) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.getAppData;
    final response = await client.get(
      url,
      headers: {ApiServerKeys.contentType: ApiServerKeys.applicationJson},
    );
    UserUsecases userUsecases = UserUsecases(
      UserDatasource(ApiImplWithAccessToken()),
    );

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      AppSingleton().appData = AppVersionResponse.fromJson(
        res[ApiResponseString.data],
      );
      // AppUtils.getAppVersion().then(
      //   (value) async {
      //     if (value != null) {
      //       AppSingleton().appVersion = value;
      //     } else {
      //       PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //       AppSingleton().appVersion = packageInfo.version;
      //     }
      //   },
      // );
      if ((Platform.isAndroid &&
              AppSingleton.singleton.appData.maintenance == 0) ||
          (Platform.isIOS &&
              AppSingleton.singleton.appData.maintenanceIos == 0)) {
        if (await AppStorage.getStorageValueBool(AppStorageKeys.logedIn) ==
            true) {
          if (context.mounted) {
            userUsecases.getUserDetails(context);
          }
        }
      }
      return true;
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>?> sendOtp(
    BuildContext context,
    String mobileNumber,
    String referCode,
    String ftoken,
    String from,
  ) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.sendOtp;

    final body = {
      ApiServerKeys.mobile: mobileNumber,
      ApiServerKeys.refercode: referCode,
      ApiServerKeys.appId: ftoken,
    };

    final response = await client.post(url, headers: headers, body: body);
    var res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return res;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<bool?> verifyLoginOtp(
    BuildContext context,
    String tempUser,
    String otp,
    String mobileNumber,
    String ftoken,
  ) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.loginOtp;
    final body = {
      ApiServerKeys.otp: otp,
      ApiServerKeys.mobile: mobileNumber,
      ApiServerKeys.appId: ftoken,
    };

    if (tempUser != "") {
      body['tempUser'] = tempUser;
    }
    final response = await client.post(url, headers: headers, body: body);

    final res = response.data;

    HomeUsecases homeUsecases = HomeUsecases(
      HomeDatasource(ApiImplWithAccessToken()),
    );

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        AppStorage.saveToStorageString(
          AppStorageKeys.authToken,
          res[ApiResponseString.data][ApiResponseString.authKey] ?? "",
        );
        AppStorage.saveToStorageBool(AppStorageKeys.logedIn, true);
        await homeUsecases.getAppDataWithHeader(context);
        return true;
      } else {
        return false;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }

  @override
  Future<List<BannersGetSet>?> getMainBanner(BuildContext context) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.getAppData;
    // this is /user/get-version

    final response = await client.get(
      url,
      headers: {
        ApiServerKeys.contentType: ApiServerKeys.applicationJson,
      },
    );

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final List list = res[ApiResponseString.data]['bannerData'];
        return list.map((e) => BannersGetSet.fromJson(e)).toList();
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }
}
