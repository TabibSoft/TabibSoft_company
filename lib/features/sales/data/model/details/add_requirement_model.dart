import 'package:json_annotation/json_annotation.dart';

part 'add_requirement_model.g.dart';

@JsonSerializable()
class AddMeasurementRequirement {
  final String id;
  final String? createdUser;
  final String? lastEditUser;
  final String createdDate;
  final String lastEditDate;
  final String measurementId;
  final String? notes;
  final String exepectedCallDate;
  final String exepectedCallTimeFrom; // تغيير إلى String
  final String exepectedCallTimeTo; // تغيير إلى String
  final String? date;
  final String? exepectedComment;
  final String? note;
  final List<String>? imageFiles;
  final String? communicationId;
  final String? model; // إضافة حقل model

  AddMeasurementRequirement({
    required this.id,
    this.createdUser,
    this.lastEditUser,
    required this.createdDate,
    required this.lastEditDate,
    required this.measurementId,
    this.notes,
    required this.exepectedCallDate,
    required this.exepectedCallTimeFrom,
    required this.exepectedCallTimeTo,
    this.date,
    this.exepectedComment,
    this.note,
    this.imageFiles,
    this.communicationId,
    this.model,
  });

  factory AddMeasurementRequirement.fromJson(Map<String, dynamic> json) =>
      _$AddMeasurementRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$AddMeasurementRequirementToJson(this);
}
@JsonSerializable()
class TimeSpan {
  final int ticks;

  TimeSpan({required this.ticks});

  factory TimeSpan.fromJson(Map<String, dynamic> json) => _$TimeSpanFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSpanToJson(this);
}