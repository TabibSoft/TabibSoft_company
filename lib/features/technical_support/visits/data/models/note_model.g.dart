// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteModel _$NoteModelFromJson(Map<String, dynamic> json) => NoteModel(
      id: json['id'] as String,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      visitInstallId: json['visitInstallId'] as String,
      isRead: json['isRead'] as bool,
      createdUser: json['createdUser'] as String?,
      lastEditUser: json['lastEditUser'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      lastEditDate: DateTime.parse(json['lastEditDate'] as String),
    );

Map<String, dynamic> _$NoteModelToJson(NoteModel instance) => <String, dynamic>{
      'id': instance.id,
      'note': instance.note,
      'date': instance.date.toIso8601String(),
      'visitInstallId': instance.visitInstallId,
      'isRead': instance.isRead,
      'createdUser': instance.createdUser,
      'lastEditUser': instance.lastEditUser,
      'createdDate': instance.createdDate.toIso8601String(),
      'lastEditDate': instance.lastEditDate.toIso8601String(),
    };

AddNoteRequest _$AddNoteRequestFromJson(Map<String, dynamic> json) =>
    AddNoteRequest(
      visitInstallId: json['visitInstallId'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$AddNoteRequestToJson(AddNoteRequest instance) =>
    <String, dynamic>{
      'visitInstallId': instance.visitInstallId,
      'note': instance.note,
    };
