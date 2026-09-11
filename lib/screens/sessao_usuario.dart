import '../models/usuario.dart';

/// Guarda em memória qual admin está logado durante o uso do app.
/// Não persiste em disco de propósito: ao fechar o app, é preciso
/// logar de novo (sessão simples, sem token/expiração).
class SessaoUsuario {
  SessaoUsuario._();

  static final SessaoUsuario instance = SessaoUsuario._();

  Usuario? usuarioLogado;

  bool get estaLogado => usuarioLogado != null;

  /// Confere se o cadastro do admin logado tem as informações
  /// essenciais preenchidas. O formulário de cadastro já obriga
  /// isso, mas mantemos essa checagem como segurança extra.
  bool get temCadastroCompleto {
    final usuario = usuarioLogado;

    if (usuario == null) return false;

    return usuario.email.trim().isNotEmpty &&
        usuario.cpf.trim().isNotEmpty &&
        usuario.telefone.trim().isNotEmpty;
  }

  void definirUsuario(Usuario usuario) {
    usuarioLogado = usuario;
  }

  void sair() {
    usuarioLogado = null;
  }
}