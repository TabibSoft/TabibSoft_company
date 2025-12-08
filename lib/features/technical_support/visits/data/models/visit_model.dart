// features/technical_support/visits/data/models/visit_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'visit_model.g.dart';

@JsonSerializable()
class VisitModel {
  final String id;
  final String customerName;
  @JsonKey(defaultValue: '')
  final String? customerPhone;
  @JsonKey(defaultValue: '')
  final String? note;
  @JsonKey(defaultValue: '')
  final String? visitType;
  final DateTime visitDate;
  final String visitId;
  @JsonKey(defaultValue: 'غير محدد')
  final String? engineerName;
  @JsonKey(defaultValue: '--')
  final String proudctName;
  @JsonKey(defaultValue: 'غير محدد')
  final String? adress;
  @JsonKey(defaultValue: 'غير محدد')
  final String location;
  @JsonKey(defaultValue: 'غير محدد')
  final String? status;
  @JsonKey(defaultValue: '')
  final String? statusId;
  @JsonKey(defaultValue: '#808080')
  final String? statusColor;
  @JsonKey(name: 'isInstall')
  final bool isInstallDone;
  final double totalRate;
  final bool? isArchive;
  
  // إضافة حقل visitInstallDetails
  @JsonKey(defaultValue: [])
  final List<dynamic>? visitInstallDetails;

  VisitModel({
    required this.id,
    required this.customerName,
    this.customerPhone,
    this.note,
    this.visitType,
    required this.visitDate,
    required this.visitId,
    this.engineerName,
    required this.proudctName,
    this.adress,
    required this.location,
    this.status,
    this.statusId,
    this.statusColor,
    required this.isInstallDone,
    required this.totalRate,
    this.isArchive,
    this.visitInstallDetails,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) =>
      _$VisitModelFromJson(json);

  Map<String, dynamic> toJson() => _$VisitModelToJson(this);
  
  // دالة مساعدة للتحقق من وجود تفاصيل
  bool get hasVisitDetails => 
      visitInstallDetails != null && visitInstallDetails!.isNotEmpty;
}
