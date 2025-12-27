class SituationStatusModel {
  final String id;
  final String name;
  final String color;

  SituationStatusModel({
    required this.id,
    required this.name,
    required this.color,
  });

  factory SituationStatusModel.fromJson(Map<String, dynamic> json) {
    return SituationStatusModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }
}
