import 'package:dio/dio.dart';

class GatewayClient {
  final Dio _dio;

  GatewayClient({required String baseUrl, String? apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            if (apiKey != null) 'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ));

  /// Maps to POST /v1/images/generations
  Future<List<String>> materialize(String runes, int count, String size) async {
    final response = await _dio.post(
      '/v1/images/generations',
      data: {
        'prompt': runes,
        'n': count,
        'size': size,
        'response_format': 'url',
      },
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'] ?? [];
      return data.map((item) => item['url'] as String).toList();
    } else {
      throw Exception('Failed to materialize images: ${response.statusMessage}');
    }
  }

  /// Maps to POST /v1/改图
  Future<List<String>> recall(String runes, String imageBase64, int count, String size) async {
    final response = await _dio.post(
      '/v1/改图',
      data: {
        'prompt': runes,
        'image_base64': imageBase64,
        'n': count,
        'size': size,
        'response_format': 'url',
      },
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'] ?? [];
      return data.map((item) => item['url'] as String).toList();
    } else {
      throw Exception('Failed to recall images: ${response.statusMessage}');
    }
  }
}
