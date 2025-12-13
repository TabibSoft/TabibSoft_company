import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

part 'create_under_transaction.g.dart';

@JsonSerializable()
class CreateUnderTransaction {
  final String customerSupportId;
  final String customerId;
  final String? note;
  final int problemstausId;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<File>? images; // لن يتم تضمينها في JSON

  CreateUnderTransaction({
    required this.customerSupportId,
    required this.customerId,
    this.note,
    required this.problemstausId,
    this.images,
  });

  factory CreateUnderTransaction.fromJson(Map<String, dynamic> json) => 
      _$CreateUnderTransactionFromJson(json);
      
  Map<String, dynamic> toJson() => _$CreateUnderTransactionToJson(this);
}
