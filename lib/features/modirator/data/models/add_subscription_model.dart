import 'package:dio/dio.dart';

class AddSubscriptionModel {
  final String customerId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime contractDate;
  final double cost;
  final double payment;
  final String payMethodId;
  final String? notes;
  final List<MultipartFile>? file;

  AddSubscriptionModel({
    required this.customerId,
    required this.startDate,
    required this.endDate,
    required this.contractDate,
    required this.cost,
    required this.payment,
    required this.payMethodId,
    this.notes,
    this.file,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'CustomerId': customerId,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'ContractDate': contractDate.toIso8601String(),
      'Cost': cost,
      'Payment': payment,
      'PayMethodId': payMethodId,
    };

    if (notes != null && notes!.isNotEmpty) {
      data['Notes'] = notes;
    }

    // Note: MultipartFile cannot be represented as JSON. Keep files out of JSON.
    return data;
  }

  FormData toFormData() {
    final data = <String, dynamic>{
      'CustomerId': customerId,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'ContractDate': contractDate.toIso8601String(),
      'Cost': cost,
      'Payment': payment,
      'PayMethodId': payMethodId,
    };

    if (notes != null && notes!.isNotEmpty) {
      data['Notes'] = notes;
    }

    if (file != null && file!.isNotEmpty) {
      data['file'] = file;
    }

    return FormData.fromMap(data);
  }

  factory AddSubscriptionModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime _parseDate(dynamic v) {
      if (v == null) throw ArgumentError('Missing date value');
      if (v is DateTime) return v;
      return DateTime.parse(v.toString());
    }

    return AddSubscriptionModel(
      customerId: json['CustomerId']?.toString() ?? json['customerId']?.toString() ?? '',
      startDate: _parseDate(json['StartDate'] ?? json['startDate']),
      endDate: _parseDate(json['EndDate'] ?? json['endDate']),
      contractDate: _parseDate(json['ContractDate'] ?? json['contractDate']),
      cost: _toDouble(json['Cost'] ?? json['cost']),
      payment: _toDouble(json['Payment'] ?? json['payment']),
      payMethodId: json['PayMethodId']?.toString() ?? json['payMethodId']?.toString() ?? '',
      notes: json['Notes']?.toString() ?? json['notes']?.toString(),
      file: null, // Files can't be reconstructed from plain JSON
    );
  }
}