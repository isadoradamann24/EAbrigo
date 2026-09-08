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

      // A versão foi alterada de 3 para 4
      version: 4,

      // Executado quando o banco é criado pela primeira vez
      onCreate: _createDB,

      // Executado quando atualizamos a versão do banco
      onUpgrade: _onUpgrade,
    );
  }

  // ============================================================
  // CRIAÇÃO DO BANCO (instalação nova, já com todas as colunas)
  // ============================================================

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    // ==========================================================
    // TABELA CIDADES
    // ==========================================================

    await db.execute('''
      CREATE TABLE cidades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');

    // ==========================================================
    // TABELA FAMÍLIAS (já com os campos do novo formulário)
    // ==========================================================

    await db.execute('''
      CREATE TABLE familias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cidade_id INTEGER NOT NULL,
        responsavel TEXT NOT NULL,
        bairro TEXT,
        endereco TEXT,
        telefone TEXT,
        data_cadastro TEXT,
        data_nascimento TEXT,
        nacionalidade TEXT,
        cpf TEXT,
        etnia TEXT,
        identidade_genero TEXT,
        situacao_trabalho TEXT,
        renda_mensal TEXT,
        cadastro_unico TEXT,
        recebe_beneficio_assistencia TEXT,
        qual_beneficio_assistencia TEXT,
        qual_beneficio_assistencia_outro TEXT,
        aposentado_pensionista TEXT,
        qual_aposentado_pensionista TEXT,
        qual_aposentado_pensionista_outro TEXT,
        possui_comorbidade TEXT,
        qual_comorbidade TEXT,
        uso_medicacao_continuo TEXT,
        qual_medicacao TEXT,
        possui_deficiencia TEXT,
        qual_deficiencia TEXT,
        houve_perdas_materiais TEXT,
        quais_perdas_materiais TEXT,
        houve_perda_documentacao TEXT,
        quais_documentos_perdidos TEXT,
        obs TEXT,
        FOREIGN KEY (cidade_id)
          REFERENCES cidades (id)
      )
    ''');

    // ==========================================================
    // TABELA MEMBROS DA FAMÍLIA (Composição Familiar)
    // ==========================================================

    await db.execute('''
      CREATE TABLE membros_familia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        familia_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        idade INTEGER,
        parentesco TEXT,
        escolaridade TEXT,
        identidade_genero TEXT,
        FOREIGN KEY (familia_id)
          REFERENCES familias (id)
          ON DELETE CASCADE
      )
    ''');

    // ==========================================================
    // TABELA LOTAÇÃO
    // ==========================================================

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

    // ==========================================================
    // TABELA USUÁRIOS (login / cadastro de administrador)
    // ==========================================================

    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        email TEXT,
        cpf TEXT,
        telefone TEXT,
        senha_hash TEXT NOT NULL
      )
    ''');

    // ==========================================================
    // CIDADES INICIAIS
    // ==========================================================

    const cidadesIniciais = [
      'Agronômica',
      'Ituporanga',
      'José Boiteux',
      'Laurentino',
      'Lontras',
      'Presidente Getúlio',
      'Rio do Campo',
      'Rio do Sul',
      'Taió',
      'Ibirama',
      'Apiúna',
      'Pouso Redondo',
      'Presidente Nereu',
    ];

    for (final nome in cidadesIniciais) {
      await db.insert('cidades', {'nome': nome});
    }
  }

  // ============================================================
  // ATUALIZAÇÃO DO BANCO
  // ============================================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ==========================================================
    // VERSÃO 2
    // Adiciona novas cidades sem apagar os dados existentes
    // ==========================================================

    if (oldVersion < 2) {
      await db.insert('cidades', {'nome': 'Ibirama'});
      await db.insert('cidades', {'nome': 'Apiúna'});
      await db.insert('cidades', {'nome': 'Pouso Redondo'});
      await db.insert('cidades', {'nome': 'Presidente Nereu'});
    }

    // ==========================================================
    // VERSÃO 3
    // Adiciona as colunas do novo formulário de cadastro,
    // sem apagar nenhum dado existente (ALTER TABLE ADD COLUMN)
    // ==========================================================

    if (oldVersion < 3) {
      final novasColunasFamilias = <String>[
        'data_nascimento',
        'nacionalidade',
        'cpf',
        'etnia',
        'identidade_genero',
        'situacao_trabalho',
        'renda_mensal',
        'cadastro_unico',
        'recebe_beneficio_assistencia',
        'qual_beneficio_assistencia',
        'qual_beneficio_assistencia_outro',
        'aposentado_pensionista',
        'qual_aposentado_pensionista',
        'qual_aposentado_pensionista_outro',
        'possui_comorbidade',
        'qual_comorbidade',
        'uso_medicacao_continuo',
        'qual_medicacao',
        'possui_deficiencia',
        'qual_deficiencia',
        'houve_perdas_materiais',
        'quais_perdas_materiais',
        'houve_perda_documentacao',
        'quais_documentos_perdidos',
        'obs',
      ];

      for (final coluna in novasColunasFamilias) {
        await db.execute(
          'ALTER TABLE familias ADD COLUMN $coluna TEXT',
        );
      }

      await db.execute(
        'ALTER TABLE membros_familia ADD COLUMN escolaridade TEXT',
      );

      await db.execute(
        'ALTER TABLE membros_familia ADD COLUMN identidade_genero TEXT',
      );
    }

    // ==========================================================
    // VERSÃO 4
    // Cria a tabela de usuários (login / cadastro de administrador)
    // ==========================================================

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          usuario TEXT NOT NULL UNIQUE,
          email TEXT,
          cpf TEXT,
          telefone TEXT,
          senha_hash TEXT NOT NULL
        )
      ''');
    }
  }

  // ============================================================
  // FECHAR BANCO
  // ============================================================

  Future<void> close() async {
    final db = await instance.database;

    await db.close();

    _database = null;
  }
}