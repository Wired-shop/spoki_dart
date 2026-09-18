import '../models/spoki_automation.dart';
import '../services/api_service.dart';

class AutomationRepository {
  static Future<List<SpokiAutomation>> list() async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/automations/');
    final data = response.data;
    final results = data is List ? data : (data['results'] as List? ?? []);
    return results
        .map((e) => SpokiAutomation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SpokiAutomation> get(int automationId) async {
    final response = await ApiService.getInstance()
        .dio
        .get('/api/1/automations/$automationId/');
    return SpokiAutomation.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> customFieldsUsed(
      int automationId) async {
    final response = await ApiService.getInstance()
        .dio
        .get('/api/1/automations/$automationId/custom-fields-used/');
    return response.data as Map<String, dynamic>;
  }

  static Future<SpokiAutomation> create({
    required String name,
    String? description,
    String? category,
    bool isActive = true,
    bool isFavorite = false,
    List<int> automationGroups = const [],
    List<Map<String, dynamic>> steps = const [],
    List<Map<String, dynamic>> webhookSet = const [],
    List<Map<String, dynamic>> onFirstMessageStarterSet = const [],
    List<Map<String, dynamic>> fieldConditionStarterSet = const [],
  }) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/automations/',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        'is_active': isActive,
        'is_favorite': isFavorite,
        if (automationGroups.isNotEmpty) 'automation_groups': automationGroups,
        if (steps.isNotEmpty) 'steps': steps,
        if (webhookSet.isNotEmpty) 'webhook_set': webhookSet,
        if (onFirstMessageStarterSet.isNotEmpty)
          'onfirstmessagestarter_set': onFirstMessageStarterSet,
        if (fieldConditionStarterSet.isNotEmpty)
          'fieldconditionstarter_set': fieldConditionStarterSet,
      },
    );
    return SpokiAutomation.fromJson(response.data as Map<String, dynamic>);
  }
}
