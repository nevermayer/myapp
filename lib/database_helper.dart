import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Tramo {
  final int? id;
  final String nombre;

  Tramo({this.id, required this.nombre});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre};
  }
}

class Camara {
  final int? id;
  final String nombre;
  final int tramoId;

  Camara({this.id, required this.nombre, required this.tramoId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'tramoId': tramoId};
  }
}

class Valvula {
  final int? id;
  final String nombre;
  final int camaraId;

  Valvula({this.id, required this.nombre, required this.camaraId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'camaraId': camaraId};
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE tramos(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT)',
    );
    await db.execute(
      'CREATE TABLE camaras(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, tramoId INTEGER, FOREIGN KEY(tramoId) REFERENCES tramos(id))',
    );
    await db.execute(
      'CREATE TABLE valvulas(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, camaraId INTEGER, FOREIGN KEY(camaraId) REFERENCES camaras(id))',
    );
  }

  Future<List<Tramo>> getTramos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tramos');
    return List.generate(maps.length, (i) {
      return Tramo(id: maps[i]['id'], nombre: maps[i]['nombre']);
    });
  }

  Future<void> insertTramo(Tramo tramo) async {
    final db = await database;
    await db.insert(
      'tramos',
      tramo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTramo(Tramo tramo) async {
    final db = await database;
    await db.update(
      'tramos',
      tramo.toMap(),
      where: 'id = ?',
      whereArgs: [tramo.id],
    );
  }

  Future<void> deleteTramo(int id) async {
    final db = await database;
    await db.delete('tramos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Camara>> getCamaras(int tramoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'camaras',
      where: 'tramoId = ?',
      whereArgs: [tramoId],
    );
    return List.generate(maps.length, (i) {
      return Camara(
        id: maps[i]['id'],
        nombre: maps[i]['nombre'],
        tramoId: maps[i]['tramoId'],
      );
    });
  }

  Future<void> insertCamara(Camara camara) async {
    final db = await database;
    await db.insert(
      'camaras',
      camara.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCamara(Camara camara) async {
    final db = await database;
    await db.update(
      'camaras',
      camara.toMap(),
      where: 'id = ?',
      whereArgs: [camara.id],
    );
  }

  Future<void> deleteCamara(int id) async {
    final db = await database;
    await db.delete('camaras', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Valvula>> getValvulas(int camaraId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'valvulas',
      where: 'camaraId = ?',
      whereArgs: [camaraId],
    );
    return List.generate(maps.length, (i) {
      return Valvula(
        id: maps[i]['id'],
        nombre: maps[i]['nombre'],
        camaraId: maps[i]['camaraId'],
      );
    });
  }

  Future<void> insertValvula(Valvula valvula) async {
    final db = await database;
    await db.insert(
      'valvulas',
      valvula.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void> updateValvula(Valvula valvula) async {
    final db = await database;
    await db.update(
      'valvulas',
      valvula.toMap(),
      where: 'id = ?',
      whereArgs: [valvula.id],
    );
  }

  Future<void> deleteValvula(int id) async {
    final db = await database;
    await db.delete('valvulas', where: 'id = ?', whereArgs: [id]);
  }
}
