import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String name;
  final String? productTypeId;
  final dynamic productType;
  final String? unitOfMeasureId;
  final dynamic unitOfMeasure;
  final num? salesPrice;
  final String? productCategoryId;
  final dynamic productCategory;
  final String? internalReference;
  final String? barcode;
  final String? internalNotes;
  final String? salesDescription;
  final String? imageUrl;
  final dynamic customers;
  final dynamic measurements;
  final String? createdUser;
  final String? lastEditUser;
  final String? createdDate;
  final String? lastEditDate;

  ProductModel({
    required this.id,
    required this.name,
    this.productTypeId,
    this.productType,
    this.unitOfMeasureId,
    this.unitOfMeasure,
    this.salesPrice,
    this.productCategoryId,
    this.productCategory,
    this.internalReference,
    this.barcode,
    this.internalNotes,
    this.salesDescription,
    this.imageUrl,
    this.customers,
    this.measurements,
    this.createdUser,
    this.lastEditUser,
    this.createdDate,
    this.lastEditDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}