class TeamTypeModel {
  String? id;
  String? name;
  String? status;

  TeamTypeModel({this.id, this.name, this.status});

  factory TeamTypeModel.fromJson(Map<String, dynamic> json) => TeamTypeModel(
    id: json['_id'],
    name: json['name'],
    status: json['status'],
  );
}
