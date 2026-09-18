class SpokiAccountReport {
  final int? accountId;
  final String? granularity;
  final DateTime? periodStart;
  final int? contactedContacts;
  final int? templateMessageCount;
  final int? freeMessageCount;
  final int? incomingMessageCount;
  final int? exchangedMessages;
  final int? sentMessageCount;
  final int? deliveredMessageCount;
  final int? readMessageCount;
  final int? conversationCount;
  final DateTime? createdDatetime;
  final DateTime? updatedDatetime;

  SpokiAccountReport({
    this.accountId,
    this.granularity,
    this.periodStart,
    this.contactedContacts,
    this.templateMessageCount,
    this.freeMessageCount,
    this.incomingMessageCount,
    this.exchangedMessages,
    this.sentMessageCount,
    this.deliveredMessageCount,
    this.readMessageCount,
    this.conversationCount,
    this.createdDatetime,
    this.updatedDatetime,
  });

  factory SpokiAccountReport.fromJson(Map<String, dynamic> json) =>
      SpokiAccountReport(
        accountId: json['account'] as int?,
        granularity: json['granularity'] as String?,
        periodStart: json['period_start'] != null
            ? DateTime.tryParse(json['period_start'] as String)
            : null,
        contactedContacts: json['contacted_contacts'] as int?,
        templateMessageCount: json['template_message_count'] as int?,
        freeMessageCount: json['free_message_count'] as int?,
        incomingMessageCount: json['incoming_message_count'] as int?,
        exchangedMessages: json['exchanged_messages'] as int?,
        sentMessageCount: json['sent_message_count'] as int?,
        deliveredMessageCount: json['delivered_message_count'] as int?,
        readMessageCount: json['read_message_count'] as int?,
        conversationCount: json['conversation_count'] as int?,
        createdDatetime: json['created_datetime'] != null
            ? DateTime.tryParse(json['created_datetime'] as String)
            : null,
        updatedDatetime: json['updated_datetime'] != null
            ? DateTime.tryParse(json['updated_datetime'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'account': accountId,
        'granularity': granularity,
        'period_start': periodStart?.toIso8601String(),
        'contacted_contacts': contactedContacts,
        'template_message_count': templateMessageCount,
        'free_message_count': freeMessageCount,
        'incoming_message_count': incomingMessageCount,
        'exchanged_messages': exchangedMessages,
        'sent_message_count': sentMessageCount,
        'delivered_message_count': deliveredMessageCount,
        'read_message_count': readMessageCount,
        'conversation_count': conversationCount,
        'created_datetime': createdDatetime?.toIso8601String(),
        'updated_datetime': updatedDatetime?.toIso8601String(),
      };

  @override
  String toString() => toJson().toString();
}
