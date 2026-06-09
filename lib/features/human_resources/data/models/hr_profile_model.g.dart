// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HrProfileModel _$HrProfileModelFromJson(Map<String, dynamic> json) =>
    HrProfileModel(
      id: json['id'] as String?,
      employeeProfileId: json['employeeProfileId'] as String?,
      employeeName: json['employeeName'] as String?,
      vacationBalance: (json['vacationBalance'] as num?)?.toInt(),
      totalVacationBalance: (json['totalVacationBalance'] as num?)?.toInt(),
      vacationMonthlyMax: (json['vacationMonthlyMax'] as num?)?.toInt(),
      casualLeaveBalance: (json['casualLeaveBalance'] as num?)?.toInt(),
      totalCasualLeaveBalance:
          (json['totalCasualLeaveBalance'] as num?)?.toInt(),
      sickLeaveBalance: (json['sickLeaveBalance'] as num?)?.toInt(),
      totalSickLeaveBalance: (json['totalSickLeaveBalance'] as num?)?.toInt(),
      fingerprintCode: json['fingerprintCode'] as String?,
      workHoursPerDay: (json['workHoursPerDay'] as num?)?.toInt(),
      defaultCheckIn: json['defaultCheckIn'] as String?,
      defaultCheckOut: json['defaultCheckOut'] as String?,
      bonusMinutes: (json['bonusMinutes'] as num?)?.toInt(),
      deficitMinutes: (json['deficitMinutes'] as num?)?.toInt(),
      financialYearStartDate: json['financialYearStartDate'] as String?,
      maxLeaveHoursPerMonth: (json['maxLeaveHoursPerMonth'] as num?)?.toInt(),
      maxLeaveHoursPerDay: (json['maxLeaveHoursPerDay'] as num?)?.toInt(),
      isActiveInHR: json['isActiveInHR'] as bool?,
    );

Map<String, dynamic> _$HrProfileModelToJson(HrProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeProfileId': instance.employeeProfileId,
      'employeeName': instance.employeeName,
      'vacationBalance': instance.vacationBalance,
      'totalVacationBalance': instance.totalVacationBalance,
      'vacationMonthlyMax': instance.vacationMonthlyMax,
      'casualLeaveBalance': instance.casualLeaveBalance,
      'totalCasualLeaveBalance': instance.totalCasualLeaveBalance,
      'sickLeaveBalance': instance.sickLeaveBalance,
      'totalSickLeaveBalance': instance.totalSickLeaveBalance,
      'fingerprintCode': instance.fingerprintCode,
      'workHoursPerDay': instance.workHoursPerDay,
      'defaultCheckIn': instance.defaultCheckIn,
      'defaultCheckOut': instance.defaultCheckOut,
      'bonusMinutes': instance.bonusMinutes,
      'deficitMinutes': instance.deficitMinutes,
      'financialYearStartDate': instance.financialYearStartDate,
      'maxLeaveHoursPerMonth': instance.maxLeaveHoursPerMonth,
      'maxLeaveHoursPerDay': instance.maxLeaveHoursPerDay,
      'isActiveInHR': instance.isActiveInHR,
    };
