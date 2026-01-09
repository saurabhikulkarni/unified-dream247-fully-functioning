import 'package:Dream247/core/utils/model_parsers.dart';

class ScorecardModel {
  String? name;
  String? shortName;
  String? scores;
  List<Batsmen>? batsmen;
  ExtraRuns? extraRuns;
  Equations? equations;
  String? didNotBat;
  List<Bowlers>? bowlers;
  List<FallOfWickets>? fallOfWickets;

  ScorecardModel(
      {this.name,
      this.shortName,
      this.scores,
      this.batsmen,
      this.extraRuns,
      this.equations,
      this.didNotBat,
      this.bowlers,
      this.fallOfWickets});

  ScorecardModel.fromJson(Map<String, dynamic> json) {
    name = ModelParsers.toStringParser(json["name"]);
    shortName = ModelParsers.toStringParser(json["short_name"]);
    scores = ModelParsers.toStringParser(json["scores"]);
    batsmen = json["batsmen"] == null
        ? null
        : (json["batsmen"] as List).map((e) => Batsmen.fromJson(e)).toList();
    extraRuns = json["extra_runs"] == null
        ? null
        : ExtraRuns.fromJson(json["extra_runs"]);
    equations = json["equations"] == null
        ? null
        : Equations.fromJson(json["equations"]);
    didNotBat = ModelParsers.toStringParser(json["did_not_bat"]);
    bowlers = json["bowlers"] == null
        ? null
        : (json["bowlers"] as List).map((e) => Bowlers.fromJson(e)).toList();
    fallOfWickets = json["fall_of_wickets"] == null
        ? null
        : (json["fall_of_wickets"] as List)
            .map((e) => FallOfWickets.fromJson(e))
            .toList();
  }
}

class FallOfWickets {
  String? name;
  String? runs;
  String? balls;
  String? scoreAtDismissal;
  String? oversAtDismissal;
  int? number;
  String? dismissal;

  FallOfWickets(
      {this.name,
      this.runs,
      this.balls,
      this.scoreAtDismissal,
      this.oversAtDismissal,
      this.number,
      this.dismissal});

  FallOfWickets.fromJson(Map<String, dynamic> json) {
    name = ModelParsers.toStringParser(json["name"]);
    runs = ModelParsers.toStringParser(json["runs"]);
    balls = ModelParsers.toStringParser(json["balls"]);
    scoreAtDismissal = ModelParsers.toStringParser(json["score_at_dismissal"]);
    oversAtDismissal = ModelParsers.toStringParser(json["overs_at_dismissal"]);
    number = ModelParsers.toIntParser(json["number"]);
    dismissal = ModelParsers.toStringParser(json["dismissal"]);
  }
}

class Bowlers {
  String? name;
  String? overs;
  String? maidens;
  String? runs;
  String? wickets;
  String? economyRate;
  String? bowling;

  Bowlers(
      {this.name,
      this.overs,
      this.maidens,
      this.runs,
      this.wickets,
      this.economyRate,
      this.bowling});

  Bowlers.fromJson(Map<String, dynamic> json) {
    name = ModelParsers.toStringParser(json["name"]);
    overs = ModelParsers.toStringParser(json["overs"]);
    maidens = ModelParsers.toStringParser(json["maidens"]);
    runs = ModelParsers.toStringParser(json["runs"]);
    wickets = ModelParsers.toStringParser(json["wickets"]);
    economyRate = ModelParsers.toStringParser(json["economy_rate"]);
    bowling = ModelParsers.toStringParser(json["bowling"]);
  }
}

class Equations {
  int? runs;
  int? wickets;
  String? overs;
  int? bowlersUsed;
  String? runrate;

  Equations(
      {this.runs, this.wickets, this.overs, this.bowlersUsed, this.runrate});

  Equations.fromJson(Map<String, dynamic> json) {
    runs = ModelParsers.toIntParser(json["runs"]);
    wickets = ModelParsers.toIntParser(json["wickets"]);
    overs = ModelParsers.toStringParser(json["overs"]);
    bowlersUsed = ModelParsers.toIntParser(json["bowlers_used"]);
    runrate = ModelParsers.toStringParser(json["runrate"]);
  }
}

class ExtraRuns {
  int? byes;
  int? legbyes;
  int? wides;
  int? noballs;
  String? penalty;
  int? total;

  ExtraRuns(
      {this.byes,
      this.legbyes,
      this.wides,
      this.noballs,
      this.penalty,
      this.total});

  ExtraRuns.fromJson(Map<String, dynamic> json) {
    byes = ModelParsers.toIntParser(json["byes"]);
    legbyes = ModelParsers.toIntParser(json["legbyes"]);
    wides = ModelParsers.toIntParser(json["wides"]);
    noballs = ModelParsers.toIntParser(json["noballs"]);
    penalty = ModelParsers.toStringParser(json["penalty"]);
    total = ModelParsers.toIntParser(json["total"]);
  }
}

class Batsmen {
  String? name;
  String? role;
  String? howOut;
  String? runs;
  String? balls;
  String? fours;
  String? sixes;
  String? strikeRate;
  String? batting;
  String? dismissal;

  Batsmen(
      {this.name,
      this.role,
      this.howOut,
      this.runs,
      this.balls,
      this.fours,
      this.sixes,
      this.strikeRate,
      this.batting,
      this.dismissal});

  Batsmen.fromJson(Map<String, dynamic> json) {
    name = ModelParsers.toStringParser(json["name"]);
    role = ModelParsers.toStringParser(json["role"]);
    howOut = ModelParsers.toStringParser(json["how_out"]);
    runs = ModelParsers.toStringParser(json["runs"]);
    balls = ModelParsers.toStringParser(json["balls"]);
    fours = ModelParsers.toStringParser(json["fours"]);
    sixes = ModelParsers.toStringParser(json["sixes"]);
    strikeRate = ModelParsers.toStringParser(json["strike_rate"]);
    batting = ModelParsers.toStringParser(json["batting"]);
    dismissal = ModelParsers.toStringParser(json["dismissal"]);
  }
}
