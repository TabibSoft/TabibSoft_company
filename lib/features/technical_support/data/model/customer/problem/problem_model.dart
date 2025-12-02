import 'package:json_annotation/json_annotation.dart';

part 'problem_model.g.dart';

@JsonSerializable()
class ProblemModel {
  final String? id;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? adderss;
  final String? title;
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

  ProblemModel({
    this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.adderss,
    this.title,
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
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) =>
      _$ProblemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemModelToJson(this);
}


// import 'package:json_annotation/json_annotation.dart';

// part 'problem_model.g.dart';

// @JsonSerializable()
// class ProblemModel {
//   final String id;
//   final String customerId;
//   final String? customerName;
//   final String? customerPhone;
//   final String? adderss; // العنوان
//   final String? title; // نوع المشكلة (مثل "تم الحل")
//   final String? problemAddress; // تفاصيل المشكلة
//   final String? phone;
//   final String? teacnicalSupportDate; // تاريخ الدعم الفني
//   final String? problemDate; // تاريخ المشكلة
//   final String? porblemColor; // لون المشكلة
//   final List<dynamic>? products; // قائمة المنتجات
//   final String? enginnerName; // اسم المهندس
//   final String? details; // تفاصيل إضافية
//   final String? problemCategoryId;
//   final String? image;
//   final String? imageUrl;
//   final int? problemStatusId;
//   final bool? haveNotifications;
//   final String? createdUser;
//   final String? status;
//   final String? statusColor;
//   final bool? statusIsArchieve;
//   final String? problemDetails;

//   ProblemModel({
//     required this.id,
//     required this.customerId,
//     this.customerName,
//     this.customerPhone,
//     this.adderss,
//     this.title,
//     this.problemAddress,
//     this.phone,
//     this.teacnicalSupportDate,
//     this.problemDate,
//     this.porblemColor,
//     this.products,
//     this.enginnerName,
//     this.details,
//     this.problemCategoryId,
//     this.image,
//     this.imageUrl,
//     this.problemStatusId,
//     this.haveNotifications,
//     this.createdUser,
//     this.status,
//     this.statusColor,
//     this.statusIsArchieve,
//     this.problemDetails,
//   });

//   factory ProblemModel.fromJson(Map<String, dynamic> json) => _$ProblemModelFromJson(json);
//   Map<String, dynamic> toJson() => _$ProblemModelToJson(this);

//   // Add copyWith method to allow updating specific fields
//   ProblemModel copyWith({
//     String? id,
//     String? customerId,
//     String? customerName,
//     String? customerPhone,
//     String? adderss,
//     String? problemtype,
//     String? problemAddress,
//     String? phone,
//     String? teacnicalSupportDate,
//     String? problemDate,
//     String? porblemColor,
//     List<dynamic>? products,
//     String? enginnerName,
//     String? details,
//     String? problemCategoryId,
//     String? image,
//     String? imageUrl,
//     int? problemStatusId,
//     bool? haveNotifications,
//     String? createdUser,
//     String? status,
//     String? statusColor,
//     bool? statusIsArchieve,
//     String? problemDetails,
//   }) {
//     return ProblemModel(
//       id: id ?? this.id,
//       customerId: customerId ?? this.customerId,
//       customerName: customerName ?? this.customerName,
//       customerPhone: customerPhone ?? this.customerPhone,
//       adderss: adderss ?? this.adderss,
//       problemtype: problemtype ?? this.title,
//       problemAddress: problemAddress ?? this.problemAddress,
//       phone: phone ?? this.phone,
//       teacnicalSupportDate: teacnicalSupportDate ?? this.teacnicalSupportDate,
//       problemDate: problemDate ?? this.problemDate,
//       porblemColor: porblemColor ?? this.porblemColor,
//       products: products ?? this.products,
//       enginnerName: enginnerName ?? this.enginnerName,
//       details: details ?? this.details,
//       problemCategoryId: problemCategoryId ?? this.problemCategoryId,
//       image: image ?? this.image,
//       imageUrl: imageUrl ?? this.imageUrl,
//       problemStatusId: problemStatusId ?? this.problemStatusId,
//       haveNotifications: haveNotifications ?? this.haveNotifications,
//       createdUser: createdUser ?? this.createdUser,
//       status: status ?? this.status,
//       statusColor: statusColor ?? this.statusColor,
//       statusIsArchieve: statusIsArchieve ?? this.statusIsArchieve,
//       problemDetails: problemDetails ?? this.problemDetails,
//     );
//   }
// }