import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/sessao_usuario.dart';

Future<bool> exigirAcessoAdmin(BuildContext context) async {
  if (SessaoUsuario.instance.estaLogado &&
      SessaoUsuario.instance.temCadastroCompleto) {
    return true;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Faça login para acessar essa área.'),
    ),
  );

  // Dá um frame de respiro para o SnackBar terminar de se inserir
  // na árvore ANTES de iniciar a transição de rota. Sem isso, o
  // Flutter pode tentar mover/desmontar elementos que ainda têm
  // dependências registradas (Theme/Directionality do SnackBar),
  // causando o erro "_dependents.isEmpty: is not true".
  await Future<void>.delayed(Duration.zero);

  if (!context.mounted) return false;

  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  if (!context.mounted) return false;

  return SessaoUsuario.instance.estaLogado &&
      SessaoUsuario.instance.temCadastroCompleto;
}