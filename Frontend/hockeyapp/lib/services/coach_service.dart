import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/config.dart';

class Coach {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? photo;

  Coach({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.photo
  });

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        phone: json['phone'] ?? '',
        email: json['email'],
        photo: json['photo'] as String?
      );
}

class CoachService {
  final _dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
  final _storage = const FlutterSecureStorage();

  Future<void> _attachToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<Coach>> listCoaches() async {
    await _attachToken();
    final resp = await _dio.get('admin/managers/');
    final data = resp.data;
    if (data is List) {
      return data.map((e) => Coach.fromJson(e)).toList();
    } else {
      throw Exception('Expected a list but got ${data.runtimeType}');
    }
  }

  Future<Coach> getCoach(int id) async {
    await _attachToken();
    final resp = await _dio.get('publicmanagers/$id/');
    return Coach.fromJson(resp.data);
  }

  Future<Coach> createCoach({
    required String firstName,
    required String lastName,
    String phone = '',
    String? email,
    String? photo
  }) async {
    await _attachToken();
    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };

    if (email != null) data['email'] = email;
    if (photo != null && photo.isNotEmpty) data['photo'] = photo;
    
    final resp = await _dio.post('admin/managers/', data: data);
    return Coach.fromJson(resp.data);
  }

  Future<Coach> updateCoach(int id, {
    required String firstName,
    required String lastName,
    String phone = '',
    String? email,
    String? photo
  }) async {
    await _attachToken();
    final resp = await _dio.put('admin/managers/$id/', data: {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      if (email != null) 'email': email,
      if (photo != null) 'photo': photo
    });
    return Coach.fromJson(resp.data);
  }

  Future<List<Coach>> listUnassignedCoaches() async {
    await _attachToken();
    final resp = await _dio.get('admin/managers/');
    final data = resp.data as List;
    // filter where coach is NOT assigned (no managed_team)
    return data
        .where((m) => m['managed_team'] == null)
        .map((j) => Coach.fromJson(j))
        .toList();
  }

}
