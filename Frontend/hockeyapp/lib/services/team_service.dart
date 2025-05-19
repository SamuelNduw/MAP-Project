import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/config.dart';
// import 'league_service.dart';

class Team {
  final int id;
  final String name, shortName, logoUrl; 
  final int foundedYear;
  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.logoUrl,
    required this.foundedYear,
  });
  factory Team.fromJson(Map<String, dynamic> j) => Team(
    id: j['id'],
    name: j['name'],
    shortName: j['short_name'],
    logoUrl: j['logo_url'] ?? '',
    foundedYear: j['founded_year'],
  );
}

class TeamService {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: '${apiBaseUrl}admin/'));

  Future<void> _attachToken() async {
    final token = await _storage.read(key: 'accessToken');
    if(token != null){
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Team> createTeam({
    required String name,
    required String shortName,
    required String logoUrl,
    required int foundedYear,
  }) async {
    await _attachToken();
    final resp = await _dio.post('teams/', data: {
      'name': name,
      'short_name': shortName,
      'logo_url': logoUrl,
      'founded_year': foundedYear,
    });
    return Team.fromJson(resp.data);
  }


  Future<List<Team>> listTeams() async {
    await _attachToken();
    final resp = await _dio.get('teams/');
    
    // SAFER: assume response is a List
    final data = resp.data;
    if (data is List) {
      return data.map((item) => Team.fromJson(item)).toList();
    } else {
      throw Exception("Expected a list but got ${data.runtimeType}");
    }
  }


  Future<Team> getTeam(int id) async {
    await _attachToken();
    final resp = await _dio.get('teams/$id/');
    return Team.fromJson(resp.data);
  }

  /// Update team by ID with given data map
  Future<bool> updateTeam(int id, Map<String, dynamic> data) async {
    try {
      await _attachToken();  // include this if you need auth
      final response = await _dio.put('/teams/$id/', data: data);
      // Some APIs return 200, some 204 for successful updates
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating team: $e');
      return false;
    }
  }

}