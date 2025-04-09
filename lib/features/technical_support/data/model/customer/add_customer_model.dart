import 'package:json_annotation/json_annotation.dart';

part 'add_customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final int? productId;
  final String? model;

  CustomerModel({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.productId,
    this.model,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);
}
