import '../services/api_service.dart';

class PartnerRepository {
  static Future<List<Map<String, dynamic>>> getAssociatedAccounts() async {
    final response =
        await ApiService.getInstance().dio.get('/api/1/partners/accounts/');
    final data = response.data;
    final results = data is List ? data : (data['results'] as List? ?? []);
    return results.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createApiKeyForAccount(
      int accountId) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/partners/create_api_key_for_account/',
      data: {'account': accountId},
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> revokeApiKeyForAccount(
      int accountId) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/partners/revoke_api_key_for_account/',
      data: {'account': accountId},
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createOnboardingLink(
      int accountId) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/partners/onboarding/',
      data: {'account': accountId},
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> addSoftwareVendorClients(
    List<Map<String, dynamic>> clients,
  ) async {
    final response = await ApiService.getInstance()
        .dio
        .post('/api/1/partners/add_sv_clients/', data: clients);
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createMetaCreditSubrecharge({
    required int destinationAccount,
    required int amountMillis,
  }) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/partners/create_subrecharge/',
      data: {
        'destination_account': destinationAccount,
        'amount': amountMillis,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> setAccountProfitMargins({
    required int destinationAccount,
    int? smsProfitMargin,
    int? smsOneWayProfitMargin,
    int? utilityProfitMargin,
    int? authenticationProfitMargin,
    int? marketingProfitMargin,
    int? serviceProfitMargin,
    int? conversationProfitMargin,
  }) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/partners/set_profits/',
      data: {
        'destination_account': destinationAccount,
        if (smsProfitMargin != null) 'sms_profit_margin': smsProfitMargin,
        if (smsOneWayProfitMargin != null)
          'sms_one_way_profit_margin': smsOneWayProfitMargin,
        if (utilityProfitMargin != null)
          'utility_profit_margin': utilityProfitMargin,
        if (authenticationProfitMargin != null)
          'authentication_profit_margin': authenticationProfitMargin,
        if (marketingProfitMargin != null)
          'marketing_profit_margin': marketingProfitMargin,
        if (serviceProfitMargin != null)
          'service_profit_margin': serviceProfitMargin,
        if (conversationProfitMargin != null)
          'conversation_profit_margin': conversationProfitMargin,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> moveCreditFromAccount({
    required int accountId,
    required int creditToMoveMillis,
  }) async {
    final response = await ApiService.getInstance().dio.post(
      '/api/1/partners/move_credit_from_account/',
      data: {
        'account_id': accountId,
        'credit_to_move': creditToMoveMillis,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getAccountReport({
    required int accountId,
    required int granularity,
    required String startDate,
    required String endDate,
  }) async {
    final response = await ApiService.getInstance().dio.get(
      '/api/1/partners/get_account_report/',
      queryParameters: {
        'account_id': accountId,
        'granularity': granularity,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getAccountForecasts({
    required int accountId,
    required String countryCode,
  }) async {
    final response = await ApiService.getInstance().dio.get(
      '/api/1/partners/get_account_forecasts/',
      queryParameters: {
        'account_id': accountId,
        'country_code': countryCode,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
