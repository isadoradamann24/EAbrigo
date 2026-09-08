class MembroFamilia {
  final int? id;
  final int? familiaId;
  final String nome;
  final String parentesco;
  final int idade;
  final String escolaridade;
  final String identidadeGenero;

  MembroFamilia({
    this.id,
    this.familiaId,
    required this.nome,
    this.parentesco = '',
    this.idade = 0,
    this.escolaridade = '',
    this.identidadeGenero = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familia_id': familiaId,
      'nome': nome,
      'parentesco': parentesco,
      'idade': idade,
      'escolaridade': escolaridade,
      'identidade_genero': identidadeGenero,
    };
  }

  factory MembroFamilia.fromMap(Map<String, dynamic> map) {
    return MembroFamilia(
      id: map['id'],
      familiaId: map['familia_id'],
      nome: map['nome'] ?? '',
      parentesco: map['parentesco'] ?? '',
      idade: map['idade'] ?? 0,
      escolaridade: map['escolaridade'] ?? '',
      identidadeGenero: map['identidade_genero'] ?? '',
    );
  }

  MembroFamilia copyWith({
    int? id,
    int? familiaId,
    String? nome,
    String? parentesco,
    int? idade,
    String? escolaridade,
    String? identidadeGenero,
  }) {
    return MembroFamilia(
      id: id ?? this.id,
      familiaId: familiaId ?? this.familiaId,
      nome: nome ?? this.nome,
      parentesco: parentesco ?? this.parentesco,
      idade: idade ?? this.idade,
      escolaridade: escolaridade ?? this.escolaridade,
      identidadeGenero: identidadeGenero ?? this.identidadeGenero,
    );
  }
}