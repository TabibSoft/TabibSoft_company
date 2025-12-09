import 'package:json_annotation/json_annotation.dart';

part 'problem_model.g.dart';

@JsonSerializable()
class ProblemModel {
  final String? id;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? adderss;
  final String? problemtype;
  final String? problemAddress;
  final String? problemDetails;
  final String? phone;
  final String? problemDate;
  final String? porblemColor;
  final String? enginnerName;
  final String? details;
  final String? image;
  final String? imageUrl;
  final int? problemStatusId;
  final String? statusColor;
  final bool? isUrgent;

  // الحقل الأصلي في الكود القديم
  @JsonKey(name: 'isArchive')
  final bool? isArchive;

  // الحقل الجديد اللي جاي من الـ API
  @JsonKey(name: 'statusIsArchieve')
  final bool? statusIsArchieveRaw;

  // Getter ذكي: يسمح لك باستخدام statusIsArchieve في كل الكود بأمان
  bool? get statusIsArchieve => statusIsArchieveRaw ?? isArchive;

  // قائمة المنتجات
  final List<dynamic>? products;

  // قائمة روابط الصور من الـ API
  final List<dynamic>? images;

  // السجل التاريخي - دعم العملاء
  final List<dynamic>? customerSupport;

  // المعاملات الجارية
  final List<dynamic>? underTransactions;

  ProblemModel({
    this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.adderss,
    this.problemtype,
    this.problemAddress,
    this.problemDetails,
    this.phone,
    this.problemDate,
    this.porblemColor,
    this.enginnerName,
    this.details,
    this.image,
    this.imageUrl,
    this.problemStatusId,
    this.statusColor,
    this.isUrgent,
    this.isArchive,
    this.statusIsArchieveRaw,
    this.products,
    this.images,
    this.customerSupport,
    this.underTransactions,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) =>
      _$ProblemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemModelToJson(this);

  ProblemModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? adderss,
    String? problemtype,
    String? problemAddress,
    String? problemDetails,
    String? phone,
    String? problemDate,
    String? porblemColor,
    String? enginnerName,
    String? details,
    String? image,
    String? imageUrl,
    int? problemStatusId,
    String? statusColor,
    bool? isUrgent,
    bool? isArchive,
    bool? statusIsArchieveRaw,
    List<dynamic>? products,
    List<dynamic>? images,
    List<dynamic>? customerSupport,
    List<dynamic>? underTransactions,
  }) {
    return ProblemModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      adderss: adderss ?? this.adderss,
      problemtype: problemtype ?? this.problemtype,
      problemAddress: problemAddress ?? this.problemAddress,
      problemDetails: problemDetails ?? this.problemDetails,
      phone: phone ?? this.phone,
      problemDate: problemDate ?? this.problemDate,
      porblemColor: porblemColor ?? this.porblemColor,
      enginnerName: enginnerName ?? this.enginnerName,
      details: details ?? this.details,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      problemStatusId: problemStatusId ?? this.problemStatusId,
      statusColor: statusColor ?? this.statusColor,
      isUrgent: isUrgent ?? this.isUrgent,
      isArchive: isArchive ?? this.isArchive,
      statusIsArchieveRaw: statusIsArchieveRaw ?? this.statusIsArchieveRaw,
      products: products ?? this.products,
      images: images ?? this.images,
      customerSupport: customerSupport ?? this.customerSupport,
      underTransactions: underTransactions ?? this.underTransactions,
    );
  }

  @override
  String toString() {
    return 'ProblemModel(id: $id, customerName: $customerName, problemAddress: $problemAddress, statusIsArchieve: $statusIsArchieve)';
  }
}