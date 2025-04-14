import 'package:json_annotation/json_annotation.dart';

part 'create_under_transaction.g.dart';

@JsonSerializable()
class CreateUnderTransaction {
  final String customerSupportId;
  final String customerId;
  final String? note;
  final int problemstausId;

  CreateUnderTransaction({
    required this.customerSupportId,
    required this.customerId,
    this.note,
    required this.problemstausId,
  });

  factory CreateUnderTransaction.fromJson(Map<String, dynamic> json) => _$CreateUnderTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUnderTransactionToJson(this);
}
