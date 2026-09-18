import '../services/api_service.dart';

class AgencyRepository {
  static Future<List<Map<String, dynamic>>> list() async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/agencies/');
    final data = response.data;
    final results = data is List ? data : (data['results'] as List? ?? []);
    return results.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> get(int agencyId) async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/agencies/$agencyId/');
    return response.data as Map<String, dynamic>;
  }
}
