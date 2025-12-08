import 'package:json_annotation/json_annotation.dart';

part 'customization_task_model.g.dart';

@JsonSerializable()
class CustomizationTaskModel {
  final String id;
  final String name;
  final List<Customization> customization;

  CustomizationTaskModel({
    required this.id,
    required this.name,
    required this.customization,
  });

  factory CustomizationTaskModel.fromJson(Map<String, dynamic> json) =>
      _$CustomizationTaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomizationTaskModelToJson(this);
}

@JsonSerializable()
class Customization {
  final String id;
  
  @JsonKey(name: 'engName', defaultValue: '')
  final String engName;
  
  @JsonKey(name: 'projectName', defaultValue: '')
  final String projectName;
  
  @JsonKey(name: 'customerName', defaultValue: '')
  final String customerName;
  
  @JsonKey(name: 'deadLine')
  final String? deadLine;
  
  @JsonKey(name: 'testEngName', defaultValue: '')
  final String testEngName;
  
  @JsonKey(name: 'testNotes', defaultValue: '')
  final String testNotes;
  
  @JsonKey(defaultValue: [])
  final List<Report> reports;
  
  @JsonKey(name: 'sitiouationStatus')
  final SituationStatus? situationStatus;

  Customization({
    required this.id,
    required this.engName,
    required this.projectName,
    required this.customerName,
    this.deadLine,
    required this.testEngName,
    required this.testNotes,
    required this.reports,
    this.situationStatus,
  });

  factory Customization.fromJson(Map<String, dynamic> json) =>
      _$CustomizationFromJson(json);

  Map<String, dynamic> toJson() => _$CustomizationToJson(this);
}

@JsonSerializable()
class Report {
  @JsonKey(includeIfNull: false)
  final String? id;
  
  @JsonKey(defaultValue: '')
  final String name;
  
  @JsonKey(name: 'note', defaultValue: '')
  final String notes;
  
  @JsonKey(name: 'finshed', defaultValue: false)
  final bool finished;
  
  @JsonKey(name: 'isTested', defaultValue: false)
  final bool isTested;
  
  @JsonKey(defaultValue: 0)
  final int time;

  Report({
    this.id,
    this.name = '',
    this.notes = '',
    this.finished = false,
    this.isTested = false,
    this.time = 0,
  });

  factory Report.fromJson(Map<String, dynamic> json) =>
      _$ReportFromJson(json);

  Map<String, dynamic> toJson() => _$ReportToJson(this);
}

@JsonSerializable()
class SituationStatus {
  @JsonKey(defaultValue: '')
  final String color;
  
  @JsonKey(defaultValue: '')
  final String name;
  
  @JsonKey(defaultValue: '')
  final String id;
  
  final String? createdUser;
  final String? lastEditUser;
  
  @JsonKey(defaultValue: '0001-01-01T00:00:00')
  final String createdDate;
  
  @JsonKey(defaultValue: '0001-01-01T00:00:00')
  final String lastEditDate;

  SituationStatus({
    this.color = '',
    this.name = '',
    this.id = '',
    this.createdUser,
    this.lastEditUser,
    this.createdDate = '0001-01-01T00:00:00',
    this.lastEditDate = '0001-01-01T00:00:00',
  });

  factory SituationStatus.fromJson(Map<String, dynamic> json) =>
      _$SituationStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SituationStatusToJson(this);
}



// import 'package:json_annotation/json_annotation.dart';

// part 'customization_task_model.g.dart';

// @JsonSerializable()
// class CustomizationTaskModel {
//   final String id;
//   final String name;
//   final List<Customization> customization;

//   CustomizationTaskModel({
//     required this.id,
//     required this.name,
//     required this.customization,
//   });

//   factory CustomizationTaskModel.fromJson(Map<String, dynamic> json) =>
//       _$CustomizationTaskModelFromJson(json);

//   Map<String, dynamic> toJson() => _$CustomizationTaskModelToJson(this);
// }

// @JsonSerializable()
// class Customization {
//   final String id;

//   @JsonKey(name: 'engName', defaultValue: '')
//   final String engName;

//   @JsonKey(name: 'projectName', defaultValue: '')
//   final String projectName;

//   @JsonKey(name: 'customerName', defaultValue: '')
//   final String customerName;

//   @JsonKey(name: 'deadLine')
//   final String? deadLine;

//   @JsonKey(name: 'testEngName', defaultValue: '')
//   final String testEngName;

//   @JsonKey(name: 'testNotes', defaultValue: '')
//   final String testNotes;

//   final List<Report> reports;

//   @JsonKey(name: 'sitiouationStatus')
//   final SituationStatus situationStatus;

//   Customization({
//     required this.id,
//     required this.engName,
//     required this.projectName,
//     required this.customerName,
//     this.deadLine,
//     required this.testEngName,
//     required this.testNotes,
//     required this.reports,
//     required this.situationStatus,
//   });

//   factory Customization.fromJson(Map<String, dynamic> json) =>
//       _$CustomizationFromJson(json);

//   Map<String, dynamic> toJson() => _$CustomizationToJson(this);
// }

// @JsonSerializable()
// class Report {
//   @JsonKey(includeIfNull: false)
//   final String? id;

//   final String name;

//   @JsonKey(name: 'note', defaultValue: '')
//   final String notes;

//   @JsonKey(name: 'finshed')
//   final bool finished;

//   @JsonKey(name: 'isTested', defaultValue: false)
//   final bool isTested;

//   final int time;

//   Report({
//     this.id,
//     required this.name,
//     this.notes = '',
//     required this.finished,
//     this.isTested = false,
//     required this.time,
//   });

//   factory Report.fromJson(Map<String, dynamic> json) =>
//       _$ReportFromJson(json);

//   Map<String, dynamic> toJson() => _$ReportToJson(this);
// }

// @JsonSerializable()
// class SituationStatus {
//   final String color;
//   final String name;
//   final String id;

//   final String? createdUser;
//   final String? lastEditUser;

//   @JsonKey(defaultValue: '0001-01-01T00:00:00')
//   final String createdDate;

//   @JsonKey(defaultValue: '0001-01-01T00:00:00')
//   final String lastEditDate;

//   SituationStatus({
//     required this.color,
//     required this.name,
//     required this.id,
//     this.createdUser,
//     this.lastEditUser,
//     required this.createdDate,
//     required this.lastEditDate,
//   });

//   factory SituationStatus.fromJson(Map<String, dynamic> json) =>
//       _$SituationStatusFromJson(json);

//   Map<String, dynamic> toJson() => _$SituationStatusToJson(this);
// }