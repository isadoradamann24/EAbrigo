class Usuario {
  final int? id;
  final String usuario;
  final String email;
  final String cpf;
  final String telefone;
  final String senhaHash;

  Usuario({
    this.id,
    required this.usuario,
    this.email = '',
    this.cpf = '',
    this.telefone = '',
    required this.senhaHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario': usuario,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'senha_hash': senhaHash,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      usuario: map['usuario'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
      senhaHash: map['senha_hash'] ?? '',
    );
  }
}