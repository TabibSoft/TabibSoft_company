import 'package:json_annotation/json_annotation.dart';

part 'note_model.g.dart';

@JsonSerializable()
class NoteModel {
  final String id;
  final String? note;
  final DateTime date;
  final String visitInstallId;
  final bool isRead;
  final String? createdUser;
  final String? lastEditUser;
  final DateTime createdDate;
  final DateTime lastEditDate;

  NoteModel({
    required this.id,
    this.note,
    required this.date,
    required this.visitInstallId,
    required this.isRead,
    this.createdUser,
    this.lastEditUser,
    required this.createdDate,
    required this.lastEditDate,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoteModelToJson(this);
}

@JsonSerializable()
class AddNoteRequest {
  final String visitInstallId;
  final String note;

  AddNoteRequest({
    required this.visitInstallId,
    required this.note,
  });

  factory AddNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$AddNoteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddNoteRequestToJson(this);
}
