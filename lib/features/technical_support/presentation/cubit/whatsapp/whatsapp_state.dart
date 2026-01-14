import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/whatsapp/whatsapp_models.dart';

enum WhatsAppStatus {
  initial,
  loading,
  loadingMessages,
  success,
  error,
  sendingMessage,
  loadingBulkJobDetails,
}

class WhatsAppState extends Equatable {
  final WhatsAppStatus status;
  final List<WhatsAppConversation> conversations;
  final List<WhatsAppMessage> currentChatMessages;
  final List<WhatsAppInstance> instances;
  final List<WhatsAppBulkJob> bulkJobs;
  final String? currentInstanceId;
  final int messageCount;
  final int conversationCount;
  final int totalInstances;
  final int activeInstances;
  final int maxAllowedInstances;
  final int availableSlots;
  final String? errorMessage;
  final String? selectedPhoneNumber;
  final String? selectedContactName;
  final WhatsAppBulkJobDetailsResponse? currentBulkJobDetails;

  const WhatsAppState({
    this.status = WhatsAppStatus.initial,
    this.conversations = const [],
    this.currentChatMessages = const [],
    this.instances = const [],
    this.bulkJobs = const [],
    this.currentInstanceId,
    this.messageCount = 0,
    this.conversationCount = 0,
    this.totalInstances = 0,
    this.activeInstances = 0,
    this.maxAllowedInstances = 0,
    this.availableSlots = 0,
    this.errorMessage,
    this.selectedPhoneNumber,
    this.selectedContactName,
    this.currentBulkJobDetails,
  });

  WhatsAppState copyWith({
    WhatsAppStatus? status,
    List<WhatsAppConversation>? conversations,
    List<WhatsAppMessage>? currentChatMessages,
    List<WhatsAppInstance>? instances,
    List<WhatsAppBulkJob>? bulkJobs,
    String? currentInstanceId,
    int? messageCount,
    int? conversationCount,
    int? totalInstances,
    int? activeInstances,
    int? maxAllowedInstances,
    int? availableSlots,
    String? errorMessage,
    String? selectedPhoneNumber,
    String? selectedContactName,
    WhatsAppBulkJobDetailsResponse? currentBulkJobDetails,
  }) {
    return WhatsAppState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      currentChatMessages: currentChatMessages ?? this.currentChatMessages,
      instances: instances ?? this.instances,
      bulkJobs: bulkJobs ?? this.bulkJobs,
      currentInstanceId: currentInstanceId ?? this.currentInstanceId,
      messageCount: messageCount ?? this.messageCount,
      conversationCount: conversationCount ?? this.conversationCount,
      totalInstances: totalInstances ?? this.totalInstances,
      activeInstances: activeInstances ?? this.activeInstances,
      maxAllowedInstances: maxAllowedInstances ?? this.maxAllowedInstances,
      availableSlots: availableSlots ?? this.availableSlots,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPhoneNumber: selectedPhoneNumber ?? this.selectedPhoneNumber,
      selectedContactName: selectedContactName ?? this.selectedContactName,
      currentBulkJobDetails:
          currentBulkJobDetails ?? this.currentBulkJobDetails,
    );
  }

  @override
  List<Object?> get props => [
        status,
        conversations,
        currentChatMessages,
        instances,
        bulkJobs,
        currentInstanceId,
        messageCount,
        conversationCount,
        totalInstances,
        activeInstances,
        maxAllowedInstances,
        availableSlots,
        errorMessage,
        selectedPhoneNumber,
        selectedContactName,
        currentBulkJobDetails,
      ];

  @override
  bool get stringify => true;

  @override
  String toString() {
    return 'WhatsAppState('
        'status: $status, '
        'conversations: ${conversations.length}, '
        'messages: ${currentChatMessages.length}, '
        'instances: ${instances.length}, '
        'bulkJobs: ${bulkJobs.length}, '
        'currentInstanceId: $currentInstanceId, '
        'messageCount: $messageCount, '
        'conversationCount: $conversationCount, '
        'selectedPhone: $selectedPhoneNumber, '
        'error: $errorMessage'
        ')';
  }
}
