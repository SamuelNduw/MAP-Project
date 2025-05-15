import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class League {
  final int id;
  final String name, season, startDate, endDate, status;
  League({
    required this.id,
    required this.name,
    required this.season,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
  factory League.fromJson(Map<String, dynamic> j) => League(
    id: j['id'],
    name: j['name'],
    season: j['season'],
    startDate: j['start_date'],
    endDate: j['end_date'],
    status: j['status'],
  );
}

class LeagueService {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/'));

  Future<void> _attachToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<League> createLeague({
    required String name,
    required String season,
    required String startDate,
    required String endDate,
    required String status,
  }) async {
    await _attachToken();
    final resp = await _dio.post('admin/leagues/', data: {
      'name': name,
      'season': season,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    });
    return League.fromJson(resp.data);
  }

  Future<List<League>> listLeagues() async {
  await _attachToken();
  final resp = await _dio.get('admin/leagues/');
  
  // SAFER: assume response is a List
  final data = resp.data;
  if (data is List) {
    return data.map((item) => League.fromJson(item)).toList();
  } else {
    throw Exception("Expected a list but got ${data.runtimeType}");
  }
}


  Future<League> getLeague(int id) async {
    await _attachToken();
    final resp = await _dio.get('admin/leagues/$id/');
    return League.fromJson(resp.data);
  }

  Future<List<League>> listPublicLeagues() async {
    await _attachToken();
    final resp = await _dio.get('publicleagues/');
    
    // SAFER: assume response is a List
    final data = resp.data;
    if (data is List) {
      return data.map((item) => League.fromJson(item)).toList();
    } else {
      throw Exception("Expected a list but got ${data.runtimeType}");
    }
  }

  Future<League> getPublicLeague(int id) async {
    await _attachToken();
    final resp = await _dio.get('publicleagues/$id/');
    return League.fromJson(resp.data);
  }

}
