class MembroFamilia {
  final int? id;
  final int familiaId;
  final String nome;
  final int idade;
  final String parentesco;

  MembroFamilia({
    this.id,
    required this.familiaId,
    required this.nome,
    required this.idade,
    required this.parentesco,
  });

  // Converte o membro para um Map
  // para ser salvo no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familia_id': familiaId,
      'nome': nome,
      'idade': idade,
      'parentesco': parentesco,
    };
  }

  // Converte os dados do SQLite
  // para um objeto MembroFamilia.
  factory MembroFamilia.fromMap(Map<String, dynamic> map) {
    return MembroFamilia(
      id: map['id'],
      familiaId: map['familia_id'],
      nome: map['nome'] ?? '',
      idade: map['idade'] ?? 0,
      parentesco: map['parentesco'] ?? '',
    );
  }

  // Cria uma cópia permitindo
  // alterar determinados dados.
  MembroFamilia copyWith({
    int? id,
    int? familiaId,
    String? nome,
    int? idade,
    String? parentesco,
  }) {
    return MembroFamilia(
      id: id ?? this.id,
      familiaId: familiaId ?? this.familiaId,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
      parentesco: parentesco ?? this.parentesco,
    );
  }
}