// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/features/winners/data/models/winners_model.dart';
import 'package:unified_dream247/features/fantasy/features/winners/data/models/stories_model.dart';
import 'package:unified_dream247/features/fantasy/features/winners/domain/repositories/winners_repositories.dart';

class WinnersDatasource extends WinnersRepositories {
  ApiImplWithAccessToken clientwithToken;
  WinnersDatasource(this.clientwithToken);

  @override
  Future<List<WinnersModel>?>? getRecentMatches(BuildContext context) async {
    final url =
        APIServerUrl.completedMatchServerUrl + APIServerUrl.getRecentWinner;

    final response = await clientwithToken.get(url);
    final json = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (json[ApiResponseString.status] == true) {
        return List<WinnersModel>.from(
            json[ApiResponseString.data].map((x) => WinnersModel.fromJson(x)));
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<StoriesModel>?>? getStories(BuildContext context) async {
    final url = APIServerUrl.otherApiServerUrl + APIServerUrl.getUserStory;

    final response = await clientwithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<StoriesModel>.from(
            res[ApiResponseString.data].map((x) => StoriesModel.fromJson(x)));
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<WinContestData>?>? loadContestWinners(
      BuildContext context,
      String challengeId,
      int skip,
      int limit,
      String fantasyType,
      String matchKey) async {
    final url =
        '${APIServerUrl.completedMatchServerUrl}${APIServerUrl.getContestWinners}$matchKey/$challengeId';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<WinContestData>.from(
            res[ApiResponseString.data].map((x) => WinContestData.fromJson(x)));
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
