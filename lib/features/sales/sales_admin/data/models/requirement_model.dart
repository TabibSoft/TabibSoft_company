import 'package:json_annotation/json_annotation.dart';

part 'requirement_model.g.dart';

@JsonSerializable()
class RequirementReport {
  @JsonKey(name: 'requirementId')
  final String id;
  final String? measurementId;
  final String customerName;
  @JsonKey(name: 'salesName')
  final String salesPersonName;
  final String programName;
  final String? note;
  @JsonKey(name: 'createdDate')
  final String creationDate;
  final String nextCallDate;
  @JsonKey(name: 'images')
  final List<dynamic>? imagesList;
  final String? adminNote;
  final String? adminNoteUser;
  final String? adminNoteDate;
  final String statusName;
  final String? statusColor;

  // Helper getter for existing code compatibility
  bool get hasImages => imagesList != null && imagesList!.isNotEmpty;

  RequirementReport({
    required this.id,
    this.measurementId,
    required this.customerName,
    required this.salesPersonName,
    required this.programName,
    this.note,
    required this.creationDate,
    required this.nextCallDate,
    this.imagesList,
    this.adminNote,
    this.adminNoteUser,
    this.adminNoteDate,
    required this.statusName,
    this.statusColor,
  });

  factory RequirementReport.fromJson(Map<String, dynamic> json) =>
      _$RequirementReportFromJson(json);

  Map<String, dynamic> toJson() => _$RequirementReportToJson(this);
}

@JsonSerializable()
class PaginatedRequirements {
  final List<RequirementReport> data;
  final List<StatusCount>? statusCounts;
  final int? page;
  final int? pageSize;
  final int? totalPages;
  final int? totalRecords;

  PaginatedRequirements({
    required this.data,
    this.statusCounts,
    this.page,
    this.pageSize,
    this.totalPages,
    this.totalRecords,
  });

  factory PaginatedRequirements.fromJson(Map<String, dynamic> json) =>
      _$PaginatedRequirementsFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedRequirementsToJson(this);
}

@JsonSerializable()
class SalesPerson {
  final String id;
  final String name;
  final String? telephone;

  SalesPerson({
    required this.id,
    required this.name,
    this.telephone,
  });

  factory SalesPerson.fromJson(Map<String, dynamic> json) =>
      _$SalesPersonFromJson(json);

  Map<String, dynamic> toJson() => _$SalesPersonToJson(this);
}

@JsonSerializable()
class StatusCount {
  final String statusName;
  final String statusColor;
  final int count;

  StatusCount({
    required this.statusName,
    required this.statusColor,
    required this.count,
  });

  factory StatusCount.fromJson(Map<String, dynamic> json) =>
      _$StatusCountFromJson(json);

  Map<String, dynamic> toJson() => _$StatusCountToJson(this);
}
