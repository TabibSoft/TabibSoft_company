import 'package:json_annotation/json_annotation.dart';

part 'hr_profile_model.g.dart';

@JsonSerializable()
class HrProfileModel {
  final String? id;
  final String? employeeProfileId;
  final String? employeeName;
  final int? vacationBalance;
  final int? vacationMonthlyMax;
  final int? casualLeaveBalance;
  final int? sickLeaveBalance;
  final String? fingerprintCode;
  final int? workHoursPerDay;
  final String? defaultCheckIn;
  final String? defaultCheckOut;
  final int? bonusMinutes;
  final int? deficitMinutes;
  final String? financialYearStartDate;
  final int? maxLeaveHoursPerMonth;
  final int? maxLeaveHoursPerDay;
  final bool? isActiveInHR;

  const HrProfileModel({
    this.id,
    this.employeeProfileId,
    this.employeeName,
    this.vacationBalance,
    this.vacationMonthlyMax,
    this.casualLeaveBalance,
    this.sickLeaveBalance,
    this.fingerprintCode,
    this.workHoursPerDay,
    this.defaultCheckIn,
    this.defaultCheckOut,
    this.bonusMinutes,
    this.deficitMinutes,
    this.financialYearStartDate,
    this.maxLeaveHoursPerMonth,
    this.maxLeaveHoursPerDay,
    this.isActiveInHR,
  });

  factory HrProfileModel.fromJson(Map<String, dynamic> json) =>
      _$HrProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$HrProfileModelToJson(this);
}