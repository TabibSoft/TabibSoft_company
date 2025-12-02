import 'package:json_annotation/json_annotation.dart';

part 'problem_model.g.dart';

@JsonSerializable()
class ProblemModel {
  final String? id;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? adderss;
  final String? problemtype;
  final String? problemAddress;
  final String? problemDetails;
  final String? phone;
  final String? problemDate;
  final String? porblemColor;
  final String? enginnerName;
  final String? details;
  final String? image;
  final String? imageUrl;
  final int? problemStatusId;
  final String? statusColor;
  final bool? isUrgent;

  // جديد: قائمة المنتجات
  final List<dynamic>? products;

  ProblemModel({
    this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.adderss,
    this.problemtype,
    this.problemAddress,
    this.problemDetails,
    this.phone,
    this.problemDate,
    this.porblemColor,
    this.enginnerName,
    this.details,
    this.image,
    this.imageUrl,
    this.problemStatusId,
    this.statusColor,
    this.isUrgent,
    this.products, // أضفناه
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) =>
      _$ProblemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemModelToJson(this);
}