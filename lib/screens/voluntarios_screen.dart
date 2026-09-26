import 'package:flutter/material.dart';

/// Tela de Voluntários — placeholder inicial.
/// Substitua o conteúdo do body pelo formulário/lista real de voluntários
/// quando estiver pronto. O visual (AppBar branca, cor de destaque
/// 0xFFDDE2FF) segue o mesmo padrão usado no menu (Cabecalho).
class VoluntariosScreen extends StatelessWidget {
  const VoluntariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Voluntários',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.black87),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Quer ajudar na organização do evento? '
                      'Cadastre-se aqui como voluntário.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Em breve: formulário de inscrição para voluntários.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}