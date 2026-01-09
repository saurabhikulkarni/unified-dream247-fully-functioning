import 'package:flutter/material.dart';
import 'package:Dream247/features/upcoming_matches/data/models/players_model.dart';

class AllPlayersProvider extends ChangeNotifier {
  List<CreateTeamPlayersData>? _allPlayersList;

  List<CreateTeamPlayersData>? get allPlayersList => _allPlayersList;

  setAllPlayers(List<CreateTeamPlayersData>? value) {
    _allPlayersList = value;
    notifyListeners();
  }

  void updateAllPlayers(List<CreateTeamPlayersData>? newallPlayersList) {
    _allPlayersList = newallPlayersList;
    notifyListeners();
  }

  void updateSelectedPlayers(CreateTeamPlayersData newallPlayersList) {
    var newPlayersList = _allPlayersList;
    newPlayersList
        ?.firstWhere(
            (element) => element.playerid == newallPlayersList.playerid)
        .isSelectedPlayer = newallPlayersList.isSelectedPlayer;

    notifyListeners();
  }
}
