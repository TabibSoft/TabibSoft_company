import 'package:flutter_test/flutter_test.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_bonus_type_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_deficit_type_model.dart';

void main() {
  group('HR type models', () {
    test('parses bonus type data from API response', () {
      final json = {
        'id': '26b98f81-7ed5-4683-319f-08dec609034d',
        'name': 'test',
        'defaultMinutes': 150,
      };

      final model = HrBonusTypeModel.fromJson(json);

      expect(model.id, '26b98f81-7ed5-4683-319f-08dec609034d');
      expect(model.name, 'test');
      expect(model.defaultMinutes, 150);
    });

    test('parses deficit type data from API response', () {
      final json = {
        'id': '0cb5ba3b-e1ce-498b-df79-08dec6090d24',
        'name': 'خصم',
        'defaultMinutes': 150,
      };

      final model = HrDeficitTypeModel.fromJson(json);

      expect(model.id, '0cb5ba3b-e1ce-498b-df79-08dec6090d24');
      expect(model.name, 'خصم');
      expect(model.defaultMinutes, 150);
    });
  });
}
