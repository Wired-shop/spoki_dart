import '../models/spoki_role.dart';
import '../services/api_service.dart';

class RoleRepository {
  static Future<List<SpokiRole>> list() async {
    final response = await ApiService.getInstance().dio.get('/api/1/roles/');
    final data = response.data;
    final results = data is List ? data : (data['results'] as List? ?? []);
    return results
        .map((e) => SpokiRole.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SpokiRole> get(int roleId) async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/roles/$roleId/');
    return SpokiRole.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SpokiRole> addServiceUser({
    required String role,
    required String name,
  }) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/roles/add_service_user/',
      data: {'role': role, 'name': name},
    );
    return SpokiRole.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> generatePrivateKey(int roleId) async {
    final response = await ApiService.getInstance()
        .dio
        .post('/api/1/roles/$roleId/generate_private_key/', data: {});
    return response.data as Map<String, dynamic>;
  }

  static Future<bool> hasPrivateKey(int roleId) async {
    final response = await ApiService.getInstance()
        .dio
        .get('/api/1/roles/$roleId/has_private_key/');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['has_private_key'] as bool? ?? false;
    }
    return data == true;
  }

  static Future<void> updateRole(int roleId, {required String role}) async {
    await ApiService.getInstance()
        .dio
        .post('/api/1/roles/$roleId/update_role/', data: {'role': role});
  }

  static Future<void> delete(int roleId) async {
    await ApiService.getInstance().dio.delete('/api/1/roles/$roleId/');
  }
}
