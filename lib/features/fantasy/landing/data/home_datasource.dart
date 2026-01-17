// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/app_data.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/joined_matches_model.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/match_list_model.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/notification_model.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/landing/domain/repositories/home_repositories.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/user_datasource.dart';
import 'package:unified_dream247/features/fantasy/menu_items/domain/use_cases/user_usecases.dart';
// ⚠️ DEPRECATED: Onboarding imports removed - Fantasy now uses Shop authentication

class HomeDatasource implements HomeRepositories {
  ApiImplWithAccessToken clientwithToken;
  HomeDatasource(this.clientwithToken);

  @override
  Future<bool?> getAppDataWithHeader(BuildContext context) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.getAppData;
    final response = await clientwithToken.get(url);
    // ⚠️ DEPRECATED: OnboardingUsecases removed - not needed anymore
    UserUsecases userUsecases = UserUsecases(
      UserDatasource(ApiImplWithAccessToken()),
    );

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      AppSingleton().appData = AppVersionResponse.fromJson(
        res[ApiResponseString.data],
      );
      AppUtils.getAppVersion().then((value) async {
        if (value != null) {
          AppSingleton().appVersion = value;
        } else {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          AppSingleton().appVersion = packageInfo.version;
        }
      });
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
  Future<String?> fetchPopUpBanner(BuildContext context) async {
    final url = APIServerUrl.otherApiServerUrl + APIServerUrl.popupNotify;
    final response = await clientwithToken.get(url);

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      final res = response.data;

      if (res[ApiResponseString.success] == true) {
        final image = res[ApiResponseString.data][ApiResponseString.popupImage];
        return (image != null && image is String) ? image : '';
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

    return '';
  }

  @override
  Future<List<MatchListModel>?>? getMatchList(
    BuildContext context,
    String gameType,
  ) async {
    String url = APIServerUrl.matchServerUrl +
        APIServerUrl.getMatchlistWithoutRedis +
        gameType;

    final response = await clientwithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final matches = GamesModel.fromJson(res);
        return matches.data?.upcomingMatches?.toList();
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<JoinedMatchesModel>?>? getJoinedMatches(
    BuildContext context,
    String gameType,
  ) async {
    final url = APIServerUrl.completedMatchServerUrl +
        APIServerUrl.userRecentMatches +
        gameType;

    final response = await clientwithToken.get(url);
    final json = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (json[ApiResponseString.status] == true) {
        return List<JoinedMatchesModel>.from(
          json[ApiResponseString.data].map(
            (x) => JoinedMatchesModel.fromJson(x),
          ),
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
  Future<List<NotificationModel>?>? getNotifications(
    BuildContext context,
  ) async {
    final url = APIServerUrl.otherApiServerUrl + APIServerUrl.getNotifications;

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        return List<NotificationModel>.from(
          res[ApiResponseString.data].map((x) => NotificationModel.fromJson(x)),
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
  Future<bool?> updateContestWon(BuildContext context) async {
    final url = APIServerUrl.userServerUrl + APIServerUrl.updateContestWon;

    final response = await clientwithToken.get(url);

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      return true;
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return false;
  }
}
