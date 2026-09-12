import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../services/banco_service.dart';
import '../screens/controle_screen.dart';
import '../screens/login_screen.dart';


class Cabecalho extends StatelessWidget implements PreferredSizeWidget {
  const Cabecalho({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(53);

  Future<void> _abrirMenu(BuildContext context) async {
    final banco = BancoService();

    await showGeneralDialog(
      context: context,
      barrierLabel: 'menu',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.15),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topLeft,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 53, left: 4),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                elevation: 6,
                child: Container(
                  width: 210,
                  constraints: const BoxConstraints(maxHeight: 420),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FutureBuilder<List<Cidade>>(
                    future: banco.listarCidades(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }

                      final cidades = snapshot.data!;

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final cidade in cidades)
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ControleScreen(cidade: cidade),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    cidade.nome,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Colors.black26),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _abrirLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          // LOGO
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Image.asset(
              'imgs/logo.png',
              width: 60,
              height: 55,
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),

          // MENU
          IconButton(
            onPressed: () => _abrirMenu(context),
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 25,
            ),
          ),

          // PERFIL / LOGIN
          IconButton(
            onPressed: () => _abrirLogin(context),
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
              size: 24,
            ),
          ),

          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

