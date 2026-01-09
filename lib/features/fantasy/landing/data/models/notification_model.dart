import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class NotificationModel {
  String? id;
  String? userid;
  String? title;
  int? seen;
  String? module;
  String? createdAt;
  String? updatedAt;

  NotificationModel({
    this.id,
    this.userid,
    this.title,
    this.seen,
    this.module,
    this.createdAt,
    this.updatedAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["_id"]);
    userid = ModelParsers.toStringParser(json["userid"]);
    title = ModelParsers.toStringParser(json["title"]);
    seen = ModelParsers.toIntParser(json["seen"]);
    module = ModelParsers.toStringParser(json["module"]);
    createdAt = ModelParsers.toStringParser(json["createdAt"]);
    updatedAt = ModelParsers.toStringParser(json["updatedAt"]);
  }
}
