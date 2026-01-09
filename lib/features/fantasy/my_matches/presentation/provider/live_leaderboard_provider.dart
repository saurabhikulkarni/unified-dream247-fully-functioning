import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/live_leaderboard_model.dart';

class LiveLeaderboardProvider extends ChangeNotifier {
  final Map<String, List<LiveJointeams>> _liveJoinTeams = {};
  String? _matchKey = "";

  Map<String, List<LiveJointeams>> get liveJoinTeams => _liveJoinTeams;
  String? get matchKey => _matchKey;

  void setliveJoinTeams(List<LiveJointeams>? value, String matchKey) {
    _liveJoinTeams[matchKey] = value!;
    _matchKey = matchKey;
    notifyListeners();
  }

  void clearliveJoinTeams() async {
    _liveJoinTeams.clear();
    _matchKey = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
