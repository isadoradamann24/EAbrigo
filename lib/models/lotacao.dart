class Lotacao {
  final int? id;
  final int cidadeId;
  final int capacidade;
  final int ocupacao;

  Lotacao({
    this.id,
    required this.cidadeId,
    required this.capacidade,
    this.ocupacao = 0,
  });

  // Quantidade de vagas disponíveis
  int get vagasDisponiveis {
    return capacidade - ocupacao;
  }

  // Converte para Map para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cidade_id': cidadeId,
      'capacidade': capacidade,
      'ocupacao': ocupacao,
    };
  }

  // Converte os dados do SQLite para um objeto Lotacao
  factory Lotacao.fromMap(Map<String, dynamic> map) {
    return Lotacao(
      id: map['id'],
      cidadeId: map['cidade_id'],
      capacidade: map['capacidade'] ?? 0,
      ocupacao: map['ocupacao'] ?? 0,
    );
  }

  // Cria uma cópia podendo alterar alguns dados
  Lotacao copyWith({
    int? id,
    int? cidadeId,
    int? capacidade,
    int? ocupacao,
  }) {
    return Lotacao(
      id: id ?? this.id,
      cidadeId: cidadeId ?? this.cidadeId,
      capacidade: capacidade ?? this.capacidade,
      ocupacao: ocupacao ?? this.ocupacao,
    );
  }
}