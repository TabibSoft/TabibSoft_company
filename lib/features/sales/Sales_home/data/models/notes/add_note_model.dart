import 'package:json_annotation/json_annotation.dart';

part 'add_note_model.g.dart';

@JsonSerializable()
class AddNoteDto {
  @JsonKey(name: 'measurementId')
  final String measurementId;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'exepectedCallDate')
  final DateTime? expectedCallDate;
  @JsonKey(name: 'exepectedCallTimeFrom')
  final String? expectedCallTimeFrom;
  @JsonKey(name: 'exepectedCallTimeTo')
  final String? expectedCallTimeTo;
  @JsonKey(name: 'imageFiles')
  final List<String>? imageFiles;

  AddNoteDto({
    required this.measurementId,
    this.notes,
    this.expectedCallDate,
    this.expectedCallTimeFrom,
    this.expectedCallTimeTo,
    this.imageFiles,
  });

  factory AddNoteDto.fromJson(Map<String, dynamic> json) =>
      _$AddNoteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddNoteDtoToJson(this);
}
