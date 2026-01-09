import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_player_teams_model.dart';

class PlayerStatsProvider extends ChangeNotifier {
  final Map<String, List<MatchPlayerTeamsModel>> _matchPlayer = {};
  String? _matchKey = "";

  Map<String, List<MatchPlayerTeamsModel>> get matchPlayer => _matchPlayer;
  String? get matchKey => _matchKey;

  void setMatchPlayers(List<MatchPlayerTeamsModel>? value, String matchKey) {
    _matchPlayer[matchKey] = value ?? [];
    _matchKey = matchKey;
    notifyListeners();
  }

  void clearUserData() async {
    _matchPlayer.clear();
    _matchKey = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
