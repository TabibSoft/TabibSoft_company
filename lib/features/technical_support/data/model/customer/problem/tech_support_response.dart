import 'package:json_annotation/json_annotation.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';

part 'tech_support_response.g.dart';

@JsonSerializable()
class TechSupportResponse {
  final int recordsFiltered;
  final int recordsTotal;
  final List<ProblemModel> data;

  TechSupportResponse({
    required this.recordsFiltered,
    required this.recordsTotal,
    required this.data,
  });

  factory TechSupportResponse.fromJson(Map<String, dynamic> json) => _$TechSupportResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TechSupportResponseToJson(this);
}