import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/whatsapp/whatsapp_models.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/whatsapp_repository.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/whatsapp/whatsapp_state.dart';

class WhatsAppCubit extends Cubit<WhatsAppState> {
  final WhatsAppRepository _repository;
  final String customerId;
  Timer? _refreshTimer;
  bool _isFetching = false;

  WhatsAppCubit({
    required WhatsAppRepository repository,
    required this.customerId,
  })  : _repository = repository,
        super(const WhatsAppState()) {
    developer.log('onCreate -- WhatsAppCubit', name: 'WhatsAppCubit');
    startPolling();
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }

  /// Start periodic polling for new messages
  void startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!isClosed && state.status != WhatsAppStatus.initial) {
        // Refresh conversations and current chat
        fetchMessages(isBackground: true);

        // Refresh bulk jobs list every 20s
        if (timer.tick % 2 == 0) {
          fetchBulkJobs(isBackground: true);
        }

        // Refresh current bulk job details if viewing one
        final currentJobId = state.currentBulkJobDetails?.job?.jobId;
        if (currentJobId != null) {
          fetchBulkJobDetails(currentJobId, isBackground: true);
        }
      }
    });
  }

  /// Stop polling
  void stopPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Upload media for WhatsApp
  Future<String?> uploadMedia(File file) async {
    emit(state.copyWith(status: WhatsAppStatus.uploadingMedia));

    try {
      final response = await _repository.uploadMedia(file);

      if (response.success && response.url != null) {
        emit(state.copyWith(status: WhatsAppStatus.success));
        return response.url;
      } else {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage: response.message ?? 'فشل رفع الملف',
        ));
        return null;
      }
    } catch (e) {
      emit(state.copyWith(
        status: WhatsAppStatus.error,
        errorMessage: 'خطأ في رفع الملف: $e',
      ));
      return null;
    }
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
  Future<void> fetchMessages({bool isBackground = false}) async {
    // تجنب الطلبات المتكررة
    if (_isFetching) return;

    _isFetching = true;
    if (!isBackground) {
      emit(state.copyWith(status: WhatsAppStatus.loadingMessages));
    }

    try {
      final response = await _repository.getNewMessages(
        customerId: customerId,
        instanceId: state.currentInstanceId,
      );

      if (response.success) {
        final currentConversations =
            List<WhatsAppConversation>.from(state.conversations);
        bool chatUpdated = false;
        List<WhatsAppMessage> updatedChatMessages =
            List<WhatsAppMessage>.from(state.currentChatMessages);

        for (final newConv in response.conversations) {
          final index = currentConversations
              .indexWhere((c) => c.phoneNumber == newConv.phoneNumber);

          if (index != -1) {
            currentConversations[index] = newConv;
          } else {
            currentConversations.add(newConv);
          }

          // If this is the currently selected chat, update messages
          if (state.selectedPhoneNumber != null &&
              (newConv.phoneNumber == state.selectedPhoneNumber)) {
            // Append new messages that are not already in updatedChatMessages
            for (final msg in newConv.messages) {
              if (!updatedChatMessages.any((m) => m.id == msg.id)) {
                updatedChatMessages.add(msg);
                chatUpdated = true;
              }
            }
          }
        }

        // Sort by last message time
        try {
          currentConversations.sort((a, b) {
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });
        } catch (e) {
          developer.log('Error sorting conversations',
              error: e, name: 'WhatsAppCubit');
        }

        if (chatUpdated) {
          // Sort chat messages by time
          updatedChatMessages.sort((a, b) =>
              (a.messageDateTime ?? '').compareTo(b.messageDateTime ?? ''));
        }

        emit(state.copyWith(
          status: WhatsAppStatus.success,
          conversations: currentConversations,
          currentChatMessages:
              chatUpdated ? updatedChatMessages : state.currentChatMessages,
          messageCount: response.messageCount,
          conversationCount: currentConversations.length,
        ));
      } else {
        if (!isBackground) {
          emit(state.copyWith(
            status: WhatsAppStatus.error,
            errorMessage: response.errorMessage ??
                response.message ??
                'فشل في جلب الرسائل',
          ));
        }
      }
    } catch (e, stackTrace) {
      developer.log('Error in fetchMessages: $e',
          name: 'WhatsAppCubit', error: e, stackTrace: stackTrace);
      if (!isBackground) {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage: 'خطأ في جلب الرسائل: $e',
        ));
      }
    } finally {
      _isFetching = false;
    }
  }

  /// Fetch chat messages for a specific contact
  Future<void> fetchChatMessages(String phoneNumber,
      {String? contactName}) async {
    // Format number for API
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (formattedNumber.length == 11 && formattedNumber.startsWith('01')) {
      formattedNumber = '2$formattedNumber';
    }

    emit(state.copyWith(
      status: WhatsAppStatus.loadingMessages,
      selectedPhoneNumber: formattedNumber,
      selectedContactName: contactName,
    ));

    try {
      final response = await _repository.getChatMessages(
        customerId: customerId,
        instanceId: state.currentInstanceId,
        phoneNumber: formattedNumber,
      );

      if (response.success) {
        // Update the conversation in the main list
        final updatedConversations =
            List<WhatsAppConversation>.from(state.conversations);
        final index = updatedConversations.indexWhere((c) =>
            c.phoneNumber == formattedNumber || c.phoneNumber == phoneNumber);

        if (index != -1) {
          final oldConv = updatedConversations[index];
          updatedConversations[index] = WhatsAppConversation(
            phoneNumber: oldConv.phoneNumber,
            contactName: response.contactName ?? oldConv.contactName,
            messageCount: 0, // Mark as read locally
            lastMessageTime: response.messages.isNotEmpty
                ? response.messages.last.messageDateTime
                : oldConv.lastMessageTime,
            messages: response.messages,
          );
        }

        emit(state.copyWith(
          status: WhatsAppStatus.success,
          currentChatMessages: response.messages,
          conversations: updatedConversations,
        ));
      } else {
        // Use existing conversation messages if API fails
        final conversation = state.conversations.firstWhere(
          (c) =>
              c.phoneNumber == formattedNumber || c.phoneNumber == phoneNumber,
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
        (c) => c.phoneNumber == formattedNumber || c.phoneNumber == phoneNumber,
        orElse: () => WhatsAppConversation(),
      );
      emit(state.copyWith(
        status: WhatsAppStatus.success,
        currentChatMessages: conversation.messages,
      ));
    }
  }

  /// Fetch bulk jobs
  Future<void> fetchBulkJobs({bool isBackground = false}) async {
    // تجنب الطلبات المتكررة
    if (_isFetching && !isBackground) return;

    if (!isBackground) {
      emit(state.copyWith(status: WhatsAppStatus.loading));
    }

    try {
      final response = await _repository.getBulkJobs(customerId);

      if (response.success) {
        emit(state.copyWith(
          status: WhatsAppStatus.success,
          bulkJobs: response.jobs,
        ));
      } else {
        if (!isBackground) {
          emit(state.copyWith(
            status: WhatsAppStatus.error,
            errorMessage: response.message ?? 'فشل في جلب سجل الرسائل الجماعية',
          ));
        }
      }
    } catch (e) {
      developer.log('Error in fetchBulkJobs: $e',
          name: 'WhatsAppCubit', error: e);
      if (!isBackground) {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage: 'خطأ في جلب سجل الرسائل الجماعية: $e',
        ));
      }
    }
  }

  /// Fetch bulk job details
  Future<void> fetchBulkJobDetails(String jobId,
      {bool isBackground = false}) async {
    if (!isBackground) {
      emit(state.copyWith(status: WhatsAppStatus.loadingBulkJobDetails));
    }

    try {
      final response = await _repository.getBulkJobDetails(jobId);

      if (response.success) {
        emit(state.copyWith(
          status: WhatsAppStatus.success,
          currentBulkJobDetails: response,
        ));
      } else {
        if (!isBackground) {
          emit(state.copyWith(
            status: WhatsAppStatus.error,
            errorMessage:
                response.message ?? 'فشل في جلب تفاصيل الرسالة الجماعية',
          ));
        }
      }
    } catch (e) {
      if (!isBackground) {
        emit(state.copyWith(
          status: WhatsAppStatus.error,
          errorMessage: 'خطأ في جلب تفاصيل الرسالة الجماعية: $e',
        ));
      }
    }
  }

  /// Send a single message
  Future<bool> sendMessage({
    required String toNumber,
    String? message,
    String? mediaUrl,
    String? caption,
    bool isGroup = false,
  }) async {
    emit(state.copyWith(status: WhatsAppStatus.sendingMessage));

    try {
      // Format number for API
      String formattedNumber = toNumber.replaceAll(RegExp(r'\D'), '');
      if (formattedNumber.length == 11 && formattedNumber.startsWith('01')) {
        formattedNumber = '2$formattedNumber';
      }

      final request = SendMessageRequest(
        customerId: customerId,
        instanceId: state.currentInstanceId,
        toNumber: formattedNumber,
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
    String? message,
    String? jobName,
    String? mediaUrl,
    String? caption,
    int delayBetweenMessagesMs = 1000,
  }) async {
    emit(state.copyWith(status: WhatsAppStatus.sendingMessage));

    try {
      // تحويل أرقام الهواتف إلى recipients
      final recipients = phoneNumbers.map((phone) {
        // Format number for API
        String formattedNumber = phone.replaceAll(RegExp(r'\D'), '');
        if (formattedNumber.length == 11 && formattedNumber.startsWith('01')) {
          formattedNumber = '2$formattedNumber';
        }
        return WhatsAppRecipient(
          phoneNumber: formattedNumber,
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

  /// Start typing indicator
  Future<void> startTyping(String phoneNumber) async {
    try {
      // Format number for API
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (formattedNumber.length == 11 && formattedNumber.startsWith('01')) {
        formattedNumber = '2$formattedNumber';
      }

      final request = TypingRequest(
        customerId: customerId,
        instanceId: state.currentInstanceId,
        phoneNumber: formattedNumber,
      );
      await _repository.typingStart(request);
    } catch (e) {
      developer.log('Error in startTyping', error: e, name: 'WhatsAppCubit');
    }
  }

  /// Stop typing indicator
  Future<void> stopTyping(String phoneNumber) async {
    try {
      // Format number for API
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (formattedNumber.length == 11 && formattedNumber.startsWith('01')) {
        formattedNumber = '2$formattedNumber';
      }

      final request = TypingRequest(
        customerId: customerId,
        instanceId: state.currentInstanceId,
        phoneNumber: formattedNumber,
      );
      await _repository.typingStop(request);
    } catch (e) {
      developer.log('Error in stopTyping', error: e, name: 'WhatsAppCubit');
    }
  }

  /// Clear current bulk job details
  void clearBulkJobDetails() {
    emit(state.copyWith(currentBulkJobDetails: null));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null, status: WhatsAppStatus.success));
  }
}
