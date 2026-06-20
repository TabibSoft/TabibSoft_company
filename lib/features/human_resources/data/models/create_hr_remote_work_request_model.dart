import 'package:json_annotation/json_annotation.dart';

part 'create_hr_remote_work_request_model.g.dart';

@JsonSerializable()
class CreateHrRemoteWorkRequestModel {
  final DateTime startDate;

  const CreateHrRemoteWorkRequestModel({
    required this.startDate,
  });

  factory CreateHrRemoteWorkRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateHrRemoteWorkRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHrRemoteWorkRequestModelToJson(this);
}
