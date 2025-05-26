import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/config.dart';
import 'package:hockeyapp/services/coach_service.dart' as coach_service;

class Team {
  final int id;
  final String name, shortName, logoUrl; 
  final int foundedYear;
  final coach_service.Coach? manager;
  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.logoUrl,
    required this.foundedYear,
    this.manager,
  });
  factory Team.fromJson(Map<String, dynamic> j) => Team(
    id: j['id'],
    name: j['name'],
    shortName: j['short_name'],
    logoUrl: j['logo_url'] ?? '',
    foundedYear: j['founded_year'],
    manager: j['manager'] != null ? coach_service.Coach.fromJson(j['manager']) : null,
  );
}

// class Coach {
//   final int id;
//   final String firstName;
//   final String lastName;

//   Coach({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//   });

//   factory Coach.fromJson(Map<String, dynamic> j) => Coach(
//         id: j['id'],
//         firstName: j['first_name'],
//         lastName: j['last_name'],
//       );
// }


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

  Future<bool> assignCoach(int teamId, int? coachId) async {
    await _attachToken();
    final data = {
      // pass null to unassign
      'manager': coachId,
    };
    try {
      final response = await _dio.patch('/teams/$teamId/', data: data);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error assigning coach: $e');
      return false;
    }
  }

}