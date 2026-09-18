import '../models/spoki_custom_field.dart';
import '../services/api_service.dart';

class CustomFieldRepository {
  static Future<List<SpokiCustomField>> list() async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/custom-fields/');
    final data = response.data;
    final results = data is List ? data : (data['results'] as List? ?? []);
    return results
        .map((e) => SpokiCustomField.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SpokiCustomField> get(int id) async {
    final response = await ApiService.getInstance()
        .dio
        .get('/api/1/custom-fields/$id/');
    return SpokiCustomField.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SpokiCustomField> create({
    required String label,
    required String code,
    required int fieldType,
    String? example,
  }) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/custom-fields/',
      data: {
        'label': label,
        'code': code,
        'field_type': fieldType,
        if (example != null) 'example': example,
      },
    );
    return SpokiCustomField.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SpokiCustomField> update(int id, {String? label}) async {
    final response = await ApiService.getInstance().dio.patch(
      '/api/1/custom-fields/$id/',
      data: {if (label != null) 'label': label},
    );
    return SpokiCustomField.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> delete(int id) async {
    await ApiService.getInstance().dio.delete('/api/1/custom-fields/$id/');
  }
}
