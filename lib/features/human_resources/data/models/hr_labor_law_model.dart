import 'package:json_annotation/json_annotation.dart';

part 'hr_labor_law_model.g.dart';

@JsonSerializable()
class HrLaborLawResponseModel {
  const HrLaborLawResponseModel({
    required this.title,
    this.data = const [],
  });

  final String title;
  final List<HrLaborLawCategoryModel> data;

  factory HrLaborLawResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HrLaborLawResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HrLaborLawResponseModelToJson(this);
}

@JsonSerializable()
class HrLaborLawCategoryModel {
  const HrLaborLawCategoryModel({
    this.category = '',
    this.articles = const [],
  });

  final String category;
  final List<HrLaborLawArticleModel> articles;

  factory HrLaborLawCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$HrLaborLawCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$HrLaborLawCategoryModelToJson(this);
}

@JsonSerializable()
class HrLaborLawArticleModel {
  const HrLaborLawArticleModel({
    this.articleNumber = '',
    this.title = '',
    this.content = '',
  });

  final String articleNumber;
  final String title;
  final String content;

  factory HrLaborLawArticleModel.fromJson(Map<String, dynamic> json) =>
      _$HrLaborLawArticleModelFromJson(json);

  Map<String, dynamic> toJson() => _$HrLaborLawArticleModelToJson(this);
}
