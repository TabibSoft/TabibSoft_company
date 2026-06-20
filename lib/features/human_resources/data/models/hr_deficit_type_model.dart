class HrDeficitTypeModel {
  final String? id;
  final String? name;
  final int? defaultMinutes;
  final String? employeeName;
  final String? transactionType;
  final int? minutes;
  final String? reason;
  final String? createdDate;

  const HrDeficitTypeModel({
    this.id,
    this.name,
    this.defaultMinutes,
    this.employeeName,
    this.transactionType,
    this.minutes,
    this.reason,
    this.createdDate,
  });

  factory HrDeficitTypeModel.fromJson(Map<String, dynamic> json) {
    final parsedMinutes = (json['minutes'] as num?)?.toInt() ??
        (json['defaultMinutes'] as num?)?.toInt();

    return HrDeficitTypeModel(
      id: json['id']?.toString(),
      name: json['reason']?.toString() ?? json['name']?.toString(),
      defaultMinutes: parsedMinutes,
      employeeName: json['employeeName']?.toString(),
      transactionType: json['transactionType']?.toString(),
      minutes: parsedMinutes,
      reason: json['reason']?.toString(),
      createdDate: json['createdDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defaultMinutes': defaultMinutes,
        'employeeName': employeeName,
        'transactionType': transactionType,
        'minutes': minutes,
        'reason': reason,
        'createdDate': createdDate,
      };
}

class HrDeficitAdjustmentResponse {
  final int totalRecords;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalMonthMinutes;
  final List<HrDeficitTypeModel> data;

  const HrDeficitAdjustmentResponse({
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalMonthMinutes,
    required this.data,
  });

  factory HrDeficitAdjustmentResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>?)
            ?.map((item) =>
                HrDeficitTypeModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        <HrDeficitTypeModel>[];

    return HrDeficitAdjustmentResponse(
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      totalMonthMinutes: (json['totalMonthMinutes'] as num?)?.toInt() ?? 0,
      data: data,
    );
  }
}
