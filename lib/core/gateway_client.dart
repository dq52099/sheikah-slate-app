import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class GatewayClient {
  late Dio _dio;
  String baseUrl = '';
  PersistCookieJar? cookieJar;

  GatewayClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      contentType: 'application/json',
    ));
  }

  Future<void> init(String url) async {
    baseUrl = url;
    _dio.options.baseUrl = url;
    final dir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
    _dio.interceptors.add(CookieManager(cookieJar!));
  }

  Future<void> updateBaseUrl(String url) async {
    baseUrl = url;
    _dio.options.baseUrl = url;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _dio.post('/api/auth/login', data: {
      'username': username,
      'password': password,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> checkAuth() async {
    final res = await _dio.get('/api/auth/me');
    return res.data;
  }

  Future<void> logout() async {
    await _dio.post('/api/auth/logout');
    await cookieJar?.deleteAll();
  }

  Future<Map<String, dynamic>> materialize(String runes, int count, String size, String quality, String background) async {
    final res = await _dio.post('/api/images/generate', data: {
      'prompt': runes,
      'n': count,
      'size': size,
      'quality': quality,
      'background': background,
      'response_format': 'url',
    });
    return res.data;
  }

  Future<Map<String, dynamic>> recall(String runes, String imagePath, int count, String size) async {
    final formData = FormData.fromMap({
      'prompt': runes,
      'n': count,
      'size': size,
      'response_format': 'url',
      'image': await MultipartFile.fromFile(imagePath),
    });
    final res = await _dio.post('/api/images/edit', data: formData);
    return res.data;
  }

  Future<Map<String, dynamic>> getHistory(int page) async {
    final res = await _dio.get('/api/images/history', queryParameters: {
      'page': page,
      'page_size': 20,
    });
    return res.data;
  }
}
