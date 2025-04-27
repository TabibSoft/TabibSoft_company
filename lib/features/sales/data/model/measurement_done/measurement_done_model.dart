import 'package:json_annotation/json_annotation.dart';

part 'measurement_done_model.g.dart';

@JsonSerializable()
class MeasurementDoneDto {
  final String id;
  final String? location;
  final String offerId; // يجب أن يكون Guid صالح
  final String? adress;
  final String? note;
  final double total;
  final DateTime installingDate;
  final String? installingNote;
  final DateTime teacnicalSupportDate;
  final String? customerReview;
  final String realEngineerId;
  final String customerId; // يجب أن يكون Guid صالح
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endDate;
  final bool hasCustomization;
  final String? image;
  final String? measurementDone; // حقل إضافي بناءً على الخطأ

  MeasurementDoneDto({
    required this.id,
    this.location,
    required this.offerId,
    this.adress,
    this.note,
    required this.total,
    required this.installingDate,
    this.installingNote,
    required this.teacnicalSupportDate,
    this.customerReview,
    required this.realEngineerId,
    required this.customerId,
    required this.createdAt,
    required this.updatedAt,
    this.endDate,
    required this.hasCustomization,
    this.image,
    this.measurementDone,
  });

  factory MeasurementDoneDto.fromJson(Map<String, dynamic> json) =>
      _$MeasurementDoneDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementDoneDtoToJson(this);
}