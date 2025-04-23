import 'package:json_annotation/json_annotation.dart';

part 'problem_model.g.dart';

@JsonSerializable()
class ProblemModel {
  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String? adderss; // العنوان
  final String? problemtype; // نوع المشكلة (مثل "تم الحل")
  final String? problemAddress; // تفاصيل المشكلة
  final String? phone;
  final String? teacnicalSupportDate; // تاريخ الدعم الفني
  final String? problemDate; // تاريخ المشكلة
  final String? porblemColor; // لون المشكلة
  final List<dynamic>? products; // قائمة المنتجات
  final String? enginnerName; // اسم المهندس
  final String? details; // تفاصيل إضافية
  final String? problemCategoryId;
  final String? image;
  final String? imageUrl;
  final int? problemStatusId;
  final bool? haveNotifications;
  final String? createdUser;
  final String? status;
  final String? statusColor;
  final bool? statusIsArchieve;
  final String ?problemDetails;


  ProblemModel({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.adderss,
    this.problemtype,
    this.problemAddress,
    this.phone,
    this.teacnicalSupportDate,
    this.problemDate,
    this.porblemColor,
    this.products,
    this.enginnerName,
    this.details,
    this.problemCategoryId,
    this.image,
    this.imageUrl,
    this.problemStatusId,
    this.haveNotifications,
    this.createdUser,
    this.status,
    this.statusColor,
    this.statusIsArchieve,
    this.problemDetails,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) => _$ProblemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProblemModelToJson(this);
}

