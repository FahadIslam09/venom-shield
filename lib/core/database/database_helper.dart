import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../features/hospital/models/hospital.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('venonshield.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE hospitals (
        id $idType,
        name_bn $textType,
        name_en $textType,
        district $textType,
        upazila $textType,
        lat $doubleType,
        lng $doubleType,
        phone $textType,
        type $textType,
        antivenom_status $textType,
        has_emergency $boolType
      )
    ''');

    await _seedDatabase(db);
  }

  Future _seedDatabase(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/hospitals.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final batch = db.batch();
      for (var item in jsonList) {
        batch.insert('hospitals', {
          'id': item['id'],
          'name_bn': item['name_bn'],
          'name_en': item['name_en'],
          'district': item['district'] ?? '',
          'upazila': item['upazila'] ?? '',
          'lat': (item['lat'] as num).toDouble(),
          'lng': (item['lng'] as num).toDouble(),
          'phone': item['phone'] ?? '',
          'type': item['type'] ?? 'general',
          'antivenom_status': item['antivenom_status'] ?? 'out_of_stock',
          'has_emergency': (item['has_emergency'] == false) ? 0 : 1,
        });
      }
      await batch.commit(noResult: true);
    } catch (e) {
      // ponytail: print error on seeding, fail silently in production since we want to run
      print('Database seeding failed: $e');
    }
  }

  Future<List<Hospital>> getHospitals() async {
    final db = await instance.database;
    final result = await db.query('hospitals');
    return result.map((json) => Hospital.fromJson(json)).toList();
  }

  Future<List<Hospital>> getNearestHospitals(double userLat, double userLng, {int limit = 10}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('hospitals');
    
    final List<Hospital> hospitals = maps.map((json) => Hospital.fromJson(json)).toList();
    
    // Sort by Haversine distance in memory (simplest correct option for local db without spatial extensions)
    // ponytail: memory sorting, fine for < 1000 items
    hospitals.sort((a, b) {
      double distA = _calculateDistance(userLat, userLng, a.lat, a.lng);
      double distB = _calculateDistance(userLat, userLng, b.lat, b.lng);
      return distA.compareTo(distB);
    });

    return hospitals.take(limit).toList();
  }

  Future<int> updateAntivenomStock(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'hospitals',
      {'antivenom_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Standard Haversine distance formula (in km)
    // ponytail: native trigonometric calc, accurate for geo-sorting
    final double p = 0.017453292519943295; // math.pi / 180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }
}
