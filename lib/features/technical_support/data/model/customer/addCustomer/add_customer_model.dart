import 'package:json_annotation/json_annotation.dart';

part 'add_customer_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AddCustomerModel {
  final String name;
  final String telephone;
  final String engineerId;
  final String productId;
  final String? location;
  final String? createdUser;
  final String? lastEditUser;
  final DateTime? createdDate;
  final DateTime? lastEditDate;

  AddCustomerModel({
    required this.name,
    required this.telephone,
    required this.engineerId,
    required this.productId,
    this.location,
    this.createdUser,
    this.lastEditUser,
    this.createdDate,
    this.lastEditDate,
  });

  factory AddCustomerModel.fromJson(Map<String, dynamic> json) =>
      _$AddCustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddCustomerModelToJson(this);
}
