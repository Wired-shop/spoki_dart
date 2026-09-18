import '../models/spoki_template.dart';
import '../models/template_localization.dart';
import '../services/api_service.dart';

class TemplateRepository {
  static Future<List<SpokiTemplate>> list() async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/templates/');
    final data = response.data;
    final results = data is List ? data : (data['results'] as List? ?? []);
    return results
        .map((e) => SpokiTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SpokiTemplate> get(int id) async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/templates/$id/');
    return SpokiTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SpokiTemplate> create(
    SpokiTemplate template, {
    required TemplateLocalization localization,
  }) async {
    final response = await ApiService.getInstance().dio.post(
          '/api/1/templates/',
          data: template.toCreatePayload(localization: localization),
        );
    return SpokiTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> submit(int templateId) async {
    await ApiService.getInstance()
        .dio
        .post('/api/1/templates/$templateId/submit/', data: {});
  }

  static Future<void> delete(int templateId) async {
    await ApiService.getInstance()
        .dio
        .delete('/api/1/templates/$templateId/');
  }

  static Future<SpokiTemplate> update(
    int templateId, {
    required TemplateLocalization localization,
  }) async {
    final response = await ApiService.getInstance().dio.patch(
      '/api/1/templates/$templateId/',
      data: {
        'templatelocalization_set': [localization.toCreatePayload()],
      },
    );
    return SpokiTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> backToDraft(int templateId) async {
    await ApiService.getInstance()
        .dio
        .post('/api/1/templates/$templateId/back_to_draft/', data: {});
  }

  static Future<SpokiTemplate> clone(int templateId) async {
    final response = await ApiService.getInstance()
        .dio
        .get('/api/1/templates/$templateId/clone/');
    return SpokiTemplate.fromJson(response.data as Map<String, dynamic>);
  }
}
