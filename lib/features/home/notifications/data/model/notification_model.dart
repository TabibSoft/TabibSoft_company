import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? type; // Made nullable to handle null or empty string
  @JsonKey(
      name: 'createdDate', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? date;
  @JsonKey(name: 'isRecevie')
  late final bool isRead;
  final String? referenceId; // Added to match API response
  final String? measurementId; // New field to handle deal details
  final String engineerId; // Added to match API response
  final dynamic
      engineer; // Added to match API response, dynamic to handle null or any type

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.date,
    required this.isRead,
    this.referenceId,
    this.measurementId,
    required this.engineerId,
    this.engineer,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Helper methods for DateTime serialization
  static DateTime? _dateTimeFromJson(String? date) =>
      date != null ? DateTime.parse(date).toLocal() : null;
  static String? _dateTimeToJson(DateTime? date) => date?.toIso8601String();
}
