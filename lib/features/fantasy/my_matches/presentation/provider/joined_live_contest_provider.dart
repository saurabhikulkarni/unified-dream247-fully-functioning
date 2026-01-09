import 'package:flutter/material.dart';
import 'package:Dream247/core/utils/app_storage.dart';
import 'package:Dream247/features/my_matches/data/models/live_challenges_model.dart';

class JoinedLiveContestProvider extends ChangeNotifier {
  final Map<String, LiveChallengesModel> _joinedContest = {};
  String? _matchKey = "";

  Map<String, LiveChallengesModel> get joinedContest => _joinedContest;
  String? get matchKey => _matchKey;

  void setjoinedContest(LiveChallengesModel? value, String matchKey) {
    _joinedContest[matchKey] = value!;
    _matchKey = matchKey;
    notifyListeners();
  }

  void clearjoinedContest() async {
    _joinedContest.clear();
    _matchKey = null;
    await AppStorage.clear();
    notifyListeners();
  }
}
