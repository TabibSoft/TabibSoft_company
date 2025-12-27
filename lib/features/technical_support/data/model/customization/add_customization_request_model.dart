import 'dart:io';
import 'package:dio/dio.dart';

class AddCustomizationRequestModel {
  final String? customerId;
  final String? customerName;
  final DateTime startDate;
  final DateTime deadLine;
  final int sort;
  final String? statusId;
  final String? customerSupportId;
  final List<File> images;
  final List<Map<String, dynamic>> reports;

  AddCustomizationRequestModel({
    required this.customerId,
    required this.customerName,
    required this.startDate,
    required this.deadLine,
    required this.sort,
    required this.statusId,
    required this.customerSupportId,
    required this.images,
    required this.reports,
  }); 

  Future<FormData> toFormData() async {
    final formData = FormData();

    if (customerId != null)
      formData.fields.add(MapEntry('CustomerId', customerId!));
    if (customerName != null)
      formData.fields.add(MapEntry('CustomerName', customerName!));
    formData.fields.add(MapEntry('StartDate', startDate.toIso8601String()));
    formData.fields.add(MapEntry('DeadLine', deadLine.toIso8601String()));
    formData.fields.add(MapEntry('Sort', sort.toString()));
    if (statusId != null)
      formData.fields.add(MapEntry('sitiouationStatusesId', statusId!));
    if (customerSupportId != null)
      formData.fields.add(MapEntry('CustomerSupportId', customerSupportId!));

    for (var i = 0; i < images.length; i++) {
      final file = images[i];
      if (await file.exists()) {
        formData.files.add(MapEntry(
          'Images',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      }
    }

    for (var i = 0; i < reports.length; i++) {
      final report = reports[i];
      report.forEach((key, value) {
        if (value != null) {
          formData.fields
              .add(MapEntry('customizationReports[$i].$key', value.toString()));
        }
      });
    }

    return formData;
  }
}
//0bdb8d02-fbd6-4405-8a23-08de241caecb
//0bdb8d02-fbd6-4405-8a23-08de241caecb

//3c16068d-f2c6-4690-53a6-08dcc029fd0c
//c219b67b-9403-4405-fdef-08de45231aea
