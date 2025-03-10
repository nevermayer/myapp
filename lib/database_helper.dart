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
  final String? dn;
  final String? pn;
  final String? medidatorquimetro;
  final String? valvula;
  final String? colada;
  final String? material;
  final String? recubrimientoB1;
  final String? recubrimientoB2;
  final String? observaciones;

  Valvula({    this.id,
    required this.nombre,
    required this.camaraId,
    this.dn,
    this.pn,
    this.medidatorquimetro,
    this.valvula,
    this.colada,
    this.material,
    this.recubrimientoB1,
    this.recubrimientoB2,
    this.observaciones,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'camaraId': camaraId,
      'dn': dn,
      'pn': pn,
      'medidatorquimetro': medidatorquimetro,
      'valvula': valvula,
      'colada': colada,
      'material': material,
      'recubrimientoB1': recubrimientoB1,
      'recubrimientoB2': recubrimientoB2,
      'observaciones': observaciones,
      };
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
    return await openDatabase(path, version: 2, onUpgrade: _onUpgrade, onCreate: _onCreate);
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN dn TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN pn TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN medidatorquimetro TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN valvula TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN colada TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN material TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN recubrimientoB1 TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN recubrimientoB2 TEXT');
      await db.execute(
          'ALTER TABLE valvulas ADD COLUMN observaciones TEXT');
    }
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE tramos(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT)');
    await db.execute(
        'CREATE TABLE camaras(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, tramoId INTEGER, FOREIGN KEY(tramoId) REFERENCES tramos(id))');
    await db.execute(
        'CREATE TABLE valvulas(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, camaraId INTEGER, dn TEXT, pn TEXT, medidatorquimetro TEXT, valvula TEXT, colada TEXT, material TEXT, recubrimientoB1 TEXT, recubrimientoB2 TEXT, observaciones TEXT, FOREIGN KEY(camaraId) REFERENCES camaras(id))');
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
        dn: maps[i]['dn'],
        pn: maps[i]['pn'],
        medidatorquimetro: maps[i]['medidatorquimetro'],
        valvula: maps[i]['valvula'],
        colada: maps[i]['colada'],
        material: maps[i]['material'],
        recubrimientoB1: maps[i]['recubrimientoB1'],
        recubrimientoB2: maps[i]['recubrimientoB2'],
        observaciones: maps[i]['observaciones'],
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
