import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../models/familia.dart';
import '../services/banco_service.dart';
import '../widgets/cabecalho.dart';


import 'familia_screen.dart';
import 'familia_detalhes_screen.dart';
import 'lotacao_screen.dart';

class ControleScreen extends StatefulWidget {
  final Cidade cidade;

  const ControleScreen({
    super.key,
    required this.cidade,
  });

  @override
  State<ControleScreen> createState() =>
      _ControleScreenState();
}

class _ControleScreenState
    extends State<ControleScreen> {
  final BancoService banco = BancoService();

  final TextEditingController pesquisaController =
      TextEditingController();

  String? bairroSelecionado;

  List<Familia> familias = [];
  List<Familia> familiasFiltradas = [];

  bool carregando = false;

  List<String> bairrosDaCidade(
    String nomeCidade,
  ) {
    switch (nomeCidade.toLowerCase()) {
      case 'rio do sul':
        return [
          'Progresso',
          'Boa Vista',
          'Santa Rita',
          'Canta Galo',
        ];

      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();

    pesquisaController.addListener(
      pesquisarFamilias,
    );
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARREGAR FAMÍLIAS
  // ============================================================

  Future<void> carregarFamilias() async {
    if (bairroSelecionado == null) {
      setState(() {
        familias = [];
        familiasFiltradas = [];
      });
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final lista = await banco.listarFamilias();

      final listaDoBairro = lista.where((familia) {
        return familia.cidadeId == widget.cidade.id &&
            familia.bairro.trim().toLowerCase() ==
                bairroSelecionado!
                    .trim()
                    .toLowerCase();
      }).toList();

      if (!mounted) return;

      setState(() {
        familias = listaDoBairro;
        familiasFiltradas = listaDoBairro;
        carregando = false;
      });

      pesquisarFamilias();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar famílias: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // PESQUISA
  // ============================================================

  void pesquisarFamilias() {
    final texto =
        pesquisaController.text.trim().toLowerCase();

    if (!mounted) return;

    setState(() {
      if (texto.isEmpty) {
        familiasFiltradas = familias;
        return;
      }

      familiasFiltradas =
          familias.where((familia) {
        return familia.responsavel
            .toLowerCase()
            .contains(texto);
      }).toList();
    });
  }

  // ============================================================
  // ABRIR FAMÍLIA
  // ============================================================

  Future<void> abrirFamilia(
    Familia familia,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FamiliaDetalhesScreen(
          familia: familia,
        ),
      ),
    );

    if (!mounted) return;

    await carregarFamilias();
  }

  // ============================================================
  // NOVA FAMÍLIA
  // ============================================================

  Future<void> novaFamilia() async {
    if (bairroSelecionado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione um bairro primeiro.',
          ),
        ),
      );
      return;
    }

    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FamiliaScreen(
          cidade: widget.cidade,
          bairro: bairroSelecionado!,
        ),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      await carregarFamilias();
    }
  }

  // ============================================================
  // BOTÃO
  // ============================================================

  Widget _botao({
    required String texto,
    required VoidCallback aoClicar,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: OutlinedButton(
        onPressed: aoClicar,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              const Color(0xFFE2E8FF),
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          side: const BorderSide(
            color: Colors.black,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(7),
          ),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARD DA FAMÍLIA
  // ============================================================

  Widget _cardFamilia(
    Familia familia,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: () =>
            abrirFamilia(familia),
        child: Container(
          width: double.infinity,
          height: 36,
          alignment: Alignment.centerLeft,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            familia.responsavel,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bairros = bairrosDaCidade(
      widget.cidade.nome,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFE2E8FF),
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
                    builder:
                        (context, constraints) {
                      final paddingHorizontal =
                          constraints.maxWidth <
                                  400
                              ? 25.0
                              : 40.0;

                      return SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 48,
                            left:
                                paddingHorizontal,
                            right:
                                paddingHorizontal,
                            bottom: 40,
                          ),
                          child: Column(
                            children: [
                              // CIDADE
                              Container(
                                width:
                                    double.infinity,
                                height: 36,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  border:
                                      Border.all(
                                    color:
                                        Colors.black,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    7,
                                  ),
                                ),
                                alignment:
                                    Alignment.center,
                                child: Text(
                                  widget.cidade
                                      .nome,
                                  style:
                                      const TextStyle(
                                    fontSize: 14,
                                    color: Colors
                                        .black87,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              // BAIRRO
                              Container(
                                width:
                                    double.infinity,
                                height: 36,
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  border:
                                      Border.all(
                                    color:
                                        Colors.black,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    7,
                                  ),
                                ),
                                child:
                                    DropdownButtonHideUnderline(
                                  child:
                                      DropdownButton<
                                          String>(
                                    value:
                                        bairroSelecionado,
                                    hint:
                                        const Text(
                                      'Abrigos',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            14,
                                        color: Colors
                                            .black87,
                                      ),
                                    ),
                                    isExpanded:
                                        true,
                                    items: bairros
                                        .map(
                                          (
                                            bairro,
                                          ) {
                                            return DropdownMenuItem<
                                                String>(
                                              value:
                                                  bairro,
                                              child:
                                                  Text(
                                                bairro,
                                              ),
                                            );
                                          },
                                        )
                                        .toList(),
                                    onChanged:
                                        (valor) {
                                      if (valor ==
                                          null) {
                                        return;
                                      }

                                      setState(() {
                                        bairroSelecionado =
                                            valor;
                                        pesquisaController
                                            .clear();
                                      });

                                      carregarFamilias();
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              // FAMÍLIA
                              _botao(
                                texto:
                                    'Família',
                                aoClicar:
                                    novaFamilia,
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // LOTAÇÃO
                              _botao(
                                texto:
                                    'Lotação',
                                aoClicar: () {
                                  if (bairroSelecionado ==
                                      null) {
                                    ScaffoldMessenger
                                            .of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text(
                                          'Selecione um bairro primeiro.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              LotacaoScreen(
                                        cidade:
                                            widget
                                                .cidade,
                                        bairro:
                                            bairroSelecionado!,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // PESQUISA
                              Container(
                                width:
                                    double.infinity,
                                height: 35,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                                child:
                                    TextField(
                                  controller:
                                      pesquisaController,
                                  decoration:
                                      InputDecoration(
                                    hintText:
                                        'Pesquisar família',
                                    hintStyle:
                                        const TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.grey,
                                    ),
                                    prefixIcon:
                                        const Icon(
                                      Icons.search,
                                      size: 18,
                                      color: Colors
                                          .black87,
                                    ),
                                    border:
                                        InputBorder
                                            .none,
                                    contentPadding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 7,
                                      horizontal:
                                          10,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              if (bairroSelecionado ==
                                  null)
                                const Text(
                                  'Selecione um bairro para visualizar as famílias.',
                                  style:
                                      TextStyle(
                                    fontSize: 12,
                                    color: Colors
                                        .black54,
                                  ),
                                ),

                              if (carregando)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),

                              if (!carregando)
                                ...familiasFiltradas
                                    .map(
                                  (familia) =>
                                      _cardFamilia(
                                    familia,
                                  ),
                                ),

                              if (!carregando &&
                                  bairroSelecionado !=
                                      null &&
                                  familiasFiltradas
                                      .isEmpty)
                                const Padding(
                                  padding:
                                      EdgeInsets
                                          .only(
                                    top: 10,
                                  ),
                                  child: Text(
                                    'Nenhuma família cadastrada neste bairro.',
                                    style:
                                        TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .black54,
                                    ),
                                  ),
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