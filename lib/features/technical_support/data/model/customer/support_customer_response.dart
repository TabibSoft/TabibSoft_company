import 'package:json_annotation/json_annotation.dart';

part 'support_customer_response.g.dart';

@JsonSerializable()
class AddCustomerResponse {
  final bool success;
  final int customerId;

  AddCustomerResponse({required this.success, required this.customerId});

  factory AddCustomerResponse.fromJson(Map<String, dynamic> json) =>
      _$AddCustomerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddCustomerResponseToJson(this);
}