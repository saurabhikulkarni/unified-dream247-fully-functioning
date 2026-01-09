class ExpertAdviceModel {
  String? id;
  String? title;
  String? content;
  bool? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  ExpertAdviceModel({
    this.id,
    this.title,
    this.content,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpertAdviceModel.fromJson(Map<String, dynamic> json) =>
      ExpertAdviceModel(
        id: json["_id"],
        title: json["title"],
        content: json["content"],
        status: json["status"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );
}
