import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'favorites.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY, recipe TEXT)',
        );
      },
    );
  }

  Future<void> insertFavorite(String recipe) async {
    final db = await database;
    await db.insert('favorites', {'recipe': recipe});
  }

  Future<void> deleteFavorite(String recipe) async {
    final db = await database;
    await db.delete('favorites', where: 'recipe = ?', whereArgs: [recipe]);
  }

  Future<List<String>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return maps[i]['recipe'];
    });
  }
}