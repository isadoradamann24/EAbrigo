import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/cidade.dart';
import '../models/familia.dart';
import '../models/membro_familia.dart';
import '../models/lotacao.dart';

class BancoService {
  // ============================================================
  // BANCO
  // ============================================================

  Future<Database> get _db async {
    return await DatabaseHelper.instance.database;
  }

  // ============================================================
  // CIDADES
  // ============================================================

  // Cadastrar cidade
  Future<int> cadastrarCidade(Cidade cidade) async {
    final db = await _db;

    return await db.insert(
      'cidades',
      cidade.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Buscar todas as cidades
  Future<List<Cidade>> listarCidades() async {
    final db = await _db;

    final resultado = await db.query(
      'cidades',
      orderBy: 'nome ASC',
    );

    return resultado
        .map((map) => Cidade.fromMap(map))
        .toList();
  }

  // Buscar cidade pelo ID
  Future<Cidade?> buscarCidade(int id) async {
    final db = await _db;

    final resultado = await db.query(
      'cidades',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Cidade.fromMap(resultado.first);
  }

  // Editar cidade
  Future<int> atualizarCidade(Cidade cidade) async {
    final db = await _db;

    return await db.update(
      'cidades',
      cidade.toMap(),
      where: 'id = ?',
      whereArgs: [cidade.id],
    );
  }

  // Excluir cidade
  Future<int> excluirCidade(int id) async {
    final db = await _db;

    return await db.delete(
      'cidades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // FAMÍLIAS
  // ============================================================

  // Cadastrar família
  Future<int> cadastrarFamilia(Familia familia) async {
    final db = await _db;

    final dados = familia.toMap();

    // O ID é criado automaticamente pelo SQLite.
    dados.remove('id');

    return await db.insert(
      'familias',
      dados,
    );
  }

  // Listar todas as famílias
  Future<List<Familia>> listarFamilias() async {
    final db = await _db;

    final resultado = await db.query(
      'familias',
      orderBy: 'id DESC',
    );

    return resultado
        .map((map) => Familia.fromMap(map))
        .toList();
  }

  // Listar famílias de uma cidade
  Future<List<Familia>> listarFamiliasPorCidade(
    int cidadeId,
  ) async {
    final db = await _db;

    final resultado = await db.query(
      'familias',
      where: 'cidade_id = ?',
      whereArgs: [cidadeId],
      orderBy: 'responsavel ASC',
    );

    return resultado
        .map((map) => Familia.fromMap(map))
        .toList();
  }

  // Buscar uma família pelo ID
  Future<Familia?> buscarFamilia(int id) async {
    final db = await _db;

    final resultado = await db.query(
      'familias',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Familia.fromMap(resultado.first);
  }

  // Pesquisar família pelo responsável
  Future<List<Familia>> pesquisarFamilias(
    String texto,
  ) async {
    final db = await _db;

    final resultado = await db.query(
      'familias',
      where: 'responsavel LIKE ?',
      whereArgs: ['%$texto%'],
      orderBy: 'responsavel ASC',
    );

    return resultado
        .map((map) => Familia.fromMap(map))
        .toList();
  }

  // Editar família
  Future<int> atualizarFamilia(Familia familia) async {
    final db = await _db;

    final dados = familia.toMap();

    dados.remove('id');

    return await db.update(
      'familias',
      dados,
      where: 'id = ?',
      whereArgs: [familia.id],
    );
  }

  // Excluir família
  Future<int> excluirFamilia(int id) async {
    final db = await _db;

    return await db.delete(
      'familias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // MEMBROS DA FAMÍLIA
  // ============================================================

  // Cadastrar membro
  Future<int> cadastrarMembro(
    MembroFamilia membro,
  ) async {
    final db = await _db;

    final dados = membro.toMap();

    dados.remove('id');

    return await db.insert(
      'membros_familia',
      dados,
    );
  }

  // Listar membros de uma família
  Future<List<MembroFamilia>> listarMembros(
    int familiaId,
  ) async {
    final db = await _db;

    final resultado = await db.query(
      'membros_familia',
      where: 'familia_id = ?',
      whereArgs: [familiaId],
      orderBy: 'nome ASC',
    );

    return resultado
        .map((map) => MembroFamilia.fromMap(map))
        .toList();
  }

  // Buscar membro pelo ID
  Future<MembroFamilia?> buscarMembro(int id) async {
    final db = await _db;

    final resultado = await db.query(
      'membros_familia',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return MembroFamilia.fromMap(resultado.first);
  }

  // Editar membro
  Future<int> atualizarMembro(
    MembroFamilia membro,
  ) async {
    final db = await _db;

    final dados = membro.toMap();

    dados.remove('id');

    return await db.update(
      'membros_familia',
      dados,
      where: 'id = ?',
      whereArgs: [membro.id],
    );
  }

  // Excluir membro
  Future<int> excluirMembro(int id) async {
    final db = await _db;

    return await db.delete(
      'membros_familia',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Excluir todos os membros de uma família
  Future<int> excluirMembrosDaFamilia(
    int familiaId,
  ) async {
    final db = await _db;

    return await db.delete(
      'membros_familia',
      where: 'familia_id = ?',
      whereArgs: [familiaId],
    );
  }

  // ============================================================
  // LOTAÇÃO
  // ============================================================

  // Cadastrar lotação
  Future<int> cadastrarLotacao(
    Lotacao lotacao,
  ) async {
    final db = await _db;

    final dados = lotacao.toMap();

    dados.remove('id');

    return await db.insert(
      'lotacao',
      dados,
    );
  }

  // Buscar todas as lotações
  Future<List<Lotacao>> listarLotacoes() async {
    final db = await _db;

    final resultado = await db.query(
      'lotacao',
      orderBy: 'cidade_id ASC',
    );

    return resultado
        .map((map) => Lotacao.fromMap(map))
        .toList();
  }

  // Buscar lotação de uma cidade
  Future<Lotacao?> buscarLotacaoPorCidade(
    int cidadeId,
  ) async {
    final db = await _db;

    final resultado = await db.query(
      'lotacao',
      where: 'cidade_id = ?',
      whereArgs: [cidadeId],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Lotacao.fromMap(resultado.first);
  }

  // Editar lotação
  Future<int> atualizarLotacao(
    Lotacao lotacao,
  ) async {
    final db = await _db;

    final dados = lotacao.toMap();

    dados.remove('id');

    return await db.update(
      'lotacao',
      dados,
      where: 'id = ?',
      whereArgs: [lotacao.id],
    );
  }

  // Excluir lotação
  Future<int> excluirLotacao(int id) async {
    final db = await _db;

    return await db.delete(
      'lotacao',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}