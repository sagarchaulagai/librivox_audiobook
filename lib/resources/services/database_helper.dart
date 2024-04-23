import 'dart:async';
import 'dart:io';

import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:librivox_audiobook/resources/models/audiobook_file.dart';
import 'package:librivox_audiobook/resources/models/played_audiobook.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const dbName = 'myDatabase.db';
  static const dbVersion = 1;
  static const tableName = 'PlayedAudiobooks';

  static const columnIdentifier = 'identifier';
  static const columnCurrentIndex = 'currentIndex';
  static const columnCurrentPosition = 'currentPosition';
  static const columnAudiobook = 'audiobook';
  static const columnAudiobookFiles = 'audiobookFiles';

  static final DatabaseHelper instance = DatabaseHelper();
  final _controller = StreamController.broadcast();

  static Database? _database;

  Stream get onUpdate => _controller.stream;

  Future<Database?> get database async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, dbName);
    return await openDatabase(path, version: dbVersion, onCreate: onCreate);
  }

  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnIdentifier TEXT PRIMARY KEY,
        $columnCurrentIndex INTEGER,
        $columnCurrentPosition INTEGER,
        $columnAudiobook TEXT,
        $columnAudiobookFiles TEXT
      )
    ''');
  }

  Future<int> insertRecord(Map<String, Object?> row) async {
    Database? db = await instance.database;
    return await db!.insert(tableName, row);
  }

  Future<List<Map<String, Object?>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(tableName);
  }

  Future<int> updateRecord(Map<String, Object?> row) async {
    Database? db = await instance.database;
    return await db!.update(
      tableName,
      row,
      where: '$columnIdentifier = ?',
      whereArgs: [row[columnIdentifier]],
    );
  }

  Future<int> deleteRecord(String identifier) async {
    Database? db = await instance.database;
    return await db!.delete(
      tableName,
      where: '$columnIdentifier = ?',
      whereArgs: [identifier],
    );
  }

  Future<void> updateCurrentIndexFromIdentifier(
      String identifier, int currentIndex) async {
    Map<String, Object?> row = {
      columnIdentifier: identifier,
      columnCurrentIndex: currentIndex,
    };
    await updateRecord(row);
    _controller.add(row);
  }

  Future<List<dynamic>> getPlayedAudiobooks() async {
    List<Map<String, Object?>> rows = await queryAllRows();
    List<PlayedAudiobook> playedAudiobooks =
        rows.map((row) => PlayedAudiobook.fromMap(row)).toList();
    List<Audiobook> audiobooks = playedAudiobooks
        .map((playedAudiobook) => playedAudiobook.audiobook)
        .toList();
    List<List<AudiobookFile>> audiobookFiles = playedAudiobooks
        .map((playedAudiobook) => playedAudiobook.audiobookFiles)
        .toList();
    return [audiobooks, audiobookFiles];
  }

  void dispose() {
    _controller.close();
  }
}
