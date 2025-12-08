import 'package:json_annotation/json_annotation.dart';

part 'customer_support_history_model.g.dart';

@JsonSerializable()
class CustomerSupportHistoryModel {
  final String? problemAddress;
  final String? details;
  final String? engName;
  final DateTime? dateTime;
  final String? createdUser;

  CustomerSupportHistoryModel({
    this.problemAddress,
    this.details,
    this.engName,
    this.dateTime,
    this.createdUser,
  });

  factory CustomerSupportHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerSupportHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerSupportHistoryModelToJson(this);
}
