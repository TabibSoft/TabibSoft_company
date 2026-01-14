// WhatsApp Models

class WhatsAppConversation {
  final String? phoneNumber;
  final String? contactName;
  final int messageCount;
  final String? lastMessageTime;
  final List<WhatsAppMessage> messages;

  WhatsAppConversation({
    this.phoneNumber,
    this.contactName,
    this.messageCount = 0,
    this.lastMessageTime,
    this.messages = const [],
  });

  factory WhatsAppConversation.fromJson(Map<String, dynamic> json) {
    try {
      return WhatsAppConversation(
        phoneNumber: _parseString(json['phoneNumber'] ?? json['from']),
        contactName: _parseString(json['contactName'] ?? json['fromName']),
        messageCount: _parseInt(json['messageCount']),
        lastMessageTime: _parseString(json['lastMessageTime']),
        messages: _parseMessagesList(json['messages']),
      );
    } catch (e) {
      return WhatsAppConversation();
    }
  }

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'contactName': contactName,
        'messageCount': messageCount,
        'lastMessageTime': lastMessageTime,
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}

class WhatsAppMessage {
  final String? id;
  final String? from;
  final String? to;
  final String? body;
  final String? messageDateTime;
  final String? fromName;
  final bool isGroupMsg;
  final bool hasMedia;
  final String? mediaUrl;
  final bool fromMe;
  final String? messageStatus;

  WhatsAppMessage({
    this.id,
    this.from,
    this.to,
    this.body,
    this.messageDateTime,
    this.fromName,
    this.isGroupMsg = false,
    this.hasMedia = false,
    this.mediaUrl,
    this.fromMe = false,
    this.messageStatus,
  });

  factory WhatsAppMessage.fromJson(Map<String, dynamic> json) {
    try {
      return WhatsAppMessage(
        id: _parseString(json['id']),
        from: _parseString(json['from']),
        to: _parseString(json['to']),
        body: _parseString(json['body']),
        messageDateTime: _parseString(json['messageDateTime']),
        fromName: _parseString(json['fromName'] ?? json['senderName']),
        isGroupMsg: _parseBool(json['isGroupMsg']),
        hasMedia: _parseBool(json['hasMedia']),
        mediaUrl: _parseString(json['mediaUrl']),
        fromMe: _parseBool(json['fromMe']),
        messageStatus: _parseString(json['messageStatus']),
      );
    } catch (e) {
      return WhatsAppMessage();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'body': body,
        'messageDateTime': messageDateTime,
        'fromName': fromName,
        'isGroupMsg': isGroupMsg,
        'hasMedia': hasMedia,
        'mediaUrl': mediaUrl,
        'fromMe': fromMe,
        'messageStatus': messageStatus,
      };
}

class WhatsAppInstance {
  final String? id;
  final String? customerId;
  final String? instanceId;
  final String? status;
  final String? phone;
  final String? session;
  final bool isConnected;
  final String? createdAt;

  WhatsAppInstance({
    this.id,
    this.customerId,
    this.instanceId,
    this.status,
    this.phone,
    this.session,
    this.isConnected = false,
    this.createdAt,
  });

  factory WhatsAppInstance.fromJson(Map<String, dynamic> json) {
    try {
      return WhatsAppInstance(
        id: _parseString(json['id']),
        customerId: _parseString(json['customerId']),
        instanceId: _parseString(json['instanceId']),
        status: _parseString(json['status']),
        phone: _parseString(json['phone']),
        session: _parseString(json['session']),
        isConnected: _parseBool(json['isConnected']),
        createdAt: _parseString(json['createdAt']),
      );
    } catch (e) {
      return WhatsAppInstance();
    }
  }
}

class WhatsAppMessagesResponse {
  final bool success;
  final String? message;
  final String? instanceId;
  final int messageCount;
  final int conversationCount;
  final List<WhatsAppConversation> conversations;
  final String? errorMessage;

  WhatsAppMessagesResponse({
    this.success = false,
    this.message,
    this.instanceId,
    this.messageCount = 0,
    this.conversationCount = 0,
    this.conversations = const [],
    this.errorMessage,
  });

  factory WhatsAppMessagesResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      if (data == null) {
        return WhatsAppMessagesResponse(
          success: _parseBool(json['success']),
          message: _parseString(json['message']),
          errorMessage: _parseString(json['message']),
        );
      }

      return WhatsAppMessagesResponse(
        success: _parseBool(json['success']),
        message: _parseString(json['message']),
        instanceId: _parseString(data['instanceId']),
        messageCount: _parseInt(data['messageCount']),
        conversationCount: _parseInt(data['conversationCount']),
        conversations: _parseConversationsList(data['conversations']),
        errorMessage: _parseString(data['errorMessage']),
      );
    } catch (e) {
      return WhatsAppMessagesResponse(
        success: false,
        errorMessage: 'خطأ في تحليل البيانات: $e',
      );
    }
  }
}

class WhatsAppInstancesResponse {
  final bool success;
  final String? message;
  final String? customerId;
  final int totalInstances;
  final int activeInstances;
  final int maxAllowedInstances;
  final int availableSlots;
  final List<WhatsAppInstance> instances;

  WhatsAppInstancesResponse({
    this.success = false,
    this.message,
    this.customerId,
    this.totalInstances = 0,
    this.activeInstances = 0,
    this.maxAllowedInstances = 0,
    this.availableSlots = 0,
    this.instances = const [],
  });

  factory WhatsAppInstancesResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      if (data == null) {
        return WhatsAppInstancesResponse(
          success: _parseBool(json['success']),
          message: _parseString(json['message']),
        );
      }

      return WhatsAppInstancesResponse(
        success: _parseBool(json['success']),
        message: _parseString(json['message']),
        customerId: _parseString(data['customerId']),
        totalInstances: _parseInt(data['totalInstances']),
        activeInstances: _parseInt(data['activeInstances']),
        maxAllowedInstances: _parseInt(data['maxAllowedInstances']),
        availableSlots: _parseInt(data['availableSlots']),
        instances: _parseInstancesList(data['instances']),
      );
    } catch (e) {
      return WhatsAppInstancesResponse(
        success: false,
        message: 'خطأ في تحليل البيانات: $e',
      );
    }
  }
}

class SendMessageRequest {
  final String customerId;
  final String? instanceId;
  final String toNumber;
  final String message;
  final String? mediaUrl;
  final String? caption;
  final bool isGroup;

  SendMessageRequest({
    required this.customerId,
    this.instanceId,
    required this.toNumber,
    required this.message,
    this.mediaUrl,
    this.caption,
    this.isGroup = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'customerId': customerId,
      'instanceId': instanceId,
      'toNumber': toNumber,
      'message': message,
      'isGroup': isGroup,
    };

    if (mediaUrl != null) data['mediaUrl'] = mediaUrl;
    if (caption != null) data['caption'] = caption;

    return data;
  }
}

class WhatsAppRecipient {
  final String phoneNumber;
  final String? name;

  WhatsAppRecipient({
    required this.phoneNumber,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'name': name,
      };
}

class BulkMessageRequest {
  final String customerId;
  final String? instanceId;
  final String? jobName;
  final String message;
  final String? mediaUrl;
  final String? caption;
  final bool isGroup;
  final List<WhatsAppRecipient> recipients;
  final int delayBetweenMessagesMs;
  final String? scheduledAt;

  BulkMessageRequest({
    required this.customerId,
    this.instanceId,
    this.jobName,
    required this.message,
    this.mediaUrl,
    this.caption,
    this.isGroup = false,
    required this.recipients,
    this.delayBetweenMessagesMs = 1000,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'customerId': customerId,
      'message': message,
      'recipients': recipients.map((r) => r.toJson()).toList(),
      'delayBetweenMessagesMs': delayBetweenMessagesMs,
    };

    if (instanceId != null) json['instanceId'] = instanceId;
    if (jobName != null) json['jobName'] = jobName;
    if (mediaUrl != null) json['mediaUrl'] = mediaUrl;
    if (caption != null) json['caption'] = caption;
    if (isGroup) json['isGroup'] = isGroup;
    if (scheduledAt != null) json['scheduledAt'] = scheduledAt;

    return json;
  }
}

class SendMessageResponse {
  final bool success;
  final String? message;
  final String? messageId;
  final String? errorMessage;

  SendMessageResponse({
    this.success = false,
    this.message,
    this.messageId,
    this.errorMessage,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      return SendMessageResponse(
        success: _parseBool(json['success']),
        message: _parseString(json['message']),
        messageId: _parseString(data?['messageId']),
        errorMessage: _parseString(data?['errorMessage']),
      );
    } catch (e) {
      return SendMessageResponse(
        success: false,
        errorMessage: 'خطأ في تحليل البيانات: $e',
      );
    }
  }
}

class GetChatMessagesRequest {
  final String customerId;
  final String? instanceId;
  final String phoneNumber;

  GetChatMessagesRequest({
    required this.customerId,
    this.instanceId,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'instanceId': instanceId,
        'phoneNumber': phoneNumber,
      };
}

class ChatMessagesResponse {
  final bool success;
  final String? message;
  final String? phoneNumber;
  final String? contactName;
  final int messageCount;
  final List<WhatsAppMessage> messages;
  final String? errorMessage;

  ChatMessagesResponse({
    this.success = false,
    this.message,
    this.phoneNumber,
    this.contactName,
    this.messageCount = 0,
    this.messages = const [],
    this.errorMessage,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      if (data == null) {
        return ChatMessagesResponse(
          success: _parseBool(json['success']),
          message: _parseString(json['message']),
        );
      }

      return ChatMessagesResponse(
        success: _parseBool(json['success']),
        message: _parseString(json['message']),
        phoneNumber: _parseString(data['phoneNumber']),
        contactName: _parseString(data['contactName']),
        messageCount: _parseInt(data['messageCount']),
        messages: _parseMessagesList(data['messages']),
        errorMessage: _parseString(data['errorMessage']),
      );
    } catch (e) {
      return ChatMessagesResponse(
        success: false,
        errorMessage: 'خطأ في تحليل البيانات: $e',
      );
    }
  }
}

// Helper functions for safe parsing
String? _parseString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is int) return value != 0;
  return false;
}

List<WhatsAppMessage> _parseMessagesList(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  try {
    return value
        .map((m) => WhatsAppMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
}

List<WhatsAppConversation> _parseConversationsList(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  try {
    return value
        .map((c) => WhatsAppConversation.fromJson(c as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
}

List<WhatsAppInstance> _parseInstancesList(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  try {
    return value
        .map((i) => WhatsAppInstance.fromJson(i as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
}

class WhatsAppBulkJob {
  final String? jobId;
  final String? customerId;
  final String? instanceId;
  final String? jobName;
  final int totalRecipients;
  final int sentCount;
  final int failedCount;
  final int pendingCount;
  final int delayBetweenMessagesMs;
  final String? status;
  final String? message;
  final String? startedAt;
  final String? completedAt;

  WhatsAppBulkJob({
    this.jobId,
    this.customerId,
    this.instanceId,
    this.jobName,
    this.totalRecipients = 0,
    this.sentCount = 0,
    this.failedCount = 0,
    this.pendingCount = 0,
    this.delayBetweenMessagesMs = 1000,
    this.status,
    this.message,
    this.startedAt,
    this.completedAt,
  });

  factory WhatsAppBulkJob.fromJson(Map<String, dynamic> json) {
    try {
      return WhatsAppBulkJob(
        jobId: _parseString(json['jobId']),
        customerId: _parseString(json['customerId']),
        instanceId: _parseString(json['instanceId']),
        jobName: _parseString(json['jobName']),
        totalRecipients: _parseInt(json['totalRecipients']),
        sentCount: _parseInt(json['sentCount']),
        failedCount: _parseInt(json['failedCount']),
        pendingCount: _parseInt(json['pendingCount']),
        delayBetweenMessagesMs: _parseInt(json['delayBetweenMessagesMs']),
        status: _parseString(json['status']),
        message: _parseString(json['message']),
        startedAt: _parseString(json['startedAt']),
        completedAt: _parseString(json['completedAt']),
      );
    } catch (e) {
      return WhatsAppBulkJob();
    }
  }
}

class WhatsAppBulkJobsResponse {
  final bool success;
  final String? message;
  final int totalJobs;
  final List<WhatsAppBulkJob> jobs;

  WhatsAppBulkJobsResponse({
    this.success = false,
    this.message,
    this.totalJobs = 0,
    this.jobs = const [],
  });

  factory WhatsAppBulkJobsResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      if (data == null) {
        return WhatsAppBulkJobsResponse(
          success: _parseBool(json['success']),
          message: _parseString(json['message']),
        );
      }

      return WhatsAppBulkJobsResponse(
        success: _parseBool(json['success']),
        message: _parseString(json['message']),
        totalJobs: _parseInt(data['totalJobs']),
        jobs: _parseBulkJobsList(data['jobs']),
      );
    } catch (e) {
      return WhatsAppBulkJobsResponse(
        success: false,
        message: 'خطأ في تحليل البيانات: $e',
      );
    }
  }
}

List<WhatsAppBulkJob> _parseBulkJobsList(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  try {
    return value
        .map((j) => WhatsAppBulkJob.fromJson(j as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
}

class WhatsAppBulkRecipient {
  final String id;
  final String phoneNumber;
  final String status;
  final String? sentAt;
  final int retryCount;

  WhatsAppBulkRecipient({
    required this.id,
    required this.phoneNumber,
    required this.status,
    this.sentAt,
    this.retryCount = 0,
  });

  factory WhatsAppBulkRecipient.fromJson(Map<String, dynamic> json) {
    return WhatsAppBulkRecipient(
      id: _parseString(json['id']) ?? '',
      phoneNumber: _parseString(json['phoneNumber']) ?? '',
      status: _parseString(json['status']) ?? 'Unknown',
      sentAt: _parseString(json['sentAt']),
      retryCount: _parseInt(json['retryCount']),
    );
  }
}

class WhatsAppBulkJobDetailsResponse {
  final bool success;
  final String? message;
  final WhatsAppBulkJob? job;
  final List<WhatsAppBulkRecipient> recipients;

  WhatsAppBulkJobDetailsResponse({
    this.success = false,
    this.message,
    this.job,
    this.recipients = const [],
  });

  factory WhatsAppBulkJobDetailsResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      if (data == null) {
        return WhatsAppBulkJobDetailsResponse(
          success: _parseBool(json['success']),
          message: _parseString(json['message']),
        );
      }

      // Parse job details from 'data' itself as it contains job fields
      final job = WhatsAppBulkJob.fromJson(data);

      // Parse recipients
      final recipients = _parseBulkRecipientsList(data['recipients']);

      return WhatsAppBulkJobDetailsResponse(
        success: _parseBool(json['success']),
        message: _parseString(json['message']),
        job: job,
        recipients: recipients,
      );
    } catch (e) {
      return WhatsAppBulkJobDetailsResponse(
        success: false,
        message: 'خطأ في تحليل البيانات: $e',
      );
    }
  }
}

List<WhatsAppBulkRecipient> _parseBulkRecipientsList(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  try {
    return value
        .map((j) => WhatsAppBulkRecipient.fromJson(j as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
}
