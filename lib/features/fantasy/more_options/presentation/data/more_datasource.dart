// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_keys.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/data/models/fantasy_points_system_model.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/domain/repositories/more_repositories.dart';

class MoreDatasource extends MoreRepositories {
  ApiImpl client;
  ApiImplWithAccessToken clientwithToken;
  MoreDatasource(this.client, this.clientwithToken);

  @override
  Future<List<FantasyPointsSystemData>?>? pointsSystem(
      BuildContext context,) async {
    final url =
        APIServerUrl.completedMatchServerUrl + APIServerUrl.getFantasyPoints;

    final response = await clientwithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        final scorecard = FantasyPointsSystemModel.fromJson(res);
        return scorecard.data != null ? scorecard.data!.toList() : [];
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> requestForPromoter(
      BuildContext context, var bodyData,) async {
    final url = APIServerUrl.otherApiServerUrl + APIServerUrl.requestPromoter;

    final response = await client.post(url,
        headers: {ApiServerKeys.contentType: ApiServerKeys.applicationJson},
        body: bodyData,);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context,);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getAffiliateData(
      BuildContext context, String startDate, String endDate,) async {
    final url =
        '${APIServerUrl.otherApiServerUrl}${APIServerUrl.getAffiliateData}$startDate&enddate=$endDate&id=${await AppStorage.getStorageValueString(AppStorageKeys.userId)}';
    final response = await clientwithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
            res[ApiResponseString.message], context,);
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }
}
