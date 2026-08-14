import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'ffi_init.dart';
import '../utils/local_storage.dart';
import '../../features/hospital/models/hospital.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database access not supported on Web. Use local storage cache instead.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('venonshield.db');
    // Ensure the assessments table exists (schema migration)
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        venomous INTEGER NOT NULL,
        risk_percentage REAL NOT NULL,
        risk_level TEXT NOT NULL,
        matched_species TEXT,
        symptoms TEXT
      )
    ''');
    // Ensure settings table exists
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Ensure hospitals table exists (schema migration)
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS hospitals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_bn TEXT NOT NULL,
        name_en TEXT NOT NULL,
        district TEXT NOT NULL,
        upazila TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        phone TEXT NOT NULL,
        type TEXT NOT NULL,
        antivenom_status TEXT NOT NULL,
        has_emergency INTEGER NOT NULL
      )
    ''');

    // Seed hospitals table if it is currently empty
    final countResult = Sqflite.firstIntValue(await _database!.rawQuery('SELECT COUNT(*) FROM hospitals'));
    if (countResult == 0) {
      await _seedDatabase(_database!);
    }

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb) {
      initFfiDatabase();
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
      CREATE TABLE assessments (
        id $idType,
        timestamp $textType,
        type $textType,
        venomous $boolType,
        risk_percentage $doubleType,
        risk_level $textType,
        matched_species TEXT,
        symptoms TEXT
      )
    ''');

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

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
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

  List<Hospital>? _webHospitalsCache;

  Future<List<Hospital>> _loadWebHospitals() async {
    if (_webHospitalsCache != null) return _webHospitalsCache!;
    try {
      final String jsonString = await rootBundle.loadString('assets/data/hospitals.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _webHospitalsCache = jsonList.map((e) => Hospital.fromJson(e)).toList();
      return _webHospitalsCache!;
    } catch (e) {
      print('Failed to load web hospitals: $e');
      return [];
    }
  }

  Future<List<Hospital>> getHospitals() async {
    if (kIsWeb) {
      return await _loadWebHospitals();
    }
    final db = await instance.database;
    final result = await db.query('hospitals');
    return result.map((json) => Hospital.fromJson(json)).toList();
  }

  Future<List<Hospital>> getNearestHospitals(double userLat, double userLng, {int limit = 10}) async {
    List<Hospital> hospitals;
    if (kIsWeb) {
      hospitals = await _loadWebHospitals();
    } else {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('hospitals');
      hospitals = maps.map((json) => Hospital.fromJson(json)).toList();
    }
    
    final sortedHospitals = List<Hospital>.from(hospitals);
    // Sort by Haversine distance in memory (simplest correct option for local db without spatial extensions)
    // ponytail: memory sorting, fine for < 1000 items
    sortedHospitals.sort((a, b) {
      double distA = _calculateDistance(userLat, userLng, a.lat, a.lng);
      double distB = _calculateDistance(userLat, userLng, b.lat, b.lng);
      return distA.compareTo(distB);
    });

    return sortedHospitals.take(limit).toList();
  }

  Future<int> updateAntivenomStock(int id, String status) async {
    if (kIsWeb) {
      final list = await _loadWebHospitals();
      final idx = list.indexWhere((h) => h.id == id);
      if (idx != -1) {
        final old = list[idx];
        list[idx] = Hospital(
          id: old.id,
          nameBn: old.nameBn,
          nameEn: old.nameEn,
          district: old.district,
          upazila: old.upazila,
          lat: old.lat,
          lng: old.lng,
          phone: old.phone,
          type: old.type,
          antivenomStatus: status,
          hasEmergency: old.hasEmergency,
        );
        return 1;
      }
      return 0;
    }
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

  // Save assessments in local database history
  Future<int> saveAssessment({
    required String type,
    required bool venomous,
    required double riskPercentage,
    required String riskLevel,
    String? matchedSpecies,
    List<String> symptoms = const [],
  }) async {
    final item = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'venomous': venomous ? 1 : 0,
      'risk_percentage': riskPercentage,
      'risk_level': riskLevel,
      'matched_species': matchedSpecies,
      'symptoms': json.encode(symptoms),
    };

    if (kIsWeb) {
      try {
        final list = await _getWebAssessments();
        item['id'] = list.length + 1;
        list.add(item);
        _webAssessmentsCache = list;
        WebLocalStorage.save('assessments_history', json.encode(list));
        return 1;
      } catch (e) {
        print('Web save assessment failed: $e');
        return 0;
      }
    }

    final db = await instance.database;
    return await db.insert('assessments', item);
  }

  List<Map<String, dynamic>>? _webAssessmentsCache;
  Future<List<Map<String, dynamic>>> _getWebAssessments() async {
    if (_webAssessmentsCache != null) return _webAssessmentsCache!;
    try {
      final data = WebLocalStorage.load('assessments_history');
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _webAssessmentsCache = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _webAssessmentsCache = [];
      }
    } catch (e) {
      print('Failed to load web assessments history: $e');
      _webAssessmentsCache = [];
    }
    return _webAssessmentsCache!;
  }

  // Fetch all assessments from history
  Future<List<Map<String, dynamic>>> getAssessments() async {
    if (kIsWeb) {
      final list = await _getWebAssessments();
      final sortedList = List<Map<String, dynamic>>.from(list);
      sortedList.sort((a, b) {
        final String tA = a['timestamp'] ?? '';
        final String tB = b['timestamp'] ?? '';
        return tB.compareTo(tA);
      });
      return sortedList;
    }
    final db = await instance.database;
    return await db.query('assessments', orderBy: 'timestamp DESC');
  }

  Future<void> saveSetting(String key, String value) async {
    if (kIsWeb) {
      WebLocalStorage.save(key, value);
      return;
    }
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    if (kIsWeb) {
      return WebLocalStorage.load(key);
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }
}
