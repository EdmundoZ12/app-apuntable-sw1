import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://backend-sw1.onrender.com';
  // final String _baseUrl = 'http://192.168.100.54:3000';


  DioClient() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Configuración adicional
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    // Interceptores para logging detallado
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 Request URL: ${options.uri}');
        print('📦 Request Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Response Status: ${response.statusCode}');
        print('📥 Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        print('❌ Error: ${error.message}');
        print('🔍 Error Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}