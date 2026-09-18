import '../models/spoki_account.dart';
import '../models/spoki_account_report.dart';
import '../services/api_service.dart';

class AccountRepository {
  static Future<List<SpokiAccount>> list() async {
    final response = await ApiService.getInstance().dio.get('/api/1/accounts/');
    final data = response.data;
    final results = data is List ? data : (data['results'] as List? ?? []);
    return results
        .map((e) => SpokiAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SpokiAccount> get(int id) async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/accounts/$id/');
    return SpokiAccount.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SpokiAccount> getPrimary() async {
    final accounts = await list();
    if (accounts.isEmpty) {
      throw StateError('Nessun account trovato per questa API Key.');
    }
    return accounts.first;
  }

  static Future<SpokiAccountReport> currentReport(int accountId) async {
    final response = await ApiService.getInstance()
        .dio
        .get('/api/1/accounts/$accountId/current_report/');
    return SpokiAccountReport.fromJson(response.data as Map<String, dynamic>);
  }
}
