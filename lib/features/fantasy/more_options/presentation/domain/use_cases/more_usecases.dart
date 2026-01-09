import 'package:flutter/material.dart';
import 'package:Dream247/features/more_options/presentation/data/models/fantasy_points_system_model.dart';
import 'package:Dream247/features/more_options/presentation/domain/repositories/more_repositories.dart';

class MoreUsecases {
  MoreRepositories moreRepositories;
  MoreUsecases(this.moreRepositories);

  Future<List<FantasyPointsSystemData>?>? pointsSystem(
      BuildContext context) async {
    var res = await moreRepositories.pointsSystem(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> requestForPromoter(
      BuildContext context, var bodyData) async {
    var res = await moreRepositories.requestForPromoter(context, bodyData);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAffiliateData(
      BuildContext context, String startDate, String endDate) async {
    var res =
        await moreRepositories.getAffiliateData(context, startDate, endDate);
    if (res != null) {
      return res;
    }
    return null;
  }
}
