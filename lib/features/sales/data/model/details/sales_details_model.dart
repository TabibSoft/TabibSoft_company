import 'package:json_annotation/json_annotation.dart';

part 'sales_details_model.g.dart';

@JsonSerializable()
class   SalesDetailModel {
  final String id;
  final String customerName;
  final String proudctName;
  final String statusName;
  final DateTime createdAt;
  final String? note;

  SalesDetailModel({
    required this.id,
    required this.customerName,
    required this.proudctName,
    required this.statusName,
    required this.createdAt,
    this.note,
  });

  factory SalesDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SalesDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesDetailModelToJson(this);
}
