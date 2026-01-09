import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class GamesGetSet {
  String? id;
  String? fantasyName;
  SportCategory? sportCategory;
  String? image;
  String? type;

  GamesGetSet({
    this.id,
    this.fantasyName,
    this.sportCategory,
    this.image,
    this.type,
  });

  factory GamesGetSet.fromJson(Map<String, dynamic> json) => GamesGetSet(
        id: ModelParsers.toStringParser(json["_id"]),
        fantasyName: ModelParsers.toStringParser(json["fantasyName"]),
        sportCategory: json["sport_category"] == null
            ? null
            : SportCategory.fromJson(json["sport_category"]),
        image: ModelParsers.toStringParser(json["image"]),
        type: ModelParsers.toStringParser(json["type"]),
      );
}

class SportCategory {
  int? id;
  String? name;
  int? maxPlayers;
  int? maxCredits;
  String? icon;
  String? category;
  List<TeamType>? teamType;

  SportCategory({
    this.id,
    this.name,
    this.maxPlayers,
    this.maxCredits,
    this.icon,
    this.category,
    this.teamType,
  });

  factory SportCategory.fromJson(Map<String, dynamic> json) => SportCategory(
        id: json["id"],
        name: json["name"],
        maxPlayers: json["max_players"],
        maxCredits: json["max_credits"],
        icon: json["icon"],
        category: json["category"],
        teamType: json["teamType"] == null
            ? []
            : List<TeamType>.from(
                json["teamType"]!.map((x) => TeamType.fromJson(x)),
              ),
      );
}

class TeamType {
  int? maxPlayersPerTeam;
  int? minPlayersPerTeam;
  String? name;
  List<PlayerPosition>? playerPositions;

  TeamType({
    this.maxPlayersPerTeam,
    this.minPlayersPerTeam,
    this.name,
    this.playerPositions,
  });

  factory TeamType.fromJson(Map<String, dynamic> json) => TeamType(
        maxPlayersPerTeam: json["max_players_per_team"],
        minPlayersPerTeam: json["min_players_per_team"],
        name: json["name"],
        playerPositions: json["player_positions"] == null
            ? []
            : List<PlayerPosition>.from(
                json["player_positions"]!
                    .map((x) => PlayerPosition.fromJson(x)),
              ),
      );
}

class PlayerPosition {
  int? id;
  int? sportCategoryId;
  String? name;
  int count = 0;
  String? fullName;
  String? code;
  String? icon;
  int? minPlayersPerTeam;
  int? maxPlayersPerTeam;

  PlayerPosition({
    this.id,
    this.sportCategoryId,
    this.name,
    this.fullName,
    this.code,
    this.icon,
    this.minPlayersPerTeam,
    this.maxPlayersPerTeam,
  });

  factory PlayerPosition.fromJson(Map<String, dynamic> json) => PlayerPosition(
        id: ModelParsers.toIntParser(json["id"]),
        sportCategoryId: ModelParsers.toIntParser(json["sport_category_id"]),
        name: ModelParsers.toStringParser(json["name"]),
        fullName: ModelParsers.toStringParser(json["full_name"]),
        code: ModelParsers.toStringParser(json["code"]),
        icon: ModelParsers.toStringParser(json["icon"]),
        minPlayersPerTeam:
            ModelParsers.toIntParser(json["min_players_per_team"]),
        maxPlayersPerTeam:
            ModelParsers.toIntParser(json["max_players_per_team"]),
      );
}
