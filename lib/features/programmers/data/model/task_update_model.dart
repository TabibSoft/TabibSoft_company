import 'package:json_annotation/json_annotation.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';

part 'task_update_model.g.dart';

@JsonSerializable()
class TaskUpdateModel {
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
  final List<String> engineerIds;
  final String? customerSupportId;
  
  // إصلاح customerId: إرسال null بدلاً من empty string
  @JsonKey(includeIfNull: true)
  final String? customerId;
  
  final String? detailes;
  
  @JsonKey(name: 'customizationReports')
  final List<Report> reports;
  
  final String sitiouationStatusesId;
  final String sitiouationId;
  final String? file;
  
  // هذا الحقل مطلوب
  @JsonKey(defaultValue: 'CustomizationForm')
  final String model;

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
    this.customerId,
    this.detailes,
    required this.reports,
    required this.sitiouationStatusesId,
    required this.sitiouationId,
    this.file,
    this.model = 'CustomizationForm',
  });

  factory TaskUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$TaskUpdateModelFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$TaskUpdateModelToJson(this);
    
    // إزالة customerId إذا كان empty string
    if (customerId == null || customerId!.isEmpty) {
      json.remove('customerId');
    }
    
    return json;
  }

  // تحويل آمن للتواريخ
  static DateTime _dateFromString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '0001-01-01T00:00:00') {
      return DateTime(1970);
    }

    if (!dateStr.contains('T')) {
      return DateTime.tryParse(dateStr) ?? DateTime.now();
    }

    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  static String _dateToString(DateTime date) => date.toIso8601String();
}
