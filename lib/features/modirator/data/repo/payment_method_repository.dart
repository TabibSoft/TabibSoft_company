// lib/features/sales/subscription/data/repositories/payment_method_repository.dart

import 'package:tabib_soft_company/core/networking/api_service.dart';
import '../models/payment_method_model.dart';

class PaymentMethodRepository {
  final ApiService apiService;

  PaymentMethodRepository(this.apiService);

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      return await apiService.getAllPaymentMethods();
    } catch (e) {
      throw Exception('فشل في جلب طرق الدفع');
    }
  }
}