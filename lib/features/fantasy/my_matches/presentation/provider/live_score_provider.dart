import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_livescore_model.dart';

class LiveScoreProvider extends ChangeNotifier {
  final Map<String, List<MatchLiveScoreModel>> _liveScore = {};
  String? _matchKey = "";

  Map<String, List<MatchLiveScoreModel>> get liveScore => _liveScore;
  String? get matchKey => _matchKey;

  void setLiveScore(List<MatchLiveScoreModel>? value, String matchKey) {
    _liveScore[matchKey] = value ?? [];
    _matchKey = matchKey;
    notifyListeners();
  }

  void clearLiveScore() async {
    _liveScore.clear();
    _matchKey = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
