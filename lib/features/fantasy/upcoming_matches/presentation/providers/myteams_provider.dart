import 'package:flutter/material.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';

class MyTeamsProvider extends ChangeNotifier {
  final Map<String, List<TeamsModel>> _myTeams = {};
  String? _matchKey = "";

  Map<String, List<TeamsModel>> get myTeams => _myTeams;
  String? get matchKey => _matchKey;

  void setMyTeams(List<TeamsModel>? value, String matchKey) {
    _myTeams[matchKey] = value ?? [];
    _matchKey = matchKey;
    notifyListeners();
  }

  void updateMyTeams(List<TeamsModel> updatedTeams, String matchId) {
    myTeams[matchId] = updatedTeams;
    notifyListeners();
  }

  void clearUserData() async {
    _myTeams.clear();
    _matchKey = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
