import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';

class TeamPreviewProvider with ChangeNotifier {
  final Map<String, List<UserTeamsModel>> _userTeams = {};

  List<UserTeamsModel>? getUserTeam(String teamId) {
    return _userTeams[teamId];
  }

  void setUserTeam(String teamId, List<UserTeamsModel> teams) {
    if (!_userTeams.containsKey(teamId)) {
      _userTeams[teamId] = teams;
      notifyListeners();
    }
  }

  void clearUserData() async {
    _userTeams.clear();
    await AppStorage.clear();
    notifyListeners();
  }
}
