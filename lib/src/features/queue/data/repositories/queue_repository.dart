import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:queue_management_system/src/core/database/database_helper.dart';
import 'package:queue_management_system/src/features/queue/domain/models/person_details.dart';

class QueueRepository {
  final DatabaseHelper _dbHelper;
  QueueRepository(this._dbHelper);

  Future<void> insertQueue(PersonDetails personDetails) async {
    final db = await _dbHelper.database;
    try {
      await db.insert(
        'queue_entries',
        personDetails.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Person inserted into queue_entries table");
    } catch (e) {
      print("Error inserting person: $e");
    }
  }

  Future<List<PersonDetails>> getQueue() async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('queue_entries');
      // print('QUEUE');
      print("Fetched ${maps.length} entries from queue_entries table");
      return maps.map((map) => PersonDetails.fromMap(map)).toList();
    } catch (e) {
      print("Error fetching queue: $e");
      return [];
    }
  }

  //Search for a person in the queue
  Future<List<PersonDetails>> searchQueue(String query) async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'queue_entries',
        where: 'full_name LIKE ? OR phone_number LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      print(
          "Fetched ${maps.length} entries from queue_entries table for query: $query");
      return maps.map((map) => PersonDetails.fromMap(map)).toList();
    } catch (e) {
      print("Error fetching queue: $e");
      return [];
    }
  }

  Future<void> removeFromQueue(String id) async {
    final db = await _dbHelper.database;
    try {
      await db.delete(
        'queue_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      print("Person with ID $id removed from queue_entries table");
    } catch (e) {
      print("Error removing person: $e");
    }
  }

  Future<PersonDetails?> getPersonDetails(int id) async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'queue_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return PersonDetails.fromMap(maps.first);
      }
    } catch (e) {
      print("Error fetching person details: $e");
    }
    return null;
  }

  Future<void> updatePersonDetails(PersonDetails personDetails) async {
    final db = await _dbHelper.database;
    try {
      await db.update(
        'queue_entries',
        personDetails.toMap(),
        where: 'id = ?',
        whereArgs: [personDetails.id],
      );
      print("Person details updated for ID ${personDetails.id}");
    } catch (e) {
      print("Error updating person details: $e");
    }
  }

  Future<void> markAsCompleted(String id) async {
    final db = await _dbHelper.database;
    final timestamps = DateTime.now().millisecondsSinceEpoch;

    try {
      await db.update(
        'queue_entries',
        {'CompletedAt': timestamps},
        where: 'id = ?',
        whereArgs: [id],
      );
      print(
          "Person with ID $id marked as completed with timestamp $timestamps");
    } catch (e) {
      print("Error marking person as completed: $e");
    }
  }
}

// add provider
final queueRepoProvider = Provider<QueueRepository>((ref) {
  final dbHelper = ref.watch(databaseProvider);
  return QueueRepository(dbHelper);
});
//search provider
final searchQueueProvider = FutureProvider.autoDispose
    .family<List<PersonDetails>, String>((ref, query) async {
  ref.onDispose(() => debugPrint('disposed: $query'));
  final link = ref.keepAlive();
  Timer(const Duration(seconds: 5), () {
    link.close();
  });
  final repo = ref.read(queueRepoProvider);
  return repo.searchQueue(query);
});
