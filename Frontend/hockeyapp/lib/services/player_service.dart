// lib/services/player_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/config.dart';

class Player {
  final int id;
  final String firstName;
  final String lastName;
  final String dob;
  final String? position;
  final int? jerseyNo;
  final String nationality;
  final int? heightCm;
  final int? weightKg;
  final String? photo;
  final int? teamId;
  final String? teamName;
  final String? teamShortName;
  final String? teamLogo;

  Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dob,
    this.position,
    this.jerseyNo,
    required this.nationality,
    this.heightCm,
    this.weightKg,
    this.photo,
    required this.teamId,
    this.teamName,
    this.teamShortName,
    this.teamLogo

  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as int,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  dob: json['dob'] as String,
  position: json['position'] as String?,
  jerseyNo: json['jersey_no'] as int?,
  nationality: json['nationality'] as String,
  heightCm: json['height_cm'] as int?,
  weightKg: json['weight_kg'] as int?,
  photo: json['photo'] as String?,
  teamId: json['team_id'] as int?,
  teamName: json['team_name'] as String?,
  teamShortName: json['team_short_name'] as String?,
  teamLogo: json['team_logo'] as String?
);

}

class PlayerService {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future<void> _attachToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<Player>> listPlayers() async {
    await _attachToken();
    final response = await _dio.get('players/');
    
    // Handle both list response and paginated response
    if (response.data is List) {
      return (response.data as List).map((json) => Player.fromJson(json)).toList();
    } else if (response.data['results'] is List) {
      return (response.data['results'] as List).map((json) => Player.fromJson(json)).toList();
    }
    throw Exception('Invalid players list format');
  }

  Future<Player> createPlayer({
    required String firstName,
    required String lastName,
    required String dob,
    String? position,
    int? jerseyNo,
    required String nationality,
    int? heightCm,
    int? weightKg,
    String? photo,
    required int teamId,
  }) async {
    await _attachToken();
    
    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'dob': dob,
      'nationality': nationality,
      'team_id': teamId,
    };

    // Add optional fields only if they have values
    if (position != null) data['position'] = position;
    if (jerseyNo != null) data['jersey_no'] = jerseyNo;
    if (heightCm != null) data['height_cm'] = heightCm;
    if (weightKg != null) data['weight_kg'] = weightKg;
    if (photo != null && photo.isNotEmpty) data['photo'] = photo;

    final response = await _dio.post('/admin/players/', data: data);
    return Player.fromJson(response.data);
  }

  Future<bool> updatePlayer(int id, Map data) async {
    try {
      await _attachToken();
      final response = await _dio.put('/admin/players/$id/', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating player: $e');
      return false;
    }
  }
  
  Future<Player> getPlayer(int id) async {
    final resp = await _dio.get('publicplayers/$id/');
    return Player.fromJson(resp.data);
  }

  Future<List<Player>> publicListPlayers() async {
    final resp = await _dio.get('publicplayers/');
    
    final data = resp.data;
    print(data);
    if (data is List) {
      return data.map((item) => Player.fromJson(item)).toList();
    } else if (data['results'] is List) {
      return (data['results'] as List).map((item) => Player.fromJson(item)).toList();
    } else {
      throw Exception("Expected a list but got ${data.runtimeType}");
    }
  }

}