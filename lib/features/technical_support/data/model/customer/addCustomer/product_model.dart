import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String? createdDate;
  final String? lastEditDate;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.createdDate,
    this.lastEditDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}