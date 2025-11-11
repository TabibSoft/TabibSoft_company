import 'package:json_annotation/json_annotation.dart';

part 'sales_detail_model.g.dart';

@JsonSerializable()
class SalesDetailModel {
  final String id;
  final double discount;
  final double total;
  final double endTotal;
  final DateTime date;
  final String? offerId;
  final String? offerName;
  final String? note;
  final String engineerId;
  final String engineerName;
  final List<MeasurementRequirement> measurementRequirement;

  SalesDetailModel({
    required this.id,
    required this.discount,
    required this.total,
    required this.endTotal,
    required this.date,
    this.offerId,
    this.offerName,
    this.note,
    required this.engineerId,
    required this.engineerName,
    required this.measurementRequirement, // Add this
  });

  factory SalesDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SalesDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesDetailModelToJson(this);
}

@JsonSerializable()
class MeasurementRequirement {
  final String id;
  final String measurementId;
  final String? type;
  final String? notes;
  final String? exepectedComment;
  final DateTime? exepectedCallDate;
  final String? exepectedCallTimeFrom;
  final String? exepectedCallTimeTo;
  final DateTime? date;
  final DateTime? creatDate;
  final String? civilnumber;
  final String? customer;
  final String? customerName;
  final String? customerPhone;
  final List<String> requireImages;
  final String? imageUrl;
  final int count;
  final String? communicationId;

  MeasurementRequirement({
    required this.id,
    required this.measurementId,
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
    required this.requireImages,
    this.imageUrl,
    required this.count,
    this.communicationId,
  });

  factory MeasurementRequirement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementRequirementToJson(this);    
}
