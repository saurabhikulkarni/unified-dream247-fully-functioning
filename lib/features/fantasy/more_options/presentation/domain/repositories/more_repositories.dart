import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/data/models/fantasy_points_system_model.dart';

abstract class MoreRepositories {
  Future<List<FantasyPointsSystemData>?>? pointsSystem(BuildContext context);

  Future<Map<String, dynamic>?> requestForPromoter(
      BuildContext context, var bodyData,);

  Future<Map<String, dynamic>?> getAffiliateData(
      BuildContext context, String startDate, String endDate,);
}
