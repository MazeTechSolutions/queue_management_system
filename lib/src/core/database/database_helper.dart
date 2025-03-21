import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'queue_management.db'),
      version: 4, // Updated version
      onCreate: (db, version) async {
        // Create `admin` table
        await db.execute('''
          CREATE TABLE admin( 
            id TEXT PRIMARY KEY, 
            email TEXT NOT NULL, 
            password TEXT NOT NULL, 
            is_logged_in BOOLEAN DEFAULT FALSE 
          ) 
        ''');

        // Create `queue_entries` table
        await db.execute('''
          CREATE TABLE queue_entries( 
            id TEXT PRIMARY KEY, 
            full_name TEXT NOT NULL, 
            phone_number TEXT NOT NULL, 
            queue_number INTEGER NOT NULL, 
            timestamp INTEGER NOT NULL, 
            notes TEXT, 
            added_by TEXT NOT NULL DEFAULT "unknown", 
            completedAt INTEGER DEFAULT NULL -- Allow NULL for completedAt
          ) 
        ''');

        // Add indexes for faster queries
        await db.execute(
            'CREATE INDEX idx_queue_timestamp ON queue_entries(timestamp)');
        await db.execute(
            'CREATE INDEX idx_queue_completedAt ON queue_entries(completedAt)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE admin ADD COLUMN is_logged_in BOOLEAN DEFAULT FALSE',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE queue_entries ADD COLUMN added_by TEXT NOT NULL DEFAULT "unknown"',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE queue_entries ADD COLUMN completedAt INTEGER DEFAULT NULL',
          );
        }

        // Ensure indexes are created during upgrades
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_queue_timestamp ON queue_entries(timestamp)');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_queue_completedAt ON queue_entries(completedAt)');
      },
    );
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
}

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
