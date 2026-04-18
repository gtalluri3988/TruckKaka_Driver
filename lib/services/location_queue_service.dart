import 'dart:developer';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/location_model.dart';

/// SQLite-backed offline queue for GPS location points.
/// Points are enqueued immediately from the GPS stream and
/// dequeued in batches for HTTP upload when network is available.
class LocationQueueService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'tracking_queue.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE location_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL,
            lat REAL NOT NULL,
            lng REAL NOT NULL,
            accuracy REAL,
            speed REAL,
            heading REAL,
            altitude REAL,
            battery INTEGER,
            is_gps_enabled INTEGER DEFAULT 1,
            is_mock INTEGER DEFAULT 0,
            recorded_at TEXT NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_queue_synced ON location_queue (synced)
        ''');
      },
    );
  }

  /// Enqueue a single location point.
  static Future<void> enqueue(LocationPoint point) async {
    try {
      final db = await database;
      final id = await db.insert('location_queue', point.toDbRow());
      // ignore: avoid_print
      print('LocationQueue: enqueued point id=$id lat=${point.latitude} lng=${point.longitude}');
    } catch (e) {
      // ignore: avoid_print
      print('LocationQueue enqueue error: $e');
    }
  }

  /// Get a batch of unsynced points, ordered oldest first.
  static Future<List<LocationPoint>> getUnsyncedBatch(int limit) async {
    try {
      final db = await database;
      final rows = await db.query(
        'location_queue',
        where: 'synced = 0',
        orderBy: 'recorded_at ASC',
        limit: limit,
      );
      return rows.map((r) => LocationPoint.fromDbRow(r)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('LocationQueue getUnsyncedBatch error: $e');
      return [];
    }
  }

  /// Mark specific points as synced.
  static Future<void> markSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      final db = await database;
      final placeholders = ids.map((_) => '?').join(',');
      await db.rawUpdate(
        'UPDATE location_queue SET synced = 1 WHERE id IN ($placeholders)',
        ids,
      );
    } catch (e) {
      // ignore: avoid_print
      print('LocationQueue markSynced error: $e');
    }
  }

  /// Delete synced points older than the given duration (default 24 hours).
  static Future<void> cleanup({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final db = await database;
      final cutoff =
          DateTime.now().toUtc().subtract(maxAge).toIso8601String();
      await db.delete(
        'location_queue',
        where: 'synced = 1 AND recorded_at < ?',
        whereArgs: [cutoff],
      );
    } catch (e) {
      // ignore: avoid_print
      print('LocationQueue cleanup error: $e');
    }
  }

  /// Count of unsynced points waiting to be uploaded.
  static Future<int> pendingCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM location_queue WHERE synced = 0',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      // ignore: avoid_print
      print('LocationQueue pendingCount error: $e');
      return 0;
    }
  }

  /// Close the database (call on app termination if needed).
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
