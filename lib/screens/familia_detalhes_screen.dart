import 'package:flutter/material.dart';

import '../models/familia.dart';
import '../database/database_helper.dart';
import '../widgets/cabecalho.dart';

class FamiliaDetalhesScreen extends StatefulWidget {
  final Familia familia;

  const FamiliaDetalhesScreen({
    super.key,
    required this.familia,
  });

  @override
  State<FamiliaDetalhesScreen> createState() => _FamiliaDetalhesScreenState();
}

class _FamiliaDetalhesScreenState extends State<FamiliaDetalhesScreen> {
  // Cópia local para poder atualizar a tela depois de editar,
  // sem precisar navegar para outra tela.
  late Familia familia;

  @override
  void initState() {
    super.initState();
    familia = widget.familia;
  }

  // ==================================================
  // EDITAR
  // ==================================================
  Future<void> _abrirEdicao() async {
    final responsavelController =
        TextEditingController(text: familia.responsavel);
    final bairroController = TextEditingController(text: familia.bairro);
    final enderecoController = TextEditingController(text: familia.endereco);
    final telefoneController = TextEditingController(text: familia.telefone);

    final salvou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool camposPreenchidos() {
              return responsavelController.text.trim().isNotEmpty &&
                  bairroController.text.trim().isNotEmpty &&
                  enderecoController.text.trim().isNotEmpty &&
                  telefoneController.text.trim().isNotEmpty;
            }

            return AlertDialog(
              title: const Text('Editar família'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: responsavelController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do responsável',
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    TextField(
                      controller: bairroController,
                      decoration: const InputDecoration(labelText: 'Bairro'),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    TextField(
                      controller: enderecoController,
                      decoration: const InputDecoration(labelText: 'Endereço'),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    TextField(
                      controller: telefoneController,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: camposPreenchidos()
                      ? () {
                          Navigator.pop(context, true);
                        }
                      : null,
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (salvou != true) return;

    final familiaAtualizada = Familia(
      id: familia.id,
      cidadeId: familia.cidadeId,
      responsavel: responsavelController.text.trim(),
      bairro: bairroController.text.trim(),
      endereco: enderecoController.text.trim(),
      telefone: telefoneController.text.trim(),
      dataCadastro: familia.dataCadastro,
    );

    final db = await DatabaseHelper.instance.database;

    await db.update(
      'familias',
      familiaAtualizada.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [familia.id],
    );

    if (!mounted) return;

    setState(() {
      familia = familiaAtualizada;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Família atualizada com sucesso!')),
    );
  }

  // ==================================================
  // EXCLUIR
  // ==================================================
  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir família'),
          content: Text(
            'Deseja realmente excluir a família de ${familia.responsavel}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final db = await DatabaseHelper.instance.database;

    await db.delete('familias', where: 'id = ?', whereArgs: [familia.id]);

    if (!mounted) return;

    // Avisa a tela anterior (lista) que precisa recarregar,
    // devolvendo "true" via Navigator.pop.
    Navigator.pop(context, true);
  }

  Widget _informacao({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        // CARD BRANCO TRANSPARENTE
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 3),
                Text(
                  valor.isEmpty ? 'Não informado' : valor,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoAcao({
    required String texto,
    required IconData icone,
    required VoidCallback aoClicar,
    required Color cor,
  }) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: OutlinedButton.icon(
          onPressed: aoClicar,
          icon: Icon(icone, size: 18, color: cor),
          label: Text(
            texto,
            style: TextStyle(fontSize: 14, color: cor),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: cor, width: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
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
            const Cabecalho(),

            Expanded(
              child: Stack(
                children: [
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final largura = constraints.maxWidth;
                      final paddingHorizontal = largura < 400 ? 25.0 : 40.0;

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 29,
                            left: paddingHorizontal,
                            right: paddingHorizontal,
                            bottom: 40,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  familia.responsavel,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Informações da família',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 18),

                              _informacao(
                                titulo: 'Responsável',
                                valor: familia.responsavel,
                                icone: Icons.person_outline,
                              ),
                              _informacao(
                                titulo: 'Bairro',
                                valor: familia.bairro,
                                icone: Icons.location_on_outlined,
                              ),
                              _informacao(
                                titulo: 'Endereço',
                                valor: familia.endereco,
                                icone: Icons.home_outlined,
                              ),
                              _informacao(
                                titulo: 'Telefone',
                                valor: familia.telefone,
                                icone: Icons.phone_outlined,
                              ),
                              _informacao(
                                titulo: 'Data do cadastro',
                                valor: familia.dataCadastro,
                                icone: Icons.calendar_today_outlined,
                              ),

                              const SizedBox(height: 10),

                              // ==================================================
                              // BOTÕES EDITAR / EXCLUIR
                              // ==================================================
                              Row(
                                children: [
                                  _botaoAcao(
                                    texto: 'Editar',
                                    icone: Icons.edit_outlined,
                                    aoClicar: _abrirEdicao,
                                    cor: Colors.black87,
                                  ),
                                  const SizedBox(width: 12),
                                  _botaoAcao(
                                    texto: 'Excluir',
                                    icone: Icons.delete_outline,
                                    aoClicar: _excluir,
                                    cor: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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