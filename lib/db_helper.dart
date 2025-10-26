import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class DBHelper {
  static Database? _englishDb;
  static Database? _banglaDb;

  // ✅ Load English Database
  static Future<Database> getEnglishDb() async {
    if (_englishDb != null) return _englishDb!;
    _englishDb = await _loadDb("assets/english_words.db");
    return _englishDb!;
  }

  // ✅ Load Bangla Database
  static Future<Database> getBanglaDb() async {
    if (_banglaDb != null) return _banglaDb!;
    _banglaDb = await _loadDb("assets/bangla_words.db");
    return _banglaDb!;
  }

  // ✅ Copy DB from assets if not exists
  static Future<Database> _loadDb(String assetPath) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, basename(assetPath));

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }
    final db = await openDatabase(path, readOnly: true);
    return db;
  }

  /// ✅ English → Bangla
  static Future<String?> getEnglishWordDetails(String word) async {
    try {
      final db = await getEnglishDb();
      final cleanedWord = word.trim().toLowerCase();
      final result = await db.query(
        'words',
        where: 'LOWER(word) = ?',
        whereArgs: [cleanedWord],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final row = result.first;
        return "Meaning: ${row['meaning'] ?? '-'}\n"
            "Part of Speech: ${row['part_of_speech'] ?? '-'}\n"
            "Example: ${row['example'] ?? '-'}";
      }
      return null;
    } catch (e) {
      debugPrint("❌ English DB Error: $e");
      return null;
    }
  }

  /// ✅ Bangla → English
  static Future<String?> getBanglaWordDetails(String word) async {
    try {
      final db = await getBanglaDb();
      final cleanedWord = word.trim();

      final result = await db.query(
        'words',
        where: 'word LIKE ?',
        whereArgs: ['$cleanedWord%'],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final row = result.first;
        return "অর্থ: ${row['meaning'] ?? '-'}\n"
            "শব্দের প্রকার: ${row['part_of_speech'] ?? '-'}\n"
            "উদাহরণ: ${row['example'] ?? '-'}";
      }
      return null;
    } catch (e) {
      debugPrint("❌ Bangla DB Error: $e");
      return null;
    }
  }

  /// ✅ English Suggestions
  static Future<List<String>> getMatchingEnglishWords(String query) async {
    if (query.isEmpty) return [];
    try {
      final db = await getEnglishDb();
      final result = await db.query(
        'words',
        columns: ['word'],
        where: 'LOWER(word) LIKE ?',
        whereArgs: ['${query.toLowerCase()}%'],
        orderBy: 'word ASC',
        limit: 20,
      );
      return result.map((e) => e['word'].toString()).toList();
    } catch (e) {
      debugPrint("❌ English Suggestion Error: $e");
      return [];
    }
  }

  /// ✅ Bangla Suggestions
  static Future<List<String>> getMatchingBanglaWords(String query) async {
    if (query.isEmpty) return [];
    try {
      final db = await getBanglaDb();
      final result = await db.query(
        'words',
        columns: ['word'],
        where: 'word LIKE ?',
        whereArgs: ['$query%'],
        orderBy: 'word ASC',
        limit: 20,
      );
      return result.map((e) => e['word'].toString()).toList();
    } catch (e) {
      debugPrint("❌ Bangla Suggestion Error: $e");
      return [];
    }
  }
}
