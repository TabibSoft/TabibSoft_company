// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      productTypeId: json['productTypeId'] as String?,
      productType: json['productType'],
      unitOfMeasureId: json['unitOfMeasureId'] as String?,
      unitOfMeasure: json['unitOfMeasure'],
      salesPrice: json['salesPrice'] as num?,
      productCategoryId: json['productCategoryId'] as String?,
      productCategory: json['productCategory'],
      internalReference: json['internalReference'] as String?,
      barcode: json['barcode'] as String?,
      internalNotes: json['internalNotes'] as String?,
      salesDescription: json['salesDescription'] as String?,
      imageUrl: json['imageUrl'] as String?,
      customers: json['customers'],
      measurements: json['measurements'],
      createdUser: json['createdUser'] as String?,
      lastEditUser: json['lastEditUser'] as String?,
      createdDate: json['createdDate'] as String?,
      lastEditDate: json['lastEditDate'] as String?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'productTypeId': instance.productTypeId,
      'productType': instance.productType,
      'unitOfMeasureId': instance.unitOfMeasureId,
      'unitOfMeasure': instance.unitOfMeasure,
      'salesPrice': instance.salesPrice,
      'productCategoryId': instance.productCategoryId,
      'productCategory': instance.productCategory,
      'internalReference': instance.internalReference,
      'barcode': instance.barcode,
      'internalNotes': instance.internalNotes,
      'salesDescription': instance.salesDescription,
      'imageUrl': instance.imageUrl,
      'customers': instance.customers,
      'measurements': instance.measurements,
      'createdUser': instance.createdUser,
      'lastEditUser': instance.lastEditUser,
      'createdDate': instance.createdDate,
      'lastEditDate': instance.lastEditDate,
    };
