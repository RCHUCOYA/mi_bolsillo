import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movimiento_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mibolsillo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        monto REAL NOT NULL,
        categoria TEXT NOT NULL,
        fecha TEXT NOT NULL,
        tipo TEXT NOT NULL,
        notas TEXT
      )
    ''');
  }

  Future<int> insertMovimiento(Movimiento m) async {
    final db = await database;
    return await db.insert(
      'movimientos',
      m.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Movimiento>> getAllMovimientos() async {
    final db = await database;
    final maps = await db.query(
      'movimientos',
      orderBy: 'fecha DESC, id DESC',
    );
    return maps.map((m) => Movimiento.fromMap(m)).toList();
  }

  Future<List<Movimiento>> getMovimientosFiltrados({
    String? tipo,
    String? categoria,
  }) async {
    final db = await database;

    final conditions = <String>[];
    final args = <dynamic>[];

    if (tipo != null && tipo.isNotEmpty) {
      conditions.add('tipo = ?');
      args.add(tipo);
    }
    if (categoria != null && categoria.isNotEmpty) {
      conditions.add('categoria = ?');
      args.add(categoria);
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final maps = await db.query(
      'movimientos',
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'fecha DESC, id DESC',
    );

    return maps.map((m) => Movimiento.fromMap(m)).toList();
  }

  Future<int> updateMovimiento(Movimiento m) async {
    final db = await database;
    return await db.update(
      'movimientos',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  Future<int> deleteMovimiento(int id) async {
    final db = await database;
    return await db.delete(
      'movimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalByTipo(String tipo) async {
    final db = await database;
    final now = DateTime.now();
    final mesActual =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-%';

    final result = await db.rawQuery(
      'SELECT SUM(monto) as total FROM movimientos WHERE tipo = ? AND fecha LIKE ?',
      [tipo, mesActual],
    );

    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getTotalesPorCategoria() async {
    final db = await database;
    final now = DateTime.now();
    final mesActual =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-%';

    final result = await db.rawQuery(
      '''
      SELECT categoria, SUM(monto) as total
      FROM movimientos
      WHERE fecha LIKE ?
      GROUP BY categoria
      ''',
      [mesActual],
    );

    final Map<String, double> totales = {};
    for (final row in result) {
      totales[row['categoria'] as String] =
          (row['total'] as num).toDouble();
    }
    return totales;
  }
}
