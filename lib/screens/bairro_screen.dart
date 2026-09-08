import 'package:flutter/material.dart';

import 'lotacao_screen.dart';
import 'cadastro_screen.dart';
import '../models/cidade.dart';
import '../models/familia.dart';
import '../services/banco_service.dart';
import '../widgets/cabecalho.dart';

class BairroScreen extends StatefulWidget {
  final Cidade cidade;
  final String bairro;

  const BairroScreen({
    super.key,
    required this.cidade,
    required this.bairro,
  });

  @override
  State<BairroScreen> createState() => _BairroScreenState();
}

class _BairroScreenState extends State<BairroScreen> {
  // ==========================================================
  // BANCO
  // ==========================================================

  final BancoService banco = BancoService();

  // ==========================================================
  // PESQUISA
  // ==========================================================

  final TextEditingController pesquisaController =
      TextEditingController();

  // ==========================================================
  // FAMÍLIAS
  // ==========================================================

  List<Familia> familias = [];

  List<Familia> familiasFiltradas = [];

  bool carregando = false;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    pesquisaController.addListener(
      pesquisarFamilias,
    );

    carregarFamilias();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    pesquisaController.dispose();

    super.dispose();
  }

  // ==========================================================
  // CARREGAR FAMÍLIAS
  // ==========================================================

  Future<void> carregarFamilias() async {
    setState(() {
      carregando = true;
    });

    try {
      final lista = await banco.listarFamilias();

      // Mostra somente as famílias:
      // 1. da cidade atual
      // 2. do bairro atual

      final familiasDoBairro = lista.where((familia) {
        return familia.cidadeId == widget.cidade.id &&
            familia.bairro.trim().toLowerCase() ==
                widget.bairro.trim().toLowerCase();
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        familias = familiasDoBairro;

        // Lista sempre visível: mostra todas as famílias do
        // bairro por padrão; a pesquisa apenas filtra essa lista.
        familiasFiltradas = familiasDoBairro;

        carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar famílias: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // PESQUISAR FAMÍLIA
  // ==========================================================

  void pesquisarFamilias() {
    final texto =
        pesquisaController.text.trim().toLowerCase();

    setState(() {
      // Campo vazio: mostra a listagem completa de famílias
      // cadastradas no bairro.
      if (texto.isEmpty) {
        familiasFiltradas = familias;
        return;
      }

      // Procura pelo nome do responsável.
      familiasFiltradas = familias.where((familia) {
        return familia.responsavel
            .toLowerCase()
            .contains(texto);
      }).toList();
    });
  }

  // ==========================================================
  // ABRIR CADASTRO (FAMÍLIA NOVA)
  // ==========================================================

  void abrirCadastroFamilia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroScreen(
          cidade: widget.cidade,
          bairro: widget.bairro,
        ),
      ),
    ).then((_) {
      // Quando voltar da tela de cadastro,
      // atualiza a lista de famílias.
      carregarFamilias();
    });
  }

  // ==========================================================
  // ABRIR FORMULÁRIO DE UMA FAMÍLIA JÁ CADASTRADA
  // (toca no nome encontrado na pesquisa)
  // ==========================================================

  void abrirFormularioDaFamilia(Familia familia) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroScreen(
          cidade: widget.cidade,
          bairro: widget.bairro,
          familiaExistente: familia,
        ),
      ),
    ).then((_) {
      // Quando voltar, atualiza a lista e limpa a pesquisa.
      pesquisaController.clear();
      carregarFamilias();
    });
  }

  // ==========================================================
  // CARD DA FAMÍLIA
  // ==========================================================

  Widget _cardFamilia(Familia familia) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => abrirFormularioDaFamilia(familia),
        child: Container(
          width: double.infinity,
          height: 31,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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

  // ==========================================================
  // BOTÃO PADRÃO
  // ==========================================================

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
          backgroundColor: const Color(0xFFE2E8FF),
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          side: const BorderSide(
            color: Colors.black,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8FF),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // CABEÇALHO
            // ==================================================

            const Cabecalho(),

            // ==================================================
            // ÁREA PRINCIPAL
            // ==================================================

            Expanded(
              child: Stack(
                children: [
                  // ==================================================
                  // MARCA D'ÁGUA
                  // ==================================================

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

                  // ==================================================
                  // CONTEÚDO
                  // ==================================================

                  LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final largura =
                          constraints.maxWidth;

                      final paddingHorizontal =
                          largura < 400 ? 25.0 : 40.0;

                      return SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),

                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 29,
                            left: paddingHorizontal,
                            right: paddingHorizontal,
                            bottom: 40,
                          ),

                          child: Column(
                            children: [
                              // ==========================================
                              // BAIRRO
                              // ==========================================

                              Container(
                                width: double.infinity,
                                height: 36,

                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,

                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),

                                  borderRadius:
                                      BorderRadius.circular(
                                    7,
                                  ),

                                  boxShadow: const [
                                    BoxShadow(
                                      color:
                                          Colors.black26,
                                      blurRadius: 2,
                                      offset:
                                          Offset(1, 2),
                                    ),
                                  ],
                                ),

                                alignment:
                                    Alignment.center,

                                child: Text(
                                  widget.bairro,
                                  textAlign:
                                      TextAlign.center,

                                  style:
                                      const TextStyle(
                                    fontSize: 14,
                                    color:
                                        Colors.black87,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              // ==========================================
                              // FAMÍLIA
                              // ==========================================

                              _botao(
                                texto: 'Família',
                                aoClicar:
                                    abrirCadastroFamilia,
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // ==========================================
                              // LOTAÇÃO
                              // ==========================================

                              _botao(
                                texto: 'Lotação',
                                aoClicar: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              LotacaoScreen(
                                        bairro:
                                            widget.bairro,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // ==========================================
                              // PESQUISA
                              // ==========================================

                              Container(
                                width: double.infinity,
                                height: 31,

                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: TextField(
                                  controller:
                                      pesquisaController,

                                  decoration:
                                      InputDecoration(
                                    hintText:
                                        'Pesquisar',

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
                                      color:
                                          Colors.black87,
                                    ),

                                    suffixIcon:
                                        pesquisaController
                                                .text
                                                .isNotEmpty
                                            ? IconButton(
                                                padding:
                                                    EdgeInsets
                                                        .zero,
                                                icon:
                                                    const Icon(
                                                  Icons.close,
                                                  size: 17,
                                                ),
                                                onPressed:
                                                    () {
                                                  pesquisaController
                                                      .clear();
                                                },
                                              )
                                            : null,

                                    border:
                                        InputBorder.none,

                                    contentPadding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // ==========================================
                              // CARREGANDO
                              // ==========================================

                              if (carregando)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),

                              // ==========================================
                              // LISTAGEM DE FAMÍLIAS CADASTRADAS
                              // (sempre visível; a pesquisa apenas
                              // filtra o que aparece aqui)
                              // ==========================================

                              if (!carregando)
                                ...familiasFiltradas.map(
                                  (familia) {
                                    return _cardFamilia(
                                      familia,
                                    );
                                  },
                                ),

                              // ==========================================
                              // NENHUM RESULTADO
                              // ==========================================

                              if (!carregando &&
                                  familiasFiltradas.isEmpty)
                                Padding(
                                  padding: const EdgeInsets
                                      .only(top: 10),
                                  child: Text(
                                    pesquisaController
                                            .text.isEmpty
                                        ? 'Nenhuma família cadastrada neste bairro.'
                                        : 'Nenhuma família encontrada.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.black54,
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