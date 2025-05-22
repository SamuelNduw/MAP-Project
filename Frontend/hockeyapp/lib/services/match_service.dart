// lib/services/match_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/config.dart';

class Match {
  final int id;
  final String homeName;
  final String awayName;
  final String homeShortName;
  final String awayShortName;
  final String homeLogo;
  final String awayLogo;
  final String leagueName;
  final String date;         // match_datetime
  final int homeScore;
  final int awayScore;
  final String status;
  final String venue;

  Match({
    required this.id,
    required this.homeName,
    required this.awayName,
    required this.homeShortName,
    required this.awayShortName,
    required this.homeLogo,
    required this.awayLogo,
    required this.leagueName,
    required this.date,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.venue,
  });

  String get scoreDisplay => '$homeScore–$awayScore';

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as int,
      date: json['match_datetime'] as String,
      leagueName: json['league_name'] as String,
      status: json['status'] as String,
      homeName: json['home_team_name'] as String,
      awayName: json['away_team_name'] as String,
      homeShortName: json['home_team_short_name'] as String,
      awayShortName: json['away_team_short_name'] as String,
      homeLogo: json['home_team_logo_url'] as String,
      awayLogo: json['away_team_logo_url'] as String,
      homeScore: json['home_team_score'] as int,
      awayScore: json['away_team_score'] as int,
      venue: json['venue'] as String,
    );
  }
}

class MatchService {
  final _dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
  final _storage = const FlutterSecureStorage();

  Future<void> _attachToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<Match>> listFixtures() async {
    await _attachToken();
    final resp = await _dio.get('simplefixtures/');
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    return list.map((j) => Match.fromJson(j)).toList();
  }

  Future<Match> getFixture(int id) async {
    await _attachToken();
    final resp = await _dio.get('simplefixtures/$id/');
    return Match.fromJson(resp.data as Map<String, dynamic>);
  }
}
