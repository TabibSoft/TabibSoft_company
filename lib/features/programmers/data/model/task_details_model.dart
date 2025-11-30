import 'package:json_annotation/json_annotation.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';

part 'task_details_model.g.dart';

@JsonSerializable()
class TaskDetailsModel {
  final String id;
  final String? image;

  @JsonKey(fromJson: _dateFromString, toJson: _dateToString)
  final DateTime startDate;

  @JsonKey(fromJson: _dateFromString, toJson: _dateToString)
  final DateTime deadLine;

  final double? engRate;
  final bool testing;
  final bool applaied;
  final String? enginnerTesterId;

  @JsonKey(defaultValue: [])
  final List<String> engineerIds;

  final String? customerSupportId;

  // هنا المشكلة الكبيرة: جاي null من الـ API
  @JsonKey(defaultValue: '')
  final String customerId;

  final String? detailes;

  @JsonKey(name: 'customizationReports', defaultValue: [])
  final List<Report> reports;

  @JsonKey(defaultValue: [])
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
    this.detailes,
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

// تحويل آمن للتواريخ (حتى لو جات بدون وقت أو null)
DateTime _dateFromString(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty || dateStr == '0001-01-01T00:00:00') {
    return DateTime(1970);
  }

  // إذا كان التاريخ بدون وقت مثل: "2025-12-07"
  if (!dateStr.contains('T')) {
    return DateTime.tryParse('$dateStr') ?? DateTime.now();
  }

  return DateTime.tryParse(dateStr) ?? DateTime.now();
}

String _dateToString(DateTime date) => date.toIso8601String();