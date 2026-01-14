import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/networking/dio_factory.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/whatsapp/whatsapp_models.dart';

class WhatsAppRepository {
  late final ApiService _apiService;

  WhatsAppRepository({Dio? dio}) {
    // Use the passed Dio instance or get the shared instance from DioFactory
    // This ensures we get the PrettyDioLogger and other standard configurations
    final dioInstance = dio ?? DioFactory.getDio();

    _apiService = ApiService(dioInstance);
  }

  void _log(String message, {Object? error}) {
    developer.log(message, name: 'WhatsAppRepository', error: error);
  }

  /// Get WhatsApp instances for a customer
  Future<WhatsAppInstancesResponse> getInstances(String customerId) async {
    try {
      _log('Getting instances for customer: $customerId');
      return await _apiService.getWhatsAppInstances(customerId);
    } on DioException catch (e) {
      _log('DioException in getInstances: ${e.message}', error: e);
      return WhatsAppInstancesResponse(
        success: false,
        message: _handleError(e),
      );
    } catch (e) {
      _log('Error in getInstances', error: e);
      return WhatsAppInstancesResponse(
        success: false,
        message: 'خطأ غير متوقع: $e',
      );
    }
  }

  /// Get new messages for a customer
  Future<WhatsAppMessagesResponse> getNewMessages({
    required String customerId,
    String? instanceId,
  }) async {
    try {
      _log(
          'Getting new messages for customer: $customerId, instance: $instanceId');
      return await _apiService.getWhatsAppNewMessages({
        'customerId': customerId,
        'instanceId': instanceId,
      });
    } on DioException catch (e) {
      _log('DioException in getNewMessages: ${e.message}', error: e);
      return WhatsAppMessagesResponse(
        success: false,
        errorMessage: _handleError(e),
      );
    } catch (e) {
      _log('Error in getNewMessages', error: e);
      return WhatsAppMessagesResponse(
        success: false,
        errorMessage: 'خطأ غير متوقع: $e',
      );
    }
  }

  /// Get chat messages for a specific phone number
  Future<ChatMessagesResponse> getChatMessages({
    required String customerId,
    String? instanceId,
    required String phoneNumber,
  }) async {
    try {
      _log('Getting chat messages for phone: $phoneNumber');
      return await _apiService.getWhatsAppChatMessages({
        'customerId': customerId,
        'instanceId': instanceId,
        'phoneNumber': phoneNumber,
      });
    } on DioException catch (e) {
      _log('DioException in getChatMessages: ${e.message}', error: e);
      return ChatMessagesResponse(
        success: false,
        errorMessage: _handleError(e),
      );
    } catch (e) {
      _log('Error in getChatMessages', error: e);
      return ChatMessagesResponse(
        success: false,
        errorMessage: 'خطأ غير متوقع: $e',
      );
    }
  }

  /// Send a single message
  Future<SendMessageResponse> sendMessage(SendMessageRequest request) async {
    try {
      _log('Sending message to: ${request.toNumber}');
      return await _apiService.sendWhatsAppMessage(request);
    } on DioException catch (e) {
      _log('DioException in sendMessage: ${e.message}', error: e);
      return SendMessageResponse(
        success: false,
        errorMessage: _handleError(e),
      );
    } catch (e) {
      _log('Error in sendMessage', error: e);
      return SendMessageResponse(
        success: false,
        errorMessage: 'خطأ غير متوقع: $e',
      );
    }
  }

  /// Send bulk messages
  Future<SendMessageResponse> sendBulkMessage(
      BulkMessageRequest request) async {
    try {
      _log('Sending bulk message to ${request.recipients.length} recipients');
      return await _apiService.sendWhatsAppBulkMessage(request);
    } on DioException catch (e) {
      _log('DioException in sendBulkMessage: ${e.message}', error: e);
      return SendMessageResponse(
        success: false,
        errorMessage: _handleError(e),
      );
    } catch (e) {
      _log('Error in sendBulkMessage', error: e);
      return SendMessageResponse(
        success: false,
        errorMessage: 'خطأ غير متوقع: $e',
      );
    }
  }

  /// Get bulk jobs history
  Future<WhatsAppBulkJobsResponse> getBulkJobs(String customerId) async {
    try {
      _log('Getting bulk jobs for customer: $customerId');
      return await _apiService.getWhatsAppBulkJobs(customerId);
    } on DioException catch (e) {
      _log('DioException in getBulkJobs: ${e.message}', error: e);
      return WhatsAppBulkJobsResponse(
        success: false,
        message: _handleError(e),
      );
    } catch (e) {
      _log('Error in getBulkJobs', error: e);
      return WhatsAppBulkJobsResponse(
        success: false,
        message: 'خطأ غير متوقع: $e',
      );
    }
  }

  /// Get bulk job details
  Future<WhatsAppBulkJobDetailsResponse> getBulkJobDetails(String jobId) async {
    try {
      _log('Getting bulk job details for job: $jobId');
      return await _apiService.getWhatsAppBulkJobDetails(jobId);
    } on DioException catch (e) {
      _log('DioException in getBulkJobDetails: ${e.message}', error: e);
      return WhatsAppBulkJobDetailsResponse(
        success: false,
        message: _handleError(e),
      );
    } catch (e) {
      _log('Error in getBulkJobDetails', error: e);
      return WhatsAppBulkJobDetailsResponse(
        success: false,
        message: 'خطأ غير متوقع: $e',
      );
    }
  }

  /// Check API health
  Future<bool> checkHealth() async {
    try {
      await _apiService.checkWhatsAppHealth();
      return true;
    } catch (e) {
      _log('Health check failed', error: e);
      return false;
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت.';
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة إرسال البيانات.';
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة استلام البيانات.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = '';
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? '';
        }
        if (statusCode == 404) {
          // This usually means the endpoint is wrong OR the resource (like customer) is not found
          return 'الخدمة غير متوفرة (404). يرجى التحقق من الخادم.';
        } else if (statusCode == 401) {
          return 'غير مصرح. يرجى تسجيل الدخول مرة أخرى.';
        } else if (statusCode == 500) {
          return 'خطأ في الخادم (500). يرجى المحاولة لاحقاً.';
        }
        return message.isNotEmpty ? message : 'خطأ من الخادم ($statusCode)';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب.';
      case DioExceptionType.connectionError:
        return 'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.';
      default:
        return e.message ?? 'حدث خطأ غير متوقع.';
    }
  }
}
