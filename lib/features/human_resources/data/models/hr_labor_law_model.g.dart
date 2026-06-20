// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_labor_law_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HrLaborLawResponseModel _$HrLaborLawResponseModelFromJson(
        Map<String, dynamic> json) =>
    HrLaborLawResponseModel(
      title: json['title'] as String,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) =>
                  HrLaborLawCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HrLaborLawResponseModelToJson(
        HrLaborLawResponseModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'data': instance.data,
    };

HrLaborLawCategoryModel _$HrLaborLawCategoryModelFromJson(
        Map<String, dynamic> json) =>
    HrLaborLawCategoryModel(
      category: json['category'] as String? ?? '',
      articles: (json['articles'] as List<dynamic>?)
              ?.map((e) =>
                  HrLaborLawArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HrLaborLawCategoryModelToJson(
        HrLaborLawCategoryModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'articles': instance.articles,
    };

HrLaborLawArticleModel _$HrLaborLawArticleModelFromJson(
        Map<String, dynamic> json) =>
    HrLaborLawArticleModel(
      articleNumber: json['articleNumber'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );

Map<String, dynamic> _$HrLaborLawArticleModelToJson(
        HrLaborLawArticleModel instance) =>
    <String, dynamic>{
      'articleNumber': instance.articleNumber,
      'title': instance.title,
      'content': instance.content,
    };
