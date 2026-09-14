import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/sessao_usuario.dart';

/// Garante que existe um admin logado, com cadastro completo,
/// antes de liberar uma ação restrita (ex: editar a capacidade
/// de um abrigo). Se ninguém estiver logado, abre a tela de
/// login e espera o resultado.
///
/// Retorna true se o acesso pode prosseguir, false caso o
/// usuário tenha cancelado ou o login tenha falhado.
Future<bool> exigirAcessoAdmin(BuildContext context) async {
  if (SessaoUsuario.instance.estaLogado &&
      SessaoUsuario.instance.temCadastroCompleto) {
    return true;
  }

  // OBS: não mostramos SnackBar aqui antes do Navigator.push.
  // A tela de login cobre a tela atual imediatamente, então o
  // aviso não seria visto mesmo — e mostrar o SnackBar bem nesse
  // instante causava o erro "_dependents.isEmpty: is not true"
  // (conflito entre o OverlayEntry do SnackBar e a transição de
  // rota acontecendo no mesmo frame).

  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  if (!context.mounted) return false;

  return SessaoUsuario.instance.estaLogado &&
      SessaoUsuario.instance.temCadastroCompleto;
}