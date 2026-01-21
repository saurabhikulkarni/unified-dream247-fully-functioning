import 'package:unified_dream247/features/fantasy/landing/data/models/app_data.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/match_list_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';

class AppSingleton {
  static final AppSingleton singleton = AppSingleton._internal();

  factory AppSingleton() {
    return singleton;
  }

  AppSingleton._internal();

  AppVersionResponse? _appVersionResponse;
  MatchListModel? _matchListModel;
  AllNewContestResponseModel? _contestData;
  AllContestResponseModel? _contest;
  String? _appVersion;

  MatchListModel get matchData => _matchListModel ?? MatchListModel();
  AllNewContestResponseModel get contestData =>
      _contestData ?? AllNewContestResponseModel();
  String get appVersion => _appVersion ?? '';
  AllContestResponseModel get contest => _contest ?? AllContestResponseModel();
  AppVersionResponse get appData => _appVersionResponse ?? AppVersionResponse();

  set appVersion(String appVersion) {
    _appVersion = appVersion;
  }

  set matchData(MatchListModel matchData) {
    _matchListModel = matchData;
  }

  set appData(AppVersionResponse appData) {
    _appVersionResponse = appData;
  }

  set contestData(AllNewContestResponseModel contestData) {
    _contestData = contestData;
  }

  set contest(AllContestResponseModel contest) {
    _contest = contest;
  }
}
