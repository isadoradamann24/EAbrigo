class Familia {
  final int? id;
  final int cidadeId;
  final String responsavel;
  final String bairro;
  final String endereco;
  final String telefone;
  final String dataCadastro;

  Familia({
    this.id,
    required this.cidadeId,
    required this.responsavel,
    this.bairro = '',
    this.endereco = '',
    this.telefone = '',
    this.dataCadastro = '',
  });

  // Converte a família para um Map
  // que pode ser salvo no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cidade_id': cidadeId,
      'responsavel': responsavel,
      'bairro': bairro,
      'endereco': endereco,
      'telefone': telefone,
      'data_cadastro': dataCadastro,
    };
  }

  // Converte os dados do SQLite
  // para um objeto Familia.
  factory Familia.fromMap(Map<String, dynamic> map) {
    return Familia(
      id: map['id'],
      cidadeId: map['cidade_id'],
      responsavel: map['responsavel'] ?? '',
      bairro: map['bairro'] ?? '',
      endereco: map['endereco'] ?? '',
      telefone: map['telefone'] ?? '',
      dataCadastro: map['data_cadastro'] ?? '',
    );
  }

  // Cria uma cópia da família
  // permitindo alterar alguns campos.
  Familia copyWith({
    int? id,
    int? cidadeId,
    String? responsavel,
    String? bairro,
    String? endereco,
    String? telefone,
    String? dataCadastro,
  }) {
    return Familia(
      id: id ?? this.id,
      cidadeId: cidadeId ?? this.cidadeId,
      responsavel: responsavel ?? this.responsavel,
      bairro: bairro ?? this.bairro,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }
}