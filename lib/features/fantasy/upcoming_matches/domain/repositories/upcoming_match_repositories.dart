import 'package:flutter/material.dart';
import 'package:Dream247/features/upcoming_matches/data/models/all_contests_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/expert_advice_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/guru_teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/players_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/team_type_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/user_teams_model.dart';

abstract class UpcomingMatchRepositories {
  Future<Map<String, dynamic>?> userContestTeamCount(BuildContext context);

  Future<List<TeamTypeModel>?>? getTeamTypes(BuildContext context);

  Future<List<AllContestResponseModel>?>? getAllContests(BuildContext context);

  Future<List<AllNewContestResponseModel>?>? getAllNewContests(
    BuildContext context,
  );

  Future<AllContestResponseModel?>? getContestDetails(
    BuildContext context,
    String matchChallengeId,
  );

  Future<List<AllContestResponseModel>?>? getJoinedContests(
    BuildContext context,
    int skip,
    int limit,
  );

  Future<List<TeamsModel>> getMyTeams(BuildContext context);

  Future<List<UserTeamsModel>> getUserTeam(
    BuildContext context,
    String joinTeamId,
  );

  Future<List<TeamsModel>> getTeamswithChallengeId(
    BuildContext context,
    String matchChallengeId,
  );

  Future<PlayersModel?> getAllPlayers(BuildContext context);

  Future<List<CreateTeamPlayersData>?> getAllPlayersbyRealMatchKey(
    BuildContext context,
  );

  Future<String?> createTeam(
    BuildContext context,
    String allPlayers,
    String captain,
    String viceCaptain,
    int isGuru,
    String guruTeamId,
    int teamnumber,
    String teamType,
  );

  Future<bool?> switchTeam(
    BuildContext buildContext,
    String leagueId,
    String teamID,
    String challengeId,
    String leaderboardId,
  );

  Future<Map<String, dynamic>?> getUsableBalance(
    BuildContext context,
    String challengeId,
    int count,
    int discount,
  );

  Future<Map<String, dynamic>?> joinContest(
    BuildContext context,
    String challengeId,
    int discount,
    String selectedTeams,
  );

  Future<Map<String, dynamic>?> closedContestJoin(
    BuildContext context,
    int entryFee,
    int winAmount,
    int maximumUser,
    String discount,
    String selectedTeams,
  );

  Future<Map<String, dynamic>?> getSelfLeaderboard(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
  );

  Future<Map<String, dynamic>?> getLeaderboardUpcoming(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
    int self,
  );

  Future<Map<String, dynamic>?> getPriceCard(
    BuildContext context,
    String entryFee,
    String spots,
    int winners,
  );

  Future<Map<String, dynamic>?> createContest(
    BuildContext context,
    String entryFee,
    String spots,
    int winners,
    String teamName,
  );

  Future<Map<String, dynamic>?> joinByCode(
    BuildContext context,
    String code,
    int isPromoCodeContest,
  );

  Future<List<GuruTeamsModel>?>? getGuruTeams(BuildContext context);

  Future<List<ExpertAdviceModel>?>? getExpertAdvice(BuildContext context);
}
