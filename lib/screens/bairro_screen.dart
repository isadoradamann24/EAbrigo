import 'package:flutter/material.dart';

import 'lotacao_screen.dart';
import 'cadastro_screen.dart';
import 'familia_detalhes_screen.dart';

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
  final BancoService banco = BancoService();

  final TextEditingController pesquisaController =
      TextEditingController();

  List<Familia> familias = [];
  List<Familia> familiasFiltradas = [];

  bool carregando = false;

  @override
  void initState() {
    super.initState();

    pesquisaController.addListener(pesquisarFamilias);

    carregarFamilias();
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
    if (mounted) {
      setState(() {
        carregando = true;
      });
    }

    try {
      final lista = await banco.listarFamilias();

      final familiasDoBairro = lista.where((familia) {
        return familia.cidadeId == widget.cidade.id &&
            familia.bairro.trim().toLowerCase() ==
                widget.bairro.trim().toLowerCase();
      }).toList();

      if (!mounted) return;

      setState(() {
        familias = familiasDoBairro;
        familiasFiltradas = familiasDoBairro;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

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

  // ============================================================
  // PESQUISAR FAMÍLIA
  // ============================================================

  void pesquisarFamilias() {
    final texto = pesquisaController.text.trim().toLowerCase();

    if (!mounted) return;

    setState(() {
      if (texto.isEmpty) {
        familiasFiltradas = familias;
        return;
      }

      familiasFiltradas = familias.where((familia) {
        return familia.responsavel
            .toLowerCase()
            .contains(texto);
      }).toList();
    });
  }

  // ============================================================
  // NOVO CADASTRO
  // ============================================================

  Future<void> abrirCadastroFamilia() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroScreen(
          cidade: widget.cidade,
          bairro: widget.bairro,
        ),
      ),
    );

    if (!mounted) return;

    pesquisaController.clear();
    await carregarFamilias();
  }

  // ============================================================
  // DETALHES DA FAMÍLIA
  // ============================================================

  Future<void> abrirDetalhesFamilia(Familia familia) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamiliaDetalhesScreen(
          familia: familia,
        ),
      ),
    );

    if (!mounted) return;

    pesquisaController.clear();
    await carregarFamilias();
  }

  // ============================================================
  // CARD DA FAMÍLIA
  // ============================================================

  Widget _cardFamilia(Familia familia) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => abrirDetalhesFamilia(familia),
        child: Container(
          width: double.infinity,
          height: 36,
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

  // ============================================================
  // BOTÕES
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
                  // LOGO DE FUNDO
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
                              // ==================================================
                              // BAIRRO
                              // ==================================================

                              Container(
                                width: double.infinity,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(7),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.bairro,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ==================================================
                              // FAMÍLIA
                              // ==================================================

                              _botao(
                                texto: 'Família',
                                aoClicar:
                                    abrirCadastroFamilia,
                              ),

                              const SizedBox(height: 15),

                              // ==================================================
                              // LOTAÇÃO
                              // ==================================================

                              _botao(
                                texto: 'Lotação',
                                aoClicar: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LotacaoScreen(
                                        cidade: widget.cidade,
                                        bairro: widget.bairro,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 15),

                              // ==================================================
                              // PESQUISA
                              // ==================================================

                              Container(
                                width: double.infinity,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  controller:
                                      pesquisaController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Pesquisar família',
                                    hintStyle:
                                        const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    prefixIcon:
                                        const Icon(
                                      Icons.search,
                                      size: 18,
                                      color: Colors.black87,
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
                                                onPressed: () {
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

                              const SizedBox(height: 15),

                              // ==================================================
                              // CARREGANDO
                              // ==================================================

                              if (carregando)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),

                              // ==================================================
                              // LISTA DE FAMÍLIAS
                              // ==================================================

                              if (!carregando)
                                ...familiasFiltradas.map(
                                  (familia) {
                                    return _cardFamilia(
                                      familia,
                                    );
                                  },
                                ),

                              // ==================================================
                              // NENHUMA FAMÍLIA
                              // ==================================================

                              if (!carregando &&
                                  familiasFiltradas
                                      .isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: Text(
                                    pesquisaController
                                            .text
                                            .isEmpty
                                        ? 'Nenhuma família cadastrada neste bairro.'
                                        : 'Nenhuma família encontrada.',
                                    textAlign:
                                        TextAlign.center,
                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
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