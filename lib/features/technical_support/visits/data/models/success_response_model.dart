// success_response_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'success_response_model.g.dart';

@JsonSerializable()
class SuccessResponse {
  final bool success;

  SuccessResponse({required this.success});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SuccessResponseToJson(this);
}
