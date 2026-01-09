import 'package:Dream247/core/utils/model_parsers.dart';

class StoriesModel {
  String? id;
  String? title;
  List<SingleStoryData>? storyData;
  String? storyProfileImage;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  StoriesModel({
    this.id,
    this.title,
    this.storyData,
    this.storyProfileImage,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  StoriesModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["_id"]);
    title = ModelParsers.toStringParser(json["title"]);
    storyData = json["storyData"] == null
        ? null
        : (json["storyData"] as List)
            .map((e) => SingleStoryData.fromJson(e))
            .toList();
    storyProfileImage = ModelParsers.toStringParser(json["storyProfileImage"]);
    isActive = ModelParsers.toBoolParser(json["is_active"]);
    createdAt = ModelParsers.toStringParser(json["createdAt"]);
    updatedAt = ModelParsers.toStringParser(json["updatedAt"]);
  }
}

class SingleStoryData {
  String? url;
  String? type;

  SingleStoryData({this.url, this.type});

  SingleStoryData.fromJson(Map<String, dynamic> json) {
    url = ModelParsers.toStringParser(json["url"]);
    type = ModelParsers.toStringParser(json["type"]);
  }
}
