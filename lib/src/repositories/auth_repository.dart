import 'package:dio/dio.dart';

import '../exceptions/spoki_exception.dart';
import '../models/spoki_auth_token.dart';
import '../services/api_service.dart';

class AuthRepository {
  static Future<SpokiAuthToken> getAuthenticationToken({
    required String apiKey,
    required String email,
    required String privateKey,
  }) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        '${ApiService.restBaseUrl}/api/1/auth/get_authentication_token/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Spoki-Api-Key': apiKey,
        }),
        data: {'email': email, 'private_key': privateKey},
      );
      return SpokiAuthToken.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw SpokiException.fromResponse(
        httpStatus: e.response?.statusCode,
        body: e.response?.data,
      );
    }
  }
}
