import 'package:json_annotation/json_annotation.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';

part 'task_details_model.g.dart';

@JsonSerializable()
class TaskDetailsModel {
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
  final List<EngineerModel> engineers;
  final String sitiouationStatusesId;
  final String sitiouationId;
  final String? file;

  TaskDetailsModel({
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
    required this.engineers,
    required this.sitiouationStatusesId,
    required this.sitiouationId,
    this.file,
  });

  factory TaskDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$TaskDetailsModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskDetailsModelToJson(this);
}