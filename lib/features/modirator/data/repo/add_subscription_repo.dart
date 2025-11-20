import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import '../models/add_subscription_model.dart';

class SubscriptionRepository {
  final ApiService apiService;

  SubscriptionRepository(this.apiService);

  Future<void> addSubscription(AddSubscriptionModel model) async {
    try {
      await apiService.addSubscription(model.toFormData());
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل في إضافة الاشتراك');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }
}