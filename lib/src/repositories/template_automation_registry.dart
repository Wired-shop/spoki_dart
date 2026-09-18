import '../exceptions/spoki_exception.dart';
import '../models/spoki_send_result.dart';
import '../models/template_automation_config.dart';
import 'message_repository.dart';

class TemplateAutomationRegistry {
  final Map<String, TemplateAutomationConfig> _configs = {};

  void register(TemplateAutomationConfig config) {
    _configs[config.templateKey] = config;
  }

  void registerAll(List<TemplateAutomationConfig> configs) {
    for (final config in configs) {
      register(config);
    }
  }

  List<String> get registeredKeys => _configs.keys.toList();

  Future<SpokiSendResult> send({
    required String templateKey,
    required String phone,
    String? firstName,
    String? lastName,
    String? email,
    Map<String, String> customFields = const {},
  }) {
    final config = _configs[templateKey];
    if (config == null) {
      throw SpokiException(
        'Nessuna automazione registrata per il template "$templateKey". '
        'Aggiungila con registry.register(TemplateAutomationConfig(...)).',
      );
    }

    return MessageRepository.sendWhatsappViaAutomation(
      automationUrl: config.automationUrl,
      secret: config.secret,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      email: email,
      customFields: customFields,
    );
  }
}
