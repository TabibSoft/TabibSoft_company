import 'package:flutter_test/flutter_test.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_labor_law_model.dart';

void main() {
  group('HrLaborLawResponseModel', () {
    test('parses the Egyptian labor-laws response from the API', () {
      final json = {
        'title': 'لائحة الحضور والانصراف والإجازات والاستئذان بالشركة',
        'data': [
          {
            'category': 'المواعيد والإجازات',
            'articles': [
              {
                'articleNumber': 'بند 1',
                'title': 'ساعات العمل الرسمية',
                'content': 'تبدأ من الساعة 9 صباحاً.',
              },
            ],
          },
        ],
      };

      final model = HrLaborLawResponseModel.fromJson(json);

      expect(
          model.title, 'لائحة الحضور والانصراف والإجازات والاستئذان بالشركة');
      expect(model.data, isNotEmpty);
      expect(model.data.first.category, 'المواعيد والإجازات');
      expect(model.data.first.articles, hasLength(1));
      expect(model.data.first.articles.first.articleNumber, 'بند 1');
      expect(model.data.first.articles.first.title, 'ساعات العمل الرسمية');
      expect(
          model.data.first.articles.first.content, 'تبدأ من الساعة 9 صباحاً.');
    });
  });
}
