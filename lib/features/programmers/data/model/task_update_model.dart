import 'package:json_annotation/json_annotation.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';

part 'task_update_model.g.dart';

@JsonSerializable()
class TaskUpdateModel {
  final String id;
  final String? image;
  final DateTime startDate;
  final DateTime deadLine;
  final double? engRate;
  final bool testing;
  final bool applaied;
  final String? enginnerTesterId;
  final List<String> engineerIds;
  final String? customerSupportId;
  final String customerId;
  final String detailes;
  @JsonKey(name: 'customizationReports')
  final List<Report> reports;
  final String sitiouationStatusesId;
  final String sitiouationId;
  final String? file;
  final String? model; // حقل model مضاف

  TaskUpdateModel({
    required this.id,
    this.image,
    required this.startDate,
    required this.deadLine,
    this.engRate,
    required this.testing,
    required this.applaied,
    this.enginnerTesterId,
    required this.engineerIds,
    this.customerSupportId,
    required this.customerId,
    required this.detailes,
    required this.reports,
    required this.sitiouationStatusesId,
    required this.sitiouationId,
    this.file,
    this.model,
  });

  factory TaskUpdateModel.fromJson(Map<String, dynamic> json) => _$TaskUpdateModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskUpdateModelToJson(this);
}@JsonSerializable()
class ReportDoneModel {
  final String id;

  ReportDoneModel({required this.id});

  factory ReportDoneModel.fromJson(Map<String, dynamic> json) => _$ReportDoneModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportDoneModelToJson(this);
}