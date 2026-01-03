import 'package:json_annotation/json_annotation.dart';

part 'government_model.g.dart';

@JsonSerializable()
class GovernmentModel {
  final String id;
  final String name;

  GovernmentModel({
    required this.id,
    required this.name,
  });

  factory GovernmentModel.fromJson(Map<String, dynamic> json) =>
      _$GovernmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$GovernmentModelToJson(this);
}
