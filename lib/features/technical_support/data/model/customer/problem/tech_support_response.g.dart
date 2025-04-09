// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tech_support_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TechSupportResponse _$TechSupportResponseFromJson(Map<String, dynamic> json) =>
    TechSupportResponse(
      recordsFiltered: (json['recordsFiltered'] as num).toInt(),
      recordsTotal: (json['recordsTotal'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => ProblemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TechSupportResponseToJson(
        TechSupportResponse instance) =>
    <String, dynamic>{
      'recordsFiltered': instance.recordsFiltered,
      'recordsTotal': instance.recordsTotal,
      'data': instance.data,
    };
