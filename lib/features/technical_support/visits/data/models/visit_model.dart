// features/technical_support/visits/data/models/visit_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'visit_model.g.dart';

@JsonSerializable()
class VisitModel {
  final String id;
  final String customerName;

  @JsonKey(defaultValue: '')
  final String? customerPhone;

  @JsonKey(defaultValue: '')
  final String? note;

  @JsonKey(defaultValue: '')
  final String? visitType;

  final DateTime visitDate;
  final String visitId;

  @JsonKey(defaultValue: 'غير محدد')
  final String? engineerName;

  @JsonKey(defaultValue: '--')
  final String proudctName;

  @JsonKey(defaultValue: 'غير محدد')
  final String? adress;

  @JsonKey(defaultValue: 'غير محدد')
  final String location;

  @JsonKey(defaultValue: 'غير محدد')
  final String? status;

  @JsonKey(defaultValue: '')
  final String? statusId;

  @JsonKey(defaultValue: '#808080')
  final String? statusColor;

  @JsonKey(name: 'isInstall')
  final bool isInstallDone;

  final double totalRate;
  final bool? isArchive;

  // تفاصيل الزيارة/التسطيب (قد تكون فارغة أو تحتوي على كائن واحد)
  @JsonKey(defaultValue: [])
  final List<dynamic>? visitInstallDetails;

  VisitModel({
    required this.id,
    required this.customerName,
    this.customerPhone,
    this.note,
    this.visitType,
    required this.visitDate,
    required this.visitId,
    this.engineerName,
    required this.proudctName,
    this.adress,
    required this.location,
    this.status,
    this.statusId,
    this.statusColor,
    required this.isInstallDone,
    required this.totalRate,
    this.isArchive,
    this.visitInstallDetails,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) =>
      _$VisitModelFromJson(json);

  Map<String, dynamic> toJson() => _$VisitModelToJson(this);

  // ===================================================================
  // Getters ذكية لتسهيل التعامل مع visitInstallDetails
  // ===================================================================

  /// هل يوجد تفاصيل زيارة/تسطيب؟
  bool get hasVisitDetails =>
      visitInstallDetails != null && visitInstallDetails!.isNotEmpty;

  /// معرف الـ visitInstallDetail (إذا وجد)
  String? get visitInstallDetailId {
    if (!hasVisitDetails) return null;
    final detail = visitInstallDetails!.first;
    if (detail is Map<String, dynamic>) {
      return detail['id']?.toString();
    }
    return null;
  }

  /// الملاحظة العامة (Global Note)
  String? get globalNote {
    if (!hasVisitDetails) return null;
    final detail = visitInstallDetails!.first;
    if (detail is Map<String, dynamic>) {
      return detail['note']?.toString();
    }
    return null;
  }

  /// قائمة روابط الصور القديمة من السيرفر
  List<String> get existingImages {
    final List<String> images = [];
    if (!hasVisitDetails) return images;

    final detail = visitInstallDetails!.first;
    if (detail is Map<String, dynamic>) {
      final imgs = detail['images'];
      if (imgs is List) {
        for (var img in imgs) {
          if (img is String && img.isNotEmpty && img.startsWith('http')) {
            images.add(img);
          } else if (img is Map<String, dynamic> &&
              img['url'] != null &&
              img['url'] is String) {
            final String url = img['url'];
            if (url.isNotEmpty && url.startsWith('http')) {
              images.add(url);
            }
          }
        }
      }
    }
    return images;
  }

  /// قائمة الملاحظات الفرعية (الملاحظات السابقة)
  List<dynamic> get previousNotes {
    final List<dynamic> notes = [];
    if (!hasVisitDetails) return notes;

    final detail = visitInstallDetails!.first;
    if (detail is Map<String, dynamic>) {
      final n = detail['notes'];
      if (n is List) {
        notes.addAll(n);
      }
    }
    return notes;
  }

  /// للطباعة والتصحيح
  @override
  String toString() {
    return 'VisitModel(id: $id, customer: $customerName, '
        'globalNote: $globalNote, images: ${existingImages.length}, '
        'notes: ${previousNotes.length}, isInstallDone: $isInstallDone)';
  }
}
