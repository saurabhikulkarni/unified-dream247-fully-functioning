// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/expert_advice_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/team_type_model.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_keys.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_utils.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/repositories/upcoming_match_repositories.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/guru_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/players_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/team_preview_provider.dart';

class UpcomingMatchDatsource extends UpcomingMatchRepositories {
  ApiImpl client;
  ApiImplWithAccessToken clientwithToken;
  UpcomingMatchDatsource(this.client, this.clientwithToken);

  @override
  Future<Map<String, dynamic>?> userContestTeamCount(
    BuildContext context,
  ) async {
    final url = APIServerUrl.teamsServerUrl +
        APIServerUrl.userContestTeamCount +
        AppSingleton.singleton.matchData.id!;
    final response = await clientwithToken.get(url);

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      final res = response.data;

      if (res[ApiResponseString.success] == true) {
        return response.data;
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
  Future<List<TeamTypeModel>?>? getTeamTypes(BuildContext context) async {
    final url = APIServerUrl.matchServerUrl + APIServerUrl.getTeamTypes;
    final response = await clientwithToken.get(url);
    final json = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (json[ApiResponseString.status] == true) {
        return List<TeamTypeModel>.from(
          json[ApiResponseString.data].map((x) => TeamTypeModel.fromJson(x)),
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
  Future<List<AllNewContestResponseModel>?>? getAllNewContests(
    BuildContext context,
  ) async {
    final url = APIServerUrl.contestServerUrl +
        APIServerUrl.getAllNewContestsRedis +
        AppSingleton.singleton.matchData.id!;
    final response = await clientwithToken.get(url);
    final json = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (json[ApiResponseString.status] == true) {
        return List<AllNewContestResponseModel>.from(
          json[ApiResponseString.data].map(
            (x) => AllNewContestResponseModel.fromJson(x),
          ),
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
  Future<List<AllContestResponseModel>?>? getAllContests(
    BuildContext context,
  ) async {
    final url = APIServerUrl.contestServerUrl +
        APIServerUrl.getAllContests +
        AppSingleton.singleton.matchData.id!;
    final response = await clientwithToken.get(url);
    final json = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (json[ApiResponseString.status] == true) {
        return List<AllContestResponseModel>.from(
          json[ApiResponseString.data].map(
            (x) => AllContestResponseModel.fromJson(x),
          ),
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
  Future<List<AllContestResponseModel>?>? getJoinedContests(
    BuildContext context,
    int skip,
    int limit,
  ) async {
    final url =
        '${APIServerUrl.myJoinContestServerUrl}${APIServerUrl.getJoinedContests}${AppSingleton.singleton.matchData.id!}&skip=$skip&limit=$limit';
    final response = await clientwithToken.get(url);
    final json = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (json[ApiResponseString.status] == true) {
        return List<AllContestResponseModel>.from(
          json[ApiResponseString.data].map(
            (x) => AllContestResponseModel.fromJson(x),
          ),
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
  Future<AllContestResponseModel?>? getContestDetails(
    BuildContext context,
    String matchChallengeId,
  ) async {
    final url =
        '${APIServerUrl.contestServerUrl}${APIServerUrl.getContestDetails}$matchChallengeId&matchkey=${AppSingleton.singleton.matchData.id}';
    final response = await clientwithToken.get(url);
    final json = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (json[ApiResponseString.status] == true) {
        final contestDetails = AllContestResponseModel.fromJson(json['data']);
        return contestDetails;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<List<TeamsModel>> getMyTeams(BuildContext context) async {
    var provider = Provider.of<MyTeamsProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    final url =
        APIServerUrl.getMyTeamsServerUrl + APIServerUrl.getMyTeams + matchKey;

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        AppUtils.teamsCount.value = res[ApiResponseString.data].length ?? 0;
        List<TeamsModel> teams = List<TeamsModel>.from(
          res[ApiResponseString.data].map((x) => TeamsModel.fromJson(x)),
        );

        provider.setMyTeams(teams, matchKey);
        return teams;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<List<TeamsModel>> getTeamswithChallengeId(
    BuildContext context,
    String matchChallengeId,
  ) async {
    var provider = Provider.of<MyTeamsProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    final url =
        '${APIServerUrl.getMyTeamsServerUrl}${APIServerUrl.getMyTeams}${AppSingleton.singleton.matchData.id}&matchchallengeid=$matchChallengeId';

    final response = await clientwithToken.get(url);
    final res = response.data;

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        List<TeamsModel> teams = List<TeamsModel>.from(
          res[ApiResponseString.data].map((x) => TeamsModel.fromJson(x)),
        );
        provider.setMyTeams(teams, matchKey);
        return teams;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return [];
  }

  @override
  Future<List<UserTeamsModel>> getUserTeam(
    BuildContext context,
    String joinTeamId,
  ) async {
    final url =
        '${APIServerUrl.getMyTeamsServerUrl}${APIServerUrl.getUserTeam}${AppSingleton.singleton.matchData.id!}&joinTeamId=$joinTeamId';

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
  Future<PlayersModel?> getAllPlayers(BuildContext context) async {
    final url = APIServerUrl.matchServerUrl +
        APIServerUrl.getAllPlayers +
        AppSingleton.singleton.matchData.id!;

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        final players = PlayersModel.fromJson(res);
        return players;
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
  Future<List<CreateTeamPlayersData>?> getAllPlayersbyRealMatchKey(
    BuildContext context,
  ) async {
    final url =
        '${AppSingleton.singleton.appData.playerJsonUrl}playerList-${AppSingleton.singleton.matchData.realMatchkey}.json';
    
    final response = await client.get(url);

    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      final res = response.data;
      
      return List<CreateTeamPlayersData>.from(
        res.map((x) => CreateTeamPlayersData.fromJson(x)),
      );
    } else {
      debugPrint('❌ [PLAYERS_DATASOURCE] API error: ${response.statusCode}');
      if (context.mounted) {
        await getAllPlayers(context);
      }
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>?> getUsableBalance(
    BuildContext context,
    String challengeId,
    int count,
    int discount,
  ) async {
    final url =
        '${APIServerUrl.contestServerUrl}${APIServerUrl.getUsableBalance}$challengeId&total_team_count=$count&discount_fee=$discount&matchkey=${AppSingleton.singleton.matchData.id}';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
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
  Future<Map<String, dynamic>?> joinContest(
    BuildContext context,
    String challengeId,
    int discount,
    String selectedTeams,
  ) async {
    final url = APIServerUrl.joinContestServerUrl + APIServerUrl.joinContest;

    final body = {
      ApiServerKeys.matchKey: AppSingleton.singleton.matchData.id,
      ApiServerKeys.matchChallengeId: challengeId,
      ApiServerKeys.joinTeamId: selectedTeams,
      ApiServerKeys.fantasyType: AppSingleton.singleton.matchData.fantasyType!,
      ApiServerKeys.discountFee: discount.toString(),
    };

    final response = await clientwithToken.post(url, body: body);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
        return response.data;
      } else {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
        return response.data;
      }
    } else {
      if (context.mounted) {
        ApiServerUtil.manageException(response, context);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> closedContestJoin(
    BuildContext context,
    int entryFee,
    int winAmount,
    int maximumUser,
    String discount,
    String selectedTeams,
  ) async {
    final url =
        APIServerUrl.joinContestServerUrl + APIServerUrl.closedContestJoin;
    final body = {
      'entryfee': entryFee,
      'win_amount': winAmount,
      'maximum_user': maximumUser,
      ApiServerKeys.joinTeamId: selectedTeams,
      ApiServerKeys.discountFee: discount.toString(),
      ApiServerKeys.matchKey: AppSingleton.singleton.matchData.id!,
    };

    final response = await clientwithToken.post(url, body: body);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return response.data;
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
  Future<String?> createTeam(
    BuildContext context,
    String allPlayers,
    String captain,
    String viceCaptain,
    int isGuru,
    String guruTeamId,
    int teamnumber,
    String teamType,
  ) async {
    final url = APIServerUrl.getMyTeamsServerUrl + APIServerUrl.createTeam;

    final body = {
      ApiServerKeys.matchKey: AppSingleton.singleton.matchData.id,
      ApiServerKeys.teamNumber: teamnumber.toString(),
      ApiServerKeys.isGuru: isGuru.toString(),
      ApiServerKeys.guruTeamId: guruTeamId,
      ApiServerKeys.players: allPlayers,
      ApiServerKeys.captain: captain,
      ApiServerKeys.viceCaptain: viceCaptain,
      ApiServerKeys.teamType: teamType,
    };

    final response = await clientwithToken.post(url, body: body);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );
        String teamid = res[ApiResponseString.data][ApiResponseString.teamId];
        return teamid;
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
  Future<bool?> switchTeam(
    BuildContext context,
    String leagueId,
    String teamId,
    String challengeId,
    String leaderboardId,
  ) async {
    final url = APIServerUrl.teamsServerUrl + APIServerUrl.switchTeam;

    final body = {
      ApiServerKeys.matchKey: AppSingleton.singleton.matchData.id!,
      'challengeId': challengeId,
      'leaderBoardId': leaderboardId,
      ApiServerKeys.switchTeam: [
        {
          ApiServerKeys.joinLeaugeId: leagueId,
          ApiServerKeys.newJoinTeamId: teamId,
        },
      ],
    };

    final response = await clientwithToken.post(url, body: body);
    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        ApiServerUtil.showAppToastforApi(
          res[ApiResponseString.message],
          context,
        );

        return true;
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
    return false;
  }

  @override
  Future<List<GuruTeamsModel>?>? getGuruTeams(BuildContext context) async {
    final url = APIServerUrl.teamsServerUrl +
        APIServerUrl.getGuruTeams +
        AppSingleton.singleton.matchData.id!;

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<GuruTeamsModel>.from(
          res[ApiResponseString.data].map((x) => GuruTeamsModel.fromJson(x)),
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
  Future<Map<String, dynamic>?> createContest(
    BuildContext context,
    String entryFee,
    String spots,
    int winners,
    String contestName,
  ) async {
    final url =
        APIServerUrl.contestServerUrl + APIServerUrl.createPrivateContest;

    final body = {
      ApiServerKeys.entryFees: entryFee,
      ApiServerKeys.totalPlayers: spots,
      ApiServerKeys.winners: winners.toString(),
      ApiServerKeys.matchKey: AppSingleton.singleton.matchData.id,
      ApiServerKeys.multiEntry: '0',
      ApiServerKeys.contestName: contestName,
      ApiServerKeys.fantasyType: AppSingleton.singleton.matchData.fantasyType!,
    };

    final response = await clientwithToken.post(url, body: body);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
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
  Future<Map<String, dynamic>?> joinByCode(
    BuildContext context,
    String code,
    int isPromoCodeContest,
  ) async {
    final url =
        APIServerUrl.joinContestServerUrl + APIServerUrl.joinContestByCode;

    final body = {
      ApiServerKeys.matchKey: AppSingleton.singleton.matchData.id,
      ApiServerKeys.getCode: code,
      ApiServerKeys.fantasyType: AppSingleton.singleton.matchData.fantasyType,
      ApiServerKeys.isPromoCodeContest: isPromoCodeContest.toString(),
    };

    final response = await clientwithToken.post(url, body: body);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
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
  Future<Map<String, dynamic>?> getPriceCard(
    BuildContext context,
    String entryFee,
    String spots,
    int winners,
  ) async {
    final url =
        APIServerUrl.contestServerUrl + APIServerUrl.getPrivateContestPriceCard;

    final body = {
      ApiServerKeys.entryFees: entryFee,
      ApiServerKeys.totalPlayers: spots,
      ApiServerKeys.winners: winners.toString(),
    };

    final response = await clientwithToken.post(url, body: body);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.status] == true) {
        return response.data;
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
  Future<Map<String, dynamic>?> getLeaderboardUpcoming(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
    int self,
  ) async {
    final url =
        '${APIServerUrl.contestServerUrl}${APIServerUrl.getLeaderboardUpcoming}${AppSingleton.singleton.matchData.id}&matchchallengeid=$challengeId&skip=$skip&limit=$limit&fantasy_type=${AppSingleton.singleton.matchData.fantasyType!}&self=$self';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
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
  Future<Map<String, dynamic>?> getSelfLeaderboard(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
  ) async {
    final url =
        '${APIServerUrl.contestServerUrl}${APIServerUrl.getSelfLeaderboard}${AppSingleton.singleton.matchData.id}&matchchallengeid=$challengeId&skip=$skip&limit=$limit&fantasy_type=${AppSingleton.singleton.matchData.fantasyType!}';

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return response.data;
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
  Future<List<ExpertAdviceModel>?>? getExpertAdvice(
      BuildContext context,) async {
    final url = APIServerUrl.otherApiServerUrl + APIServerUrl.getExpertAdvice;

    final response = await clientwithToken.get(url);

    final res = response.data;
    if (ApiServerUtil.validateStatusCode(response.statusCode ?? 200)) {
      if (res[ApiResponseString.success] == true) {
        return List<ExpertAdviceModel>.from(
          res[ApiResponseString.data].map(
            (x) => ExpertAdviceModel.fromJson(x),
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
