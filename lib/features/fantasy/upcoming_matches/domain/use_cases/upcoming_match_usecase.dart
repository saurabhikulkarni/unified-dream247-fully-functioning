import 'package:Dream247/features/upcoming_matches/data/models/leaderboard_model.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/features/upcoming_matches/data/models/all_contests_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/expert_advice_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/guru_teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/players_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/team_type_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/user_teams_model.dart';
import 'package:Dream247/features/upcoming_matches/domain/repositories/upcoming_match_repositories.dart';

class UpcomingMatchUsecase {
  UpcomingMatchRepositories upcomingMatchRepositories;
  UpcomingMatchUsecase(this.upcomingMatchRepositories);

  Future<Map<String, dynamic>?> userContestTeamCount(
    BuildContext context,
  ) async {
    var res = await upcomingMatchRepositories.userContestTeamCount(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<TeamTypeModel>?>? getTeamTypes(BuildContext context) async {
    var res = await upcomingMatchRepositories.getTeamTypes(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<AllContestResponseModel>?>? getAllContests(
    BuildContext context,
  ) async {
    var res = await upcomingMatchRepositories.getAllContests(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<AllNewContestResponseModel>?>? getAllNewContests(
    BuildContext context,
  ) async {
    var res = await upcomingMatchRepositories.getAllNewContests(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<AllContestResponseModel?>? getContestDetails(
    BuildContext context,
    String matchChallengeId,
  ) async {
    var res = await upcomingMatchRepositories.getContestDetails(
      context,
      matchChallengeId,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<AllContestResponseModel>?>? getJoinedContests(
    BuildContext context,
    int skip,
    int limit,
  ) async {
    var res = await upcomingMatchRepositories.getJoinedContests(
      context,
      skip,
      limit,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<TeamsModel>> getMyTeams(BuildContext context) async {
    var res = await upcomingMatchRepositories.getMyTeams(context);
    return res;
  }

  Future<List<UserTeamsModel>> getUserTeam(
    BuildContext context,
    String joinTeamId,
  ) async {
    var res = await upcomingMatchRepositories.getUserTeam(context, joinTeamId);
    return res;
  }

  Future<List<TeamsModel>> getTeamswithChallengeId(
    BuildContext context,
    String matchChallengeId,
  ) async {
    var res = await upcomingMatchRepositories.getTeamswithChallengeId(
      context,
      matchChallengeId,
    );
    return res;
  }

  Future<PlayersModel?> getAllPlayers(BuildContext context) async {
    var res = await upcomingMatchRepositories.getAllPlayers(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<CreateTeamPlayersData>?> getAllPlayersbyRealMatchKey(
    BuildContext context,
  ) async {
    var res = await upcomingMatchRepositories.getAllPlayersbyRealMatchKey(
      context,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<LeaderboardModelData>> fetchSelfLeaderboardOnly(
    BuildContext context,
    String challengeId,
  ) async {
    final value = await getSelfLeaderboard(context, challengeId, 0, 50);

    if (value == null) return [];

    return LeaderboardModel.fromJson(value).data ?? [];
  }


  Future<Map<String, dynamic>?> getUsableBalance(
    BuildContext context,
    String challengeId,
    int count,
    int discount,
  ) async {
    var res = await upcomingMatchRepositories.getUsableBalance(
      context,
      challengeId,
      count,
      discount,
    );
    return res;
  }

  Future<Map<String, dynamic>?> joinContest(
    BuildContext context,
    String challengeId,
    int discount,
    String selectedTeams,
  ) async {
    var res = await upcomingMatchRepositories.joinContest(
      context,
      challengeId,
      discount,
      selectedTeams,
    );
    return res;
  }

  Future<Map<String, dynamic>?> closedContestJoin(
    BuildContext context,
    int entryFee,
    int winAmount,
    int maximumUser,
    String discount,
    String selectedTeams,
  ) async {
    var res = await upcomingMatchRepositories.closedContestJoin(
      context,
      entryFee,
      winAmount,
      maximumUser,
      discount,
      selectedTeams,
    );
    return res;
  }

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
    var res = await upcomingMatchRepositories.createTeam(
      context,
      allPlayers,
      captain,
      viceCaptain,
      isGuru,
      guruTeamId,
      teamnumber,
      teamType,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<bool?> switchTeam(
    BuildContext buildContext,
    String leagueId,
    String teamId,
    String challengeId,
    String leaderboardId,
  ) async {
    var res = await upcomingMatchRepositories.switchTeam(
      buildContext,
      leagueId,
      teamId,
      challengeId,
      leaderboardId,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<GuruTeamsModel>?>? getGuruTeams(BuildContext context) async {
    var res = await upcomingMatchRepositories.getGuruTeams(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> createContest(
    BuildContext context,
    String entryFee,
    String spots,
    int winners,
    String contestName,
  ) async {
    var res = await upcomingMatchRepositories.createContest(
      context,
      entryFee,
      spots,
      winners,
      contestName,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> joinByCode(
    BuildContext context,
    String code,
    int isPromoCodeContest,
  ) async {
    var res = await upcomingMatchRepositories.joinByCode(
      context,
      code,
      isPromoCodeContest,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPriceCard(
    BuildContext context,
    String entryFee,
    String spots,
    int winners,
  ) async {
    var res = await upcomingMatchRepositories.getPriceCard(
      context,
      entryFee,
      spots,
      winners,
    );
    return res;
  }

  Future<Map<String, dynamic>?> getSelfLeaderboard(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
  ) async {
    var res = await upcomingMatchRepositories.getSelfLeaderboard(
      context,
      challengeId,
      skip,
      limit,
    );
    return res;
  }

  Future<Map<String, dynamic>?> getLeaderboardUpcoming(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
    int self,
  ) async {
    var res = await upcomingMatchRepositories.getLeaderboardUpcoming(
      context,
      challengeId,
      skip,
      limit,
      self,
    );
    return res;
  }

  Future<List<ExpertAdviceModel>?>? getExpertAdvice(
      BuildContext context) async {
    var res = await upcomingMatchRepositories.getExpertAdvice(context);
    return res;
  }
}
