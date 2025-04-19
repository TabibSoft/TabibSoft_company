import 'package:json_annotation/json_annotation.dart';

part 'sales_model.g.dart';

@JsonSerializable()
class SalesModel {
  final String id;
  final String customerName;
  final String customerTelephone;
  final String fullName;
  final String statusName;
  final String proudctName; // ملاحظة الإملاء كما في الـ API
  final String productId;
  final String? note;

  // الحقول الجديدة
  final String? adress;
  final String? offerName;
  final double? total;

  SalesModel({
    required this.id,
    required this.customerName,
    required this.customerTelephone,
    required this.fullName,
    required this.statusName,
    required this.proudctName,
    required this.productId,
    this.note,
    this.adress,
    this.offerName,
    this.total,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) =>
      _$SalesModelFromJson(json);
  Map<String, dynamic> toJson() => _$SalesModelToJson(this);
}
