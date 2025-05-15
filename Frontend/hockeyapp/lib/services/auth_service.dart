// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000/api/"));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String> register(String fullName, String email, String password) async {
    try {
      final response = await _dio.post('register/', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      });
      // If tokens are returned on register, store them:
      if (response.data.containsKey('access')) {
        final accessToken = response.data['access'];
        final refreshToken = response.data['refresh'];

        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);

        final claims = JwtDecoder.decode(accessToken);
        return claims['role'];
      } else{
        throw Exception('Registration succeeded but no tokens returned');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Registration failed');
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('login/', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];

      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'refreshToken', value: refreshToken);

      final claims = JwtDecoder.decode(accessToken);
      return claims['role'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) throw Exception('Refresh token not found');

    final response = await _dio.post('token/refresh/', data: {
      'refresh': refreshToken,
    });

    final newAccessToken = response.data['access'];
    await _storage.write(key: 'accessToken', value: newAccessToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  void logout() async {
    await _storage.deleteAll();
  }
}
