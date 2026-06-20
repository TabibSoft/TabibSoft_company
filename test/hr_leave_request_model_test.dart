import 'package:flutter_test/flutter_test.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/create_hr_leave_request_model.dart';

void main() {
  group('CreateHrLeaveRequestModel', () {
    test('serializes early-permission fields for HR leave API', () {
      final request = CreateHrLeaveRequestModel(
        leaveType: 'LeaveHours',
        startDate: DateTime(2026, 6, 15),
        endDate: DateTime(2026, 6, 15),
        startTime: '13:00:00',
        endTime: '15:00:00',
        hoursRequested: 2,
      );

      final json = request.toJson();

      expect(json['leaveType'], 'LeaveHours');
      expect(json['startDate'], '2026-06-15T00:00:00.000');
      expect(json['endDate'], '2026-06-15T00:00:00.000');
      expect(json['startTime'], '13:00:00');
      expect(json['endTime'], '15:00:00');
    });
  });
}
