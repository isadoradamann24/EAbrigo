import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cidade.dart';
import '../services/acesso_admin.dart';
import '../widgets/cabecalho.dart';

class CadastroAbrigoScreen extends StatefulWidget {
  final Cidade cidade;

  const CadastroAbrigoScreen({super.key, required this.cidade});

  @override
  State<CadastroAbrigoScreen> createState() => _CadastroAbrigoScreenState();
}

class _CadastroAbrigoScreenState extends State<CadastroAbrigoScreen> {
  final bairroController = TextEditingController();
  final capacidadeController = TextEditingController();

  List<String> abrigosExistentes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final autorizado = await exigirAcessoAdmin(context);

      if (!mounted) return;

      if (!autorizado) {
        Navigator.pop(context);
        return;
      }

      carregarAbrigos();
    });
  }

  @override
  void dispose() {
    bairroController.dispose();
    capacidadeController.dispose();
    super.dispose();
  }

  Future<void> carregarAbrigos() async {
    setState(() {
      carregando = true;
    });

    final lista = await DatabaseHelper.instance
        .buscarBairrosComLotacao(widget.cidade.id!);

    if (!mounted) return;

    setState(() {
      abrigosExistentes = lista;
      carregando = false;
    });
  }

  Future<void> salvar() async {
    final autorizado = await exigirAcessoAdmin(context);

    if (!mounted || !autorizado) return;

    final bairro = bairroController.text.trim();
    final capacidadeTexto = capacidadeController.text.trim();

    if (bairro.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do bairro/abrigo.')),
      );
      return;
    }

    final capacidade = int.tryParse(capacidadeTexto);

    if (capacidade == null || capacidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma capacidade válida.')),
      );
      return;
    }

    await DatabaseHelper.instance.salvarCapacidadeAbrigo(
      cidadeId: widget.cidade.id!,
      bairro: bairro,
      capacidade: capacidade,
    );

    if (!mounted) return;

    bairroController.clear();
    capacidadeController.clear();

    await carregarAbrigos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Capacidade salva com sucesso!')),
    );
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        // CARD BRANCO TRANSPARENTE
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8FF),
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO
            const Cabecalho(),

            Expanded(
              child: Stack(
                children: [
                  // MARCA D'ÁGUA
                  Center(
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.asset(
                        'imgs/logofosca.png',
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  carregando
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Abrigos de ${widget.cidade.nome}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // CARD DA PERGUNTA / FORMULÁRIO
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Cadastrar / atualizar capacidade',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _campo(
                                      label: 'Bairro / nome do abrigo',
                                      controller: bairroController,
                                    ),
                                    const SizedBox(height: 10),
                                    _campo(
                                      label: 'Capacidade máxima',
                                      controller: capacidadeController,
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: salvar,
                                        child: const Text('Salvar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),
                              const Text(
                                'Abrigos já cadastrados:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              if (abrigosExistentes.isEmpty)
                                const Text('Nenhum abrigo cadastrado ainda.')
                              else
                                ...abrigosExistentes.map(
                                  (bairro) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      // CARD BRANCO
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(bairro),
                                      dense: true,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}