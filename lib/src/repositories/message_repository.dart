import 'package:dio/dio.dart';

import '../enums/spoki_channel_type.dart';
import '../exceptions/spoki_exception.dart';
import '../models/spoki_send_result.dart';
import '../services/api_service.dart';

class MessageRepository {
  static Future<SpokiSendResult> _postSend(
    String apiKey,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await ApiService.getInstance().dio.post(
            '/api/1/messages/send/',
            options: Options(headers: {'X-Spoki-Api-Key': apiKey}),
            data: body,
          );
      return SpokiSendResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw SpokiException.fromResponse(
        httpStatus: e.response?.statusCode,
        body: e.response?.data,
      );
    }
  }

  static Future<SpokiSendResult> sendWhatsappTemplate({
    required String apiKey,
    required int templateId,
    required String phone,
    required String language,
    String? email,
    Map<String, String> customFields = const {},
    List<Map<String, dynamic>> buttons = const [],
    Map<String, dynamic> metadata = const {},
    int? channelId,
  }) {
    return _postSend(apiKey, {
      'type': 'Template',
      'phone': phone,
      'template': templateId,
      if (email != null) 'email': email,
      'language': language,
      'custom_fields': customFields,
      if (buttons.isNotEmpty) 'buttons': buttons,
      'metadata': metadata,
      if (channelId != null) 'channel_id': channelId,
    });
  }

  static Future<SpokiSendResult> sendWhatsappTemplateWithHeaderMedia({
    required String apiKey,
    required int templateId,
    required String phone,
    required String headerMediaUrl,
    required String headerMediaFilename,
    String? email,
    Map<String, String> customFields = const {},
    Map<String, dynamic> metadata = const {},
    int? channelId,
  }) {
    return _postSend(apiKey, {
      'type': 'Template',
      'phone': phone,
      'template': templateId,
      if (email != null) 'email': email,
      'header_media': {
        'url': headerMediaUrl,
        'filename': headerMediaFilename,
      },
      'custom_fields': customFields,
      'metadata': metadata,
      if (channelId != null) 'channel_id': channelId,
    });
  }

  static Future<SpokiSendResult> sendText({
    required String apiKey,
    required String phone,
    required String text,
    Map<String, dynamic> metadata = const {},
    int? channelId,
  }) {
    return _postSend(apiKey, {
      'type': 'Message',
      'content_type': 'Text',
      'phone': phone,
      'text': text,
      'metadata': metadata,
      if (channelId != null) 'channel_id': channelId,
    });
  }

  static Future<SpokiSendResult> sendWithButtons({
    required String apiKey,
    required String phone,
    required String text,
    required List<Map<String, dynamic>> buttons,
    Map<String, dynamic>? header,
    Map<String, dynamic>? footer,
    Map<String, dynamic> metadata = const {},
    int? channelId,
  }) {
    return _postSend(apiKey, {
      'type': 'Message',
      'content_type': 'Interactive',
      'phone': phone,
      'text': text,
      if (header != null) 'header': header,
      if (footer != null) 'footer': footer,
      'buttons': buttons,
      'metadata': metadata,
      if (channelId != null) 'channel_id': channelId,
    });
  }

  static Future<SpokiSendResult> sendList({
    required String apiKey,
    required String phone,
    required String text,
    required Map<String, dynamic> list,
    Map<String, dynamic>? header,
    Map<String, dynamic>? footer,
    Map<String, dynamic> metadata = const {},
    int? channelId,
  }) {
    return _postSend(apiKey, {
      'type': 'Message',
      'content_type': 'List',
      'phone': phone,
      'text': text,
      if (header != null) 'header': header,
      if (footer != null) 'footer': footer,
      'list': list,
      'metadata': metadata,
      if (channelId != null) 'channel_id': channelId,
    });
  }

  static Future<SpokiSendResult> sendWhatsappViaAutomation({
    required String automationUrl,
    required String secret,
    required String phone,
    String? firstName,
    String? lastName,
    String? email,
    String? language,
    Map<String, String> customFields = const {},
    Map<String, dynamic> metadata = const {},
  }) async {
    final dio = Dio();
    final response = await dio.post(
      automationUrl,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'secret': secret,
        'phone': phone,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (language != null) 'language': language,
        'custom_fields': customFields,
        'metadata': metadata,
      },
    );
    return SpokiSendResult.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SpokiSendResult> sendWhatsappViaAutomationBulk({
    required String automationUrl,
    required String secret,
    required List<Map<String, dynamic>> contacts,
  }) async {
    final dio = Dio();
    final bulkUrl = automationUrl.endsWith('/')
        ? '${automationUrl}bulk/'
        : '$automationUrl/bulk/';
    final response = await dio.post(
      bulkUrl,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'secret': secret,
        'contacts': contacts,
      },
    );
    return SpokiSendResult.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SpokiSendResult> send({
    required SpokiChannelType channel,
    required String automationUrl,
    required String secret,
    required String phone,
    String? firstName,
    String? lastName,
    String? email,
    Map<String, String> customFields = const {},
  }) {
    switch (channel) {
      case SpokiChannelType.whatsapp:
        return sendWhatsappViaAutomation(
          automationUrl: automationUrl,
          secret: secret,
          phone: phone,
          firstName: firstName,
          lastName: lastName,
          email: email,
          customFields: customFields,
        );
      case SpokiChannelType.sms:
      case SpokiChannelType.voice:
        throw UnimplementedError(
          'Invio via ${channel.name} non ancora implementato.',
        );
    }
  }
}
