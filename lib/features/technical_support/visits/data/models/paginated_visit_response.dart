
import 'package:json_annotation/json_annotation.dart';
import 'visit_model.dart';

part 'paginated_visit_response.g.dart';

@JsonSerializable()
class PaginatedVisitResponse {
  final int totalRecords;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final List<VisitModel> data;

  PaginatedVisitResponse({
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedVisitResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedVisitResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedVisitResponseToJson(this);
}