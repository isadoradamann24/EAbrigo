class Cidade {
  final int? id;
  final String nome;

  Cidade({
    this.id,
    required this.nome,
  });

  // Converte os dados do Flutter para o formato do SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  // Converte os dados do SQLite para um objeto Cidade
  factory Cidade.fromMap(Map<String, dynamic> map) {
    return Cidade(
      id: map['id'],
      nome: map['nome'],
    );
  }

  // Permite criar uma cópia da cidade alterando algum dado
  Cidade copyWith({
    int? id,
    String? nome,
  }) {
    return Cidade(
      id: id ?? this.id,
      nome: nome ?? this.nome,
    );
  }
}