import 'package:dio/dio.dart';

import '../exceptions/spoki_exception.dart';

class ApiService {
  static const String restBaseUrl = 'https://api.spoki.com';

  String? _apiKey;

  final Dio dio = Dio(BaseOptions(baseUrl: restBaseUrl));

  ApiService._privateConstructor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_apiKey != null && _apiKey!.isNotEmpty) {
            options.headers['X-Spoki-Api-Key'] = _apiKey;
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) {
          final exception = SpokiException.fromResponse(
            httpStatus: error.response?.statusCode,
            body: error.response?.data,
          );
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              message: exception.message,
              error: exception,
            ),
          );
        },
      ),
    );
  }

  static final ApiService _instance = ApiService._privateConstructor();

  static ApiService getInstance() => _instance;

  void setApiKey(String apiKey) => _apiKey = apiKey;

  String? getApiKey() => _apiKey;
}
