import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('eabrigo.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE cidades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE familias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cidade_id INTEGER NOT NULL,
        responsavel TEXT NOT NULL,
        bairro TEXT,
        endereco TEXT,
        telefone TEXT,
        data_cadastro TEXT,
        FOREIGN KEY (cidade_id)
          REFERENCES cidades (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE membros_familia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        familia_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        idade INTEGER,
        parentesco TEXT,
        FOREIGN KEY (familia_id)
          REFERENCES familias (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE lotacao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cidade_id INTEGER NOT NULL,
        capacidade INTEGER NOT NULL,
        ocupacao INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (cidade_id)
          REFERENCES cidades (id)
      )
    ''');

    await db.insert('cidades', {
      'nome': 'Rio do Sul',
    });

    await db.insert('cidades', {
      'nome': 'Laurentino',
    });

    await db.insert('cidades', {
      'nome': 'Lontras',
    });
  }

  Future<void> close() async {
    final db = await instance.database;

    await db.close();

    _database = null;
  }
}