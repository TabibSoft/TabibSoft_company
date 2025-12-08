import 'package:json_annotation/json_annotation.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/customer_support_history_model.dart';

part 'technical_support_details_model.g.dart';

@JsonSerializable()
class TechnicalSupportDetailsModel {
  final String? customerSupportId;
  final String? id;
  final DateTime? dateTime;
  final String? problemKindName;
  final String? problemStatusName;
  final String? note;
  final DateTime? solvidDate;
  final bool? solvid;
  final String? details;
  final String? location;
  final String? name;
  final String? problemCategoryName;
  final int? problemStatusId;
  final String? telephone;
  final String? engineer;
  final bool? isTransaction;
  final String? problemAddress;
  final String? transactionNote;
  final List<String>? images; // Assuming images are a list of URLs/paths
  final DateTime? teacnicalSupportDate;
  final String? enginnerId;
  final List<String>? products;
  final String? contactPhone;
  final String? transactionId;
  final DateTime? underTransactionDate;
  final List<dynamic>? underTransactions; // Assuming this is a list of objects, but keeping dynamic for now
  final List<CustomerSupportHistoryModel>? customerSupport;

  TechnicalSupportDetailsModel({
    this.customerSupportId,
    this.id,
    this.dateTime,
    this.problemKindName,
    this.problemStatusName,
    this.note,
    this.solvidDate,
    this.solvid,
    this.details,
    this.location,
    this.name,
    this.problemCategoryName,
    this.problemStatusId,
    this.telephone,
    this.engineer,
    this.isTransaction,
    this.problemAddress,
    this.transactionNote,
    this.images,
    this.teacnicalSupportDate,
    this.enginnerId,
    this.products,
    this.contactPhone,
    this.transactionId,
    this.underTransactionDate,
    this.underTransactions,
    this.customerSupport,
  });

  factory TechnicalSupportDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$TechnicalSupportDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TechnicalSupportDetailsModelToJson(this);
}
