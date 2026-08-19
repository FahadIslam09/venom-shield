import 'dart:convert';
import 'package:dio/dio.dart';
import 'snake_database.dart';

class CloudSnakeService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  static const String _supabaseUrl = 'https://ljedvghtylsyscwimbse.supabase.co/rest/v1/snakes';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqZWR2Z2h0eWxzeXNjd2ltYnNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY2MjAwMjAsImV4cCI6MjEwMjE5NjAyMH0.4L5CIDOtFkrZl2_87VurXdCQLLfYfpaPGuZvRbjJ_8w';

  static Map<String, String> get _headers => {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates',
      };

  /// 1. Fetch community-added snakes from Supabase into local memory
  static Future<void> syncFromSupabase() async {
    try {
      final response = await _dio.get(
        '$_supabaseUrl?select=*',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List<dynamic>;
        int addedCount = 0;
        for (final raw in list) {
          if (raw is Map<String, dynamic>) {
            final species = SnakeSpecies.fromJson(raw);
            SnakeDatabase.registerDynamicSpecies(species);
            addedCount++;
          }
        }
        print('Supabase Cloud Sync: Synced $addedCount dynamic snakes to local database.');
      }
    } catch (e) {
      // Fail silently for resilient offline-first execution
      print('Supabase Cloud Sync skipped (offline or table pending): $e');
    }
  }

  /// 2. Push AI-discovered or newly added species to Supabase
  static Future<void> pushToSupabase(SnakeSpecies species) async {
    try {
      final data = species.toJson();
      await _dio.post(
        _supabaseUrl,
        data: json.encode(data),
        options: Options(headers: _headers),
      );
      print('Successfully pushed ${species.speciesEn} (${species.scientificName}) to Supabase Cloud.');
    } catch (e) {
      print('Failed to push species to Supabase (stored locally): $e');
    }
  }
}
