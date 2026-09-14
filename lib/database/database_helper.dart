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
      version: 6,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ============================================================
  // CRIAÇÃO DO BANCO
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
    // TABELA FAMÍLIAS
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
    // TABELA MEMBROS DA FAMÍLIA
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
        bairro TEXT NOT NULL,
        capacidade INTEGER NOT NULL DEFAULT 100,
        ocupacao INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (cidade_id)
          REFERENCES cidades (id)
      )
    ''');

    // ==========================================================
    // TABELA USUÁRIOS
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
      await db.insert(
        'cidades',
        {'nome': nome},
      );
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
    // ==========================================================

    if (oldVersion < 2) {
      await db.insert(
        'cidades',
        {'nome': 'Ibirama'},
      );

      await db.insert(
        'cidades',
        {'nome': 'Apiúna'},
      );

      await db.insert(
        'cidades',
        {'nome': 'Pouso Redondo'},
      );

      await db.insert(
        'cidades',
        {'nome': 'Presidente Nereu'},
      );
    }

    // ==========================================================
    // VERSÃO 3
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

    // ==========================================================
    // VERSÃO 5
    // ==========================================================

    if (oldVersion < 5) {
      await db.execute(
        "ALTER TABLE lotacao ADD COLUMN bairro TEXT NOT NULL DEFAULT ''",
      );
    }

    // ==========================================================
    // VERSÃO 6
    // Capacidade máxima dos abrigos = 100
    //
    // Esta migração já rodou no passado pra deixar todo mundo
    // com 100 de capacidade. Mantida como está (histórico) — a
    // partir de agora a capacidade pode ser alterada pelo admin
    // através de salvarCapacidadeAbrigo, sem precisar de uma
    // nova migração.
    // ==========================================================

    if (oldVersion < 6) {
      await db.execute('''
        UPDATE lotacao
        SET capacidade = 100
      ''');
    }
  }

  // ============================================================
  // IDADE A PARTIR DA DATA DE NASCIMENTO
  // ============================================================

  int? calcularIdade(String? dataNascimento) {
    if (dataNascimento == null ||
        dataNascimento.trim().isEmpty) {
      return null;
    }

    try {
      final partes = dataNascimento.split('/');

      if (partes.length != 3) {
        return null;
      }

      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);

      final nascimento = DateTime(
        ano,
        mes,
        dia,
      );

      final hoje = DateTime.now();

      int idade = hoje.year - nascimento.year;

      final aniversarioJaPassouEsteAno =
          (hoje.month > nascimento.month) ||
          (hoje.month == nascimento.month &&
              hoje.day >= nascimento.day);

      if (!aniversarioJaPassouEsteAno) {
        idade--;
      }

      return idade < 0 ? null : idade;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // FAIXAS ETÁRIAS
  //
  // MANTIDA A ORDEM ORIGINAL DA LOTAÇÃO
  // ============================================================

  static const List<String> ordemFaixasEtarias = [
    'Até 2 anos',
    '3 a 9 anos',
    '10 a 12 anos',
    '13 a 17 anos',
    '18 a 59 anos',
    '60 anos ou mais',
  ];

  String faixaEtariaDe(int idade) {
    if (idade <= 2) {
      return 'Até 2 anos';
    }

    if (idade <= 9) {
      return '3 a 9 anos';
    }

    if (idade <= 12) {
      return '10 a 12 anos';
    }

    if (idade <= 17) {
      return '13 a 17 anos';
    }

    if (idade <= 59) {
      return '18 a 59 anos';
    }

    return '60 anos ou mais';
  }

  // ============================================================
  // BUSCAR TODAS AS IDADES DO ABRIGO
  //
  // Conta:
  // - idade do responsável;
  // - idade de cada membro da família.
  // ============================================================

  Future<List<int>> buscarIdadesPorBairro({
    required int cidadeId,
    required String bairro,
  }) async {
    final db = await database;

    final familias = await db.query(
      'familias',
      where: 'cidade_id = ? AND bairro = ?',
      whereArgs: [
        cidadeId,
        bairro,
      ],
    );

    final List<int> idades = [];

    for (final familia in familias) {
      // ========================================================
      // RESPONSÁVEL
      // ========================================================

      final idadeResponsavel = calcularIdade(
        familia['data_nascimento']?.toString(),
      );

      if (idadeResponsavel != null &&
          idadeResponsavel >= 0) {
        idades.add(idadeResponsavel);
      }

      // ========================================================
      // MEMBROS DA FAMÍLIA
      // ========================================================

      final familiaId = familia['id'];

      if (familiaId == null) {
        continue;
      }

      final membros = await db.query(
        'membros_familia',
        where: 'familia_id = ?',
        whereArgs: [familiaId],
      );

      for (final membro in membros) {
        final valorIdade = membro['idade'];

        if (valorIdade == null) {
          continue;
        }

        int? idadeMembro;

        if (valorIdade is int) {
          idadeMembro = valorIdade;
        } else {
          idadeMembro = int.tryParse(
            valorIdade.toString(),
          );
        }

        if (idadeMembro != null &&
            idadeMembro >= 0) {
          idades.add(idadeMembro);
        }
      }
    }

    return idades;
  }

  // ============================================================
  // CAPACIDADE DO ABRIGO
  //
  // Retorna a capacidade realmente salva na tabela 'lotacao'
  // pra essa cidade/bairro. Se ainda não existe nenhum registro
  // (abrigo nunca teve a capacidade alterada), usa 100 como
  // padrão, sem gravar nada ainda.
  // ============================================================

  Future<int> buscarCapacidadeAbrigo({
    required int cidadeId,
    required String bairro,
  }) async {
    final db = await database;

    final resultado = await db.query(
      'lotacao',
      where: 'cidade_id = ? AND bairro = ?',
      whereArgs: [
        cidadeId,
        bairro,
      ],
    );

    if (resultado.isEmpty) {
      return 100;
    }

    final capacidadeSalva = resultado.first['capacidade'];

    if (capacidadeSalva is int) {
      return capacidadeSalva;
    }

    return int.tryParse(
          capacidadeSalva.toString(),
        ) ??
        100;
  }

  // ============================================================
  // SALVAR CAPACIDADE
  //
  // Grava a capacidade informada (não mais um valor fixo).
  // ============================================================

  Future<void> salvarCapacidadeAbrigo({
    required int cidadeId,
    required String bairro,
    required int capacidade,
  }) async {
    final db = await database;

    final existente = await db.query(
      'lotacao',
      where: 'cidade_id = ? AND bairro = ?',
      whereArgs: [
        cidadeId,
        bairro,
      ],
    );

    if (existente.isEmpty) {
      await db.insert(
        'lotacao',
        {
          'cidade_id': cidadeId,
          'bairro': bairro,
          'capacidade': capacidade,
          'ocupacao': 0,
        },
      );
    } else {
      await db.update(
        'lotacao',
        {
          'capacidade': capacidade,
        },
        where: 'cidade_id = ? AND bairro = ?',
        whereArgs: [
          cidadeId,
          bairro,
        ],
      );
    }
  }

  // ============================================================
  // LISTA DE ABRIGOS
  // ============================================================

  Future<List<String>> buscarBairrosComLotacao(
    int cidadeId,
  ) async {
    final db = await database;

    final resultado = await db.rawQuery(
      '''
      SELECT DISTINCT bairro
      FROM lotacao
      WHERE cidade_id = ?
      ORDER BY bairro
      ''',
      [cidadeId],
    );

    return resultado
        .map(
          (linha) => linha['bairro'] as String,
        )
        .where(
          (bairro) => bairro.isNotEmpty,
        )
        .toList();
  }

  // ============================================================
  // LOTAÇÃO COMPLETA DO ABRIGO
  // ============================================================

  Future<LotacaoInfo> buscarLotacao({
    required int cidadeId,
    required String bairro,
  }) async {
    // Busca novamente todas as idades cadastradas.
    final idades = await buscarIdadesPorBairro(
      cidadeId: cidadeId,
      bairro: bairro,
    );

    // Começa todas as faixas com zero.
    final Map<String, int> contagem = {
      for (final faixa in ordemFaixasEtarias)
        faixa: 0,
    };

    // Coloca cada idade na faixa correspondente.
    for (final idade in idades) {
      final faixa = faixaEtariaDe(idade);

      contagem[faixa] =
          (contagem[faixa] ?? 0) + 1;
    }

    // Capacidade máxima: usa o valor salvo pra esse abrigo,
    // ou o padrão de 100 caso ainda não tenha sido definido.
    final capacidade = await buscarCapacidadeAbrigo(
      cidadeId: cidadeId,
      bairro: bairro,
    );

    // Quantidade real de pessoas.
    final ocupacao = idades.length;

    return LotacaoInfo(
      capacidade: capacidade,
      ocupacao: ocupacao,
      porFaixaEtaria: contagem,
    );
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

// ================================================================
// MODELO DA LOTAÇÃO
// ================================================================

class LotacaoInfo {
  final int capacidade;
  final int ocupacao;
  final Map<String, int> porFaixaEtaria;

  LotacaoInfo({
    required this.capacidade,
    required this.ocupacao,
    required this.porFaixaEtaria,
  });

  int get vagasDisponiveis {
    final vagas = capacidade - ocupacao;

    return vagas < 0 ? 0 : vagas;
  }
}