// Modified File: features/home/data/models/today_call_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'today_call_model.g.dart';

@JsonSerializable()
class TodayCallModel {
  final String? id;
  final String? measurementId;
  final String? type;
  final String? notes;
  final String? exepectedComment;
  @JsonKey(name: 'exepectedCallDate')
  final DateTime? exepectedCallDate;
  final String? exepectedCallTimeFrom;
  final String? exepectedCallTimeTo;
  final DateTime? date;
  final DateTime? creatDate;
  final String? civilnumber;
  final String? customer;
  final String? customerName;
  final String? customerPhone;
  @JsonKey(name: 'requireImages')
  final List<String>? requireImages;
  final String? imageUrl;
  final int? count;
  final String? communicationId;

  TodayCallModel({
    this.id,
    this.measurementId,
    this.type,
    this.notes,
    this.exepectedComment,
    this.exepectedCallDate,
    this.exepectedCallTimeFrom,
    this.exepectedCallTimeTo,
    this.date,
    this.creatDate,
    this.civilnumber,
    this.customer,
    this.customerName,
    this.customerPhone,
    this.requireImages,
    this.imageUrl,
    this.count,
    this.communicationId,
  });

  factory TodayCallModel.fromJson(Map<String, dynamic> json) => _$TodayCallModelFromJson(json);
  Map<String, dynamic> toJson() => _$TodayCallModelToJson(this);
}
