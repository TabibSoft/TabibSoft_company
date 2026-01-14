import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/whatsapp/whatsapp_models.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/whatsapp_repository.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/whatsapp/whatsapp_state.dart';

class WhatsAppCubit extends Cubit<WhatsAppState> {
  final WhatsAppRepository _repository;
  final String customerId;

  WhatsAppCubit({
    required WhatsAppRepository repository,
    required this.customerId,
  })  : _repository = repository,
        super(const WhatsAppState()) {
    developer.log('onCreate -- WhatsAppCubit', name: 'WhatsAppCubit');
  }

  @override
  void onChange(Change<WhatsAppState> change) {
    super.onChange(change);
    developer.log(
        'onChange -- WhatsAppCubit, Change { currentState: ${change.currentState}, nextState: ${change.nextState} }',
        name: 'WhatsAppCubit');
  }

  /// Initialize WhatsApp - fetch instances and messages
  Future<void> initialize() async {
    emit(state.copyWith(status: WhatsAppStatus.loading));

    try {
      // First, get instances
      final instancesResponse = await _repository.getInstances(customerId);
      developer.log(
          'Instances response: success=${instancesResponse.success}, count=${instancesResponse.instances.length}',
          name: 'WhatsAppCubit');

      String? instanceId;
      if (instancesResponse.success && instancesResponse.instances.isNotEmpty) {
        instanceId = instancesResponse.instances.first.instanceId;
        developer.log('Using instanceId: $instanceId', name: 'WhatsAppCubit');
      }

      emit(state.copyWith(
        instances: instancesResponse.instances,
        currentInstanceId: instanceId,
        totalInstances: instancesResponse.totalInstances,
        activeInstances: instancesResponse.activeInstances,
        maxAllowedInstances: instancesResponse.maxAllowedInstances,
        availableSlots: instancesResponse.availableSlots,
      ));

      // If no instances found, stop here and show appropriate message
      if (instanceId == null) {
        developer.log('No instances found for this customer',
            name: 'WhatsAppCubit');
        emit(state.copyWith(
          status: WhatsAppStatus.success, // Not an error, just empty state
          conversations: [], // Clear conversations
          errorMessage: null,
        ));
        return;
      }

      // Then fetch messages only if we have an instanceId
      await fetchMessages();
    } catch (e, stackTrace) {
      developer.log('Error in initialize: $e',
          name: 'WhatsAppCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        status: WhatsAppStatus.error,
        errorMessage: 'خطأ في التهيئة: $e',
      ));
    }
  }

  /// Fetch new messages
  Future<void> fetchMessages() async {
    // تجنب الطلبات المتكررة إذا كان هناك طلب جاري للرسائل فقط
    if (state.status == WhatsAppStatus.loadingMessages) {
      developer.log('Already loading messages, skipping duplicate request',
          name: 'WhatsAppCubit');
      return;
    }

    emit(state.copyWith(status: WhatsAppStatus.loadingMessages));

    try {
      final response = await _repository.getNewMessages(
        customerId: customerId,
        instanceId: state.currentInstanceId,
      );

      developer.log(
          'Messages response: success=${response.success}, conversations=${response.conversations.length}',
          name: 'WhatsAppCubit');

      if (response.success) {
        emit(state.copyWith(
          status: WhatsAppStatus.success,
          conversations: response.conversations,
          messageCount: response.messageCount,
          conversationCount: response.conversationCount,
        ));
      } else {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage:
              response.errorMessage ?? response.message ?? 'فشل في جلب الرسائل',
        ));
      }
    } catch (e, stackTrace) {
      developer.log('Error in fetchMessages: $e',
          name: 'WhatsAppCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        status: WhatsAppStatus.error,
        errorMessage: 'خطأ في جلب الرسائل: $e',
      ));
    }
  }

  /// Fetch chat messages for a specific contact
  Future<void> fetchChatMessages(String phoneNumber,
      {String? contactName}) async {
    emit(state.copyWith(
      status: WhatsAppStatus.loadingMessages,
      selectedPhoneNumber: phoneNumber,
      selectedContactName: contactName,
    ));

    try {
      final response = await _repository.getChatMessages(
        customerId: customerId,
        instanceId: state.currentInstanceId,
        phoneNumber: phoneNumber,
      );

      if (response.success) {
        emit(state.copyWith(
          status: WhatsAppStatus.success,
          currentChatMessages: response.messages,
        ));
      } else {
        // Use existing conversation messages if API fails
        final conversation = state.conversations.firstWhere(
          (c) => c.phoneNumber == phoneNumber,
          orElse: () => WhatsAppConversation(),
        );
        emit(state.copyWith(
          status: WhatsAppStatus.success,
          currentChatMessages: conversation.messages,
        ));
      }
    } catch (e) {
      // Use existing conversation messages if API fails
      final conversation = state.conversations.firstWhere(
        (c) => c.phoneNumber == phoneNumber,
        orElse: () => WhatsAppConversation(),
      );
      emit(state.copyWith(
        status: WhatsAppStatus.success,
        currentChatMessages: conversation.messages,
      ));
    }
  }

  /// Fetch bulk jobs
  Future<void> fetchBulkJobs() async {
    // تجنب الطلبات المتكررة إذا كان هناك طلب جاري
    if (state.status == WhatsAppStatus.loading ||
        state.status == WhatsAppStatus.loadingMessages) {
      developer.log('Already loading bulk jobs, skipping duplicate request',
          name: 'WhatsAppCubit');
      return;
    }

    emit(state.copyWith(status: WhatsAppStatus.loading));

    try {
      final response = await _repository.getBulkJobs(customerId);

      if (response.success) {
        emit(state.copyWith(
          status: WhatsAppStatus.success,
          bulkJobs: response.jobs,
        ));
      } else {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage: response.message ?? 'فشل في جلب سجل الرسائل الجماعية',
        ));
      }
    } catch (e) {
      developer.log('Error in fetchBulkJobs: $e',
          name: 'WhatsAppCubit', error: e);
      emit(state.copyWith(
        status: WhatsAppStatus.error,
        errorMessage: 'خطأ في جلب سجل الرسائل الجماعية: $e',
      ));
    }
  }

  /// Fetch bulk job details
  Future<void> fetchBulkJobDetails(String jobId) async {
    emit(state.copyWith(status: WhatsAppStatus.loadingBulkJobDetails));

    try {
      final response = await _repository.getBulkJobDetails(jobId);

      if (response.success) {
        emit(state.copyWith(
          status: WhatsAppStatus.success,
          currentBulkJobDetails: response,
        ));
      } else {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage:
              response.message ?? 'فشل في جلب تفاصيل الرسالة الجماعية',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WhatsAppStatus.error,
        errorMessage: 'خطأ في جلب تفاصيل الرسالة الجماعية: $e',
      ));
    }
  }

  /// Send a single message
  Future<bool> sendMessage({
    required String toNumber,
    required String message,
    String? mediaUrl,
    String? caption,
    bool isGroup = false,
  }) async {
    emit(state.copyWith(status: WhatsAppStatus.sendingMessage));

    try {
      final request = SendMessageRequest(
        customerId: customerId,
        instanceId: state.currentInstanceId,
        toNumber: toNumber,
        message: message,
        mediaUrl: mediaUrl,
        caption: caption,
        isGroup: isGroup,
      );

      final response = await _repository.sendMessage(request);

      if (response.success) {
        emit(state.copyWith(status: WhatsAppStatus.success));
        // Refresh messages after sending
        await fetchMessages();
        return true;
      } else {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage:
              response.errorMessage ?? response.message ?? 'فشل إرسال الرسالة',
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        status: WhatsAppStatus.error,
        errorMessage: 'خطأ في إرسال الرسالة: $e',
      ));
      return false;
    }
  }

  /// Send bulk messages
  Future<bool> sendBulkMessage({
    required List<String> phoneNumbers,
    required String message,
    String? jobName,
    String? mediaUrl,
    String? caption,
    int delayBetweenMessagesMs = 1000,
  }) async {
    emit(state.copyWith(status: WhatsAppStatus.sendingMessage));

    try {
      // تحويل أرقام الهواتف إلى recipients
      final recipients = phoneNumbers.map((phone) {
        return WhatsAppRecipient(
          phoneNumber: phone,
          name: null,
        );
      }).toList();

      final request = BulkMessageRequest(
        customerId: customerId,
        instanceId: state.currentInstanceId,
        jobName: jobName ??
            'رسالة جماعية - ${DateTime.now().toString().substring(0, 16)}',
        message: message,
        mediaUrl: mediaUrl,
        caption: caption,
        recipients: recipients,
        delayBetweenMessagesMs: delayBetweenMessagesMs,
      );

      final response = await _repository.sendBulkMessage(request);

      if (response.success) {
        emit(state.copyWith(status: WhatsAppStatus.success));
        return true;
      } else {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage:
              response.errorMessage ?? response.message ?? 'فشل إرسال الرسائل',
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        status: WhatsAppStatus.error,
        errorMessage: 'خطأ في إرسال الرسائل: $e',
      ));
      return false;
    }
  }

  /// Clear current chat messages
  void clearCurrentChat() {
    emit(state.copyWith(
      currentChatMessages: [],
      selectedPhoneNumber: null,
      selectedContactName: null,
    ));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null, status: WhatsAppStatus.success));
  }
}
