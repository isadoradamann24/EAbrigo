import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';
import '../models/cidade.dart';
import '../models/familia.dart';
import '../models/membro_familia.dart';
import '../models/usuario.dart';

class BancoService {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  // ============================================================
  // CIDADES
  // ============================================================

  Future<List<Cidade>> listarCidades() async {
    final db = await _helper.database;

    final resultado = await db.query('cidades');

    return resultado.map((mapa) => Cidade.fromMap(mapa)).toList();
  }

  // ============================================================
  // FAMÍLIA
  // ============================================================

  /// Cadastra a família e retorna o id gerado.
Future<void> excluirFamilia(int familiaId) async {
  final db = await _helper.database;

  await db.transaction((txn) async {
    await txn.delete(
      'membros_familia',
      where: 'familia_id = ?',
      whereArgs: [familiaId],
    );

    await txn.delete(
      'familias',
      where: 'id = ?',
      whereArgs: [familiaId],
    );
  });
}
  /// Cadastra a família junto com todos os membros da composição
  /// familiar em uma única transação (tudo ou nada).
  Future<int> cadastrarFamiliaCompleta(
    Familia familia,
    List<MembroFamilia> membros,
  ) async {
    final db = await _helper.database;

    return await db.transaction<int>((txn) async {
      final mapaFamilia = familia.toMap()..remove('id');

      final familiaId = await txn.insert('familias', mapaFamilia);

      for (final membro in membros) {
        final mapaMembro = membro.copyWith(familiaId: familiaId).toMap()
          ..remove('id');

        await txn.insert('membros_familia', mapaMembro);
      }

      return familiaId;
    });
  }

  /// Atualiza os dados da família e substitui a composição familiar
  /// (membros) pela lista informada. Usado quando o responsável
  /// reabre um cadastro já existente para continuar/editar.
  Future<void> atualizarFamiliaCompleta(
    Familia familia,
    List<MembroFamilia> membros,
  ) async {
    final db = await _helper.database;

    if (familia.id == null) {
      throw ArgumentError(
        'Não é possível atualizar uma família sem id.',
      );
    }

    await db.transaction((txn) async {
      final mapaFamilia = familia.toMap()..remove('id');

      await txn.update(
        'familias',
        mapaFamilia,
        where: 'id = ?',
        whereArgs: [familia.id],
      );

      // Remove os membros antigos e grava a lista atual novamente,
      // já que o usuário pode ter adicionado/removido pessoas.
      await txn.delete(
        'membros_familia',
        where: 'familia_id = ?',
        whereArgs: [familia.id],
      );

      for (final membro in membros) {
        final mapaMembro = membro.copyWith(familiaId: familia.id).toMap()
          ..remove('id');

        await txn.insert('membros_familia', mapaMembro);
      }
    });
  }

  /// Lista todas as famílias cadastradas. A tela de bairro filtra
  /// o resultado por cidade e bairro depois de receber a lista.
  Future<List<Familia>> listarFamilias() async {
    final db = await _helper.database;

    final resultado = await db.query('familias');

    return resultado.map((mapa) => Familia.fromMap(mapa)).toList();
  }

  /// Variante já filtrada por cidade, para quem preferir filtrar
  /// direto na consulta em vez de em memória.
  Future<List<Familia>> listarFamiliasPorCidade(int cidadeId) async {
    final db = await _helper.database;

    final resultado = await db.query(
      'familias',
      where: 'cidade_id = ?',
      whereArgs: [cidadeId],
    );

    return resultado.map((mapa) => Familia.fromMap(mapa)).toList();
  }

  // ============================================================
  // MEMBROS DA FAMÍLIA (Composição Familiar)
  // ============================================================

  Future<int> cadastrarMembro(MembroFamilia membro) async {
    final db = await _helper.database;

    final mapa = membro.toMap()..remove('id');

    return await db.insert('membros_familia', mapa);
  }

  Future<List<MembroFamilia>> listarMembros(int familiaId) async {
    final db = await _helper.database;

    final resultado = await db.query(
      'membros_familia',
      where: 'familia_id = ?',
      whereArgs: [familiaId],
    );

    return resultado.map((mapa) => MembroFamilia.fromMap(mapa)).toList();
  }

  Future<void> excluirMembro(int id) async {
    final db = await _helper.database;

    await db.delete(
      'membros_familia',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // USUÁRIOS (LOGIN / CADASTRO DE ADMINISTRADOR)
  // ============================================================

  String _hashSenha(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  /// Cadastra um novo usuário. Lança uma exceção se o nome de
  /// usuário já existir (coluna UNIQUE no banco).
  Future<int> cadastrarUsuario({
    required String usuario,
    required String senha,
    String email = '',
    String cpf = '',
    String telefone = '',
  }) async {
    final db = await _helper.database;

    final novoUsuario = Usuario(
      usuario: usuario.trim(),
      email: email.trim(),
      cpf: cpf.trim(),
      telefone: telefone.trim(),
      senhaHash: _hashSenha(senha),
    );

    return await db.insert('usuarios', novoUsuario.toMap()..remove('id'));
  }

  /// Retorna o usuário se a combinação usuário/senha estiver correta,
  /// ou null se não encontrar (usuário inexistente ou senha errada).
  Future<Usuario?> login({
    required String usuario,
    required String senha,
  }) async {
    final db = await _helper.database;

    final resultado = await db.query(
      'usuarios',
      where: 'usuario = ? AND senha_hash = ?',
      whereArgs: [usuario.trim(), _hashSenha(senha)],
      limit: 1,
    );

    if (resultado.isEmpty) return null;

    return Usuario.fromMap(resultado.first);
  }
}