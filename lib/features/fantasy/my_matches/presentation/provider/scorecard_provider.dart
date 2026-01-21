import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/scorecard_model.dart';

class ScorecardProvider extends ChangeNotifier {
  final Map<String, List<ScorecardModel>> _scorecard = {};
  String? _matchKey = '';

  Map<String, List<ScorecardModel>> get scoreCard => _scorecard;
  String? get matchKey => _matchKey;

  void setScorecard(List<ScorecardModel>? value, String matchKey) {
    _scorecard[matchKey] = value ?? [];
    _matchKey = matchKey;
    notifyListeners();
  }

  void clearScoreCard() async {
    _scorecard.clear();
    _matchKey = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
