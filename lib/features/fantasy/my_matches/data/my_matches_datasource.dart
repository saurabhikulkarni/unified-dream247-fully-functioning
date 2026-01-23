// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/live_challenges_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_livescore_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_player_teams_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/my_matches_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/player_preview_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/scorecard_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/team_compare_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/team_pdf_range_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/repositories/my_matches_repositories.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/joined_live_contest_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/live_score_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/player_stats_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/scorecard_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/player_details_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/team_preview_provider.dart';

class MyMatchesDatasource extends MyMatchesRepositories {
  ApiImplWithAccessToken clientwithToken;
  MyMatchesDatasource(this.clientwithToken);

  @override
  Future<List<MyMatchesModel>?>? getUpcomingMatches(
    BuildContext context,
    String gameType,
  ) async {
    final url = APIServerUrl.matchServerUrl +
        APIServerUrl.getJoinedUpcomingMatches +
        gameType;

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<MyMatchesModel>.from(
          res[ApiResponseString.data].map((x) => MyMatchesModel.fromJson(x)),
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<MyMatchesModel>?> getLiveMatches(
    BuildContext context,
    String gameType,
  ) async {
    final url = APIServerUrl.liveMatchServerUrl +
        APIServerUrl.getLiveMatches +
        gameType;

    final response = await clientwithToken.get(url);

    final res = response.data;

    try {
      if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
        if (res[ApiResponseString.success] == true &&
            res[ApiResponseString.data] != null) {
          List<MyMatchesModel> matches = List<MyMatchesModel>.from(
            res[ApiResponseString.data].map((x) => MyMatchesModel.fromJson(x)),
          );
          if (matches.isNotEmpty) {
            return matches;
          }
        }
      }
    } catch (e) {
      ApiServerUtil.manageException(res[ApiResponseString.message], context);
    }

    return null;
  }

  @override
  Future<List<MyMatchesModel>?>? getCompletedMatches(
    BuildContext context,
    String gameType,
    int cursor,
  ) async {
    final url =
        '${APIServerUrl.completedMatchServerUrl}${APIServerUrl.getCompletedMatches}$gameType&limit=10&cursor=$cursor';

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<MyMatchesModel>.from(
          res[ApiResponseString.data].map((x) => MyMatchesModel.fromJson(x)),
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<MyMatchesModel>?>? getCompletedOldMatches(
    BuildContext context,
    String gameType,
    int skip,
    int limit,
  ) async {
    final url =
        '${APIServerUrl.completedMatchServerUrl}${APIServerUrl.getCompletedOldMatches}$gameType&skip=$skip&limit=$limit';

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<MyMatchesModel>.from(
          res[ApiResponseString.data].map((x) => MyMatchesModel.fromJson(x)),
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<LiveChallengesModel> getJoinedLiveContests(
    BuildContext context,
    int skip,
    int limit,
  ) async {
    debugPrint('🎯 [JOINED_CONTESTS] ========== getJoinedLiveContests START ==========');
    var provider = Provider.of<JoinedLiveContestProvider>(
      context,
      listen: false,
    );
    String matchKey = AppSingleton.singleton.matchData.id ?? '';
    debugPrint('🎯 [JOINED_CONTESTS] matchKey: $matchKey');
    debugPrint('🎯 [JOINED_CONTESTS] skip: $skip, limit: $limit');

    final url =
        '${APIServerUrl.myJoinContestServerUrl}${APIServerUrl.getJoinedContests}${AppSingleton.singleton.matchData.id!}&skip=$skip&limit=$limit';
    debugPrint('🎯 [JOINED_CONTESTS] URL: $url');
    
    final response = await clientwithToken.get(url);
    final res = response.data;

    debugPrint('🎯 [JOINED_CONTESTS] Response status: ${response.statusCode}');
    debugPrint('🎯 [JOINED_CONTESTS] Response keys: ${res?.keys?.toList()}');
    debugPrint('🎯 [JOINED_CONTESTS] status: ${res[ApiResponseString.status]}, message: ${res[ApiResponseString.message]}');

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        debugPrint('🎯 [JOINED_CONTESTS] ✅ Success - parsing contests');
        final contests = LiveChallengesModel.fromJson(res);
        debugPrint('🎯 [JOINED_CONTESTS] Parsed contests count: ${contests.data?.length ?? 0}');
        if (contests.data != null && contests.data!.isNotEmpty) {
          for (int i = 0; i < (contests.data!.length > 3 ? 3 : contests.data!.length); i++) {
            debugPrint('🎯 [JOINED_CONTESTS] Contest $i: ${contests.data![i].contestName}, status: ${contests.data![i].matchChallengeStatus}, totalwinners: ${contests.data![i].totalwinners}');
          }
        }
        provider.setjoinedContest(contests, matchKey);
        return contests;
      } else {
        debugPrint('🎯 [JOINED_CONTESTS] ⚠️ API status=false');
      }
    } else {
      debugPrint('🎯 [JOINED_CONTESTS] ❌ HTTP error: ${response.statusCode}');
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return res;
  }

  @override
  Future<List<TeamsModel>> completeMatchGetMyTeams(BuildContext context) async {
    final url = APIServerUrl.teamsServerUrl +
        APIServerUrl.completeMatchGetMyTeams +
        AppSingleton.singleton.matchData.id!;

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        AppUtils.teamsCount.value = res[ApiResponseString.data].length ?? 0;
        return List<TeamsModel>.from(
          res[ApiResponseString.data].map((x) => TeamsModel.fromJson(x)),
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<List<PlayerPreviewModel>?>? dreamTeam(
    BuildContext context,
    String matchKey,
  ) async {
    final url = APIServerUrl.teamsServerUrl + APIServerUrl.dreamTeam + matchKey;

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<PlayerPreviewModel>.from(
          res[ApiResponseString.data].map(
            (x) => PlayerPreviewModel.fromJson(x),
          ),
        );
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<TeamPdfRangeModel>?>? getTeamFilesPdf(
    BuildContext context,
    String challengeId,
  ) async {
    final url = APIServerUrl.otherApiServerUrl +
        APIServerUrl.getTeamFilesPdf +
        challengeId;

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      return List<TeamPdfRangeModel>.from(
        res[ApiResponseString.data].map((x) => TeamPdfRangeModel.fromJson(x)),
      );
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<ScorecardModel>> getScorecard(BuildContext context) async {
    var provider = Provider.of<ScorecardProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';
    final url = APIServerUrl.liveMatchServerUrl +
        APIServerUrl.getScorecard +
        AppSingleton.singleton.matchData.id!;

    final response = await clientwithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        List<ScorecardModel> scoreCard = List<ScorecardModel>.from(
          res[ApiResponseString.data].map((x) => ScorecardModel.fromJson(x)),
        );
        provider.setScorecard(scoreCard, matchKey);
        return scoreCard;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<TeamCompareModel?> teamCompare(
    BuildContext context,
    String team1id,
    String team2id,
    String userId,
    String challengeId,
    String l1,
    String l2,
  ) async {
    final url =
        '${APIServerUrl.teamsServerUrl}${APIServerUrl.teamCompare}$team1id&team2id=$team2id&matchkey=${AppSingleton.singleton.matchData.id}&team2UserId=$userId&challengeId=$challengeId&l1=$l1&l2=$l2';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final teamCompare = TeamCompareModel.fromJson(
          res[ApiResponseString.data],
        );
        return teamCompare;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<MatchLiveScoreModel>?>? getMatchLiveScore(
    BuildContext context,
  ) async {
    var provider = Provider.of<LiveScoreProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';
    final url = APIServerUrl.liveMatchServerUrl +
        APIServerUrl.getMatchLiveScore +
        AppSingleton.singleton.matchData.id!;
    final response = await clientwithToken.get(url);

    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        List<MatchLiveScoreModel> liveScores = List<MatchLiveScoreModel>.from(
          res[ApiResponseString.data].map(
            (x) => MatchLiveScoreModel.fromJson(x),
          ),
        );

        provider.setLiveScore(liveScores, matchKey);
        return liveScores;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<PlayerDetailsModel?> getPlayerDetails(
    BuildContext context,
    String playerid,
  ) async {
    final url =
        '${APIServerUrl.matchServerUrl}${APIServerUrl.getMatchPlayerInfo}${AppSingleton.singleton.matchData.id}&playerid=$playerid&seriesid=${AppSingleton.singleton.matchData.series}';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final playerDetails = PlayerDetailsModel.fromJson(res);
        return playerDetails;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<MatchPlayerTeamsModel>?>? matchPlayerTeams(
    BuildContext context,
    String joinTeamId,
  ) async {
    final url =
        '${APIServerUrl.completedMatchServerUrl}${APIServerUrl.matchPlayerTeamsData}$joinTeamId&matchkey=${AppSingleton.singleton.matchData.id}';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<MatchPlayerTeamsModel>.from(
          res[ApiResponseString.data].map(
            (x) => MatchPlayerTeamsModel.fromJson(x),
          ),
        );
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<List<MatchPlayerTeamsModel>?>? matchplayerfantasyscorecards(
    BuildContext context,
  ) async {
    var provider = Provider.of<PlayerStatsProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    final url =
        '${APIServerUrl.completedMatchServerUrl}${APIServerUrl.matchplayerfantasyscorecards + matchKey}';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        List<MatchPlayerTeamsModel> matchPlayer =
            List<MatchPlayerTeamsModel>.from(
          res[ApiResponseString.data].map(
            (x) => MatchPlayerTeamsModel.fromJson(x),
          ),
        );

        provider.setMatchPlayers(matchPlayer, matchKey);
        return matchPlayer;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>?> getLeaderboardLive(
    BuildContext context,
    String challengeId,
    String finalStatus,
    int skip,
    int limit,
  ) async {
    final url =
        '${APIServerUrl.matchServerUrl}${APIServerUrl.getLiveRankLeaderboard}${AppSingleton.singleton.matchData.id}&final_status=$finalStatus&matchchallengeid=$challengeId&skip=$skip&limit=$limit&fantasy_type=${AppSingleton.singleton.matchData.fantasyType!}';

    debugPrint('🏆 [LEADERBOARD] Fetching live leaderboard: $url');
    final response = await clientwithToken.get(url);

    final res = response.data;
    debugPrint('🏆 [LEADERBOARD] Response status: ${response.statusCode}');
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        debugPrint('🏆 [LEADERBOARD] Success - data received');
        return response.data;
      } else {
        debugPrint('🏆 [LEADERBOARD] API returned failure: ${res[ApiResponseString.message]}');
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      debugPrint('🏆 [LEADERBOARD] HTTP error: ${response.statusCode}');
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getSelfLeaderboardLive(
    BuildContext context,
    String challengeId,
    String finalStatus,
    int skip,
    int limit,
  ) async {
    final url =
        '${APIServerUrl.matchServerUrl}${APIServerUrl.getSelfLiveLeaderboard}${AppSingleton.singleton.matchData.id}&final_status=$finalStatus&matchchallengeid=$challengeId&skip=$skip&limit=$limit&fantasy_type=${AppSingleton.singleton.matchData.fantasyType!}';

    debugPrint('🏆 [SELF-LEADERBOARD] Fetching self leaderboard: $url');
    final response = await clientwithToken.get(url);

    final res = response.data;
    debugPrint('🏆 [SELF-LEADERBOARD] Response status: ${response.statusCode}');
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        debugPrint('🏆 [SELF-LEADERBOARD] Success - data received');
        return response.data;
      } else {
        debugPrint('🏆 [SELF-LEADERBOARD] API returned failure: ${res[ApiResponseString.message]}');
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      debugPrint('🏆 [SELF-LEADERBOARD] HTTP error: ${response.statusCode}');
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<TeamsModel>> liveGetMyTeams(BuildContext context) async {
    debugPrint('👥 [MY_TEAMS] ========== liveGetMyTeams START ==========');
    var provider = Provider.of<MyTeamsProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    final url = APIServerUrl.getMyTeamsServerUrl +
        APIServerUrl.liveGetMyTeams +
        matchKey;

    debugPrint('👥 [MY_TEAMS] URL: $url');
    debugPrint('👥 [MY_TEAMS] matchKey: $matchKey');
    
    final response = await clientwithToken.get(url);
    final res = response.data;

    debugPrint('👥 [MY_TEAMS] Response status code: ${response.statusCode}');
    debugPrint('👥 [MY_TEAMS] Response data keys: ${res?.keys?.toList()}');
    debugPrint('👥 [MY_TEAMS] status: ${res[ApiResponseString.status]}');

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        final dataLength = res[ApiResponseString.data]?.length ?? 0;
        debugPrint('👥 [MY_TEAMS] ✅ Success - teams count: $dataLength');
        AppUtils.teamsCount.value = dataLength;
        List<TeamsModel> teams = List<TeamsModel>.from(
          res[ApiResponseString.data].map((x) => TeamsModel.fromJson(x)),
        );
        
        for (int i = 0; i < teams.length; i++) {
          debugPrint('👥 [MY_TEAMS] Team $i: teamnumber=${teams[i].teamnumber}, jointeamid: ${teams[i].jointeamid}');
        }

        provider.setMyTeams(teams, matchKey);
        return teams;
      } else {
        debugPrint('👥 [MY_TEAMS] ⚠️ API returned status=false, message: ${res[ApiResponseString.message]}');
      }
    } else {
      debugPrint('👥 [MY_TEAMS] ❌ HTTP error: ${response.statusCode}');
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<List<UserTeamsModel>> liveGetUserTeam(
    BuildContext context,
    String joinTeamId,
  ) async {
    final url =
        '${APIServerUrl.getMyTeamsServerUrl}${APIServerUrl.liveGetUserTeam}${AppSingleton.singleton.matchData.id!}&joinTeamId=$joinTeamId';

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        List<UserTeamsModel> userTeams = List<UserTeamsModel>.from(
          res[ApiResponseString.data][0][ApiResponseString.player].map(
            (x) => UserTeamsModel.fromJson(x),
          ),
        );
        Provider.of<TeamPreviewProvider>(
          context,
          listen: false,
        ).setUserTeam(joinTeamId, userTeams);
        return userTeams;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<List<PlayerPreviewModel>?>? liveViewTeam(
    BuildContext context,
    String teamId,
    int teamNumber,
    String userId,
  ) async {
    final url =
        '${APIServerUrl.teamsServerUrl}${APIServerUrl.liveViewTeam}${AppSingleton.singleton.matchData.id!}&jointeamid=$teamId&teamnumber=$teamNumber&userId=$userId';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<PlayerPreviewModel>.from(
          res[ApiResponseString.data].map(
            (x) => PlayerPreviewModel.fromJson(x),
          ),
        );
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }
}
