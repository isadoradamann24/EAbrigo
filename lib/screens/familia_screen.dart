import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../models/familia.dart';
import '../database/database_helper.dart';

class FamiliaScreen extends StatefulWidget {
  final Cidade cidade;

  const FamiliaScreen({
    super.key,
    required this.cidade,
  });

  @override
  State<FamiliaScreen> createState() => _FamiliaScreenState();
}

class _FamiliaScreenState extends State<FamiliaScreen> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController responsavelController =
      TextEditingController();

  final TextEditingController bairroController =
      TextEditingController();

  final TextEditingController enderecoController =
      TextEditingController();

  final TextEditingController telefoneController =
      TextEditingController();

  final TextEditingController pesquisaController =
      TextEditingController();

  // ==========================================================
  // LISTA DE FAMÍLIAS
  // ==========================================================

  List<Familia> familias = [];

  bool carregando = true;

  // ==========================================================
  // INICIALIZAÇÃO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    carregarFamilias();

    pesquisaController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    responsavelController.dispose();
    bairroController.dispose();
    enderecoController.dispose();
    telefoneController.dispose();
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

    final db = await DatabaseHelper.instance.database;

    final resultado = await db.query(
      'familias',
      where: 'cidade_id = ?',
      whereArgs: [widget.cidade.id],
      orderBy: 'id DESC',
    );

    final lista = resultado.map((map) {
      return Familia.fromMap(map);
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      familias = lista;
      carregando = false;
    });
  }

  // ==========================================================
  // FAMÍLIAS FILTRADAS
  // ==========================================================

  List<Familia> get familiasFiltradas {
    final texto = pesquisaController.text.trim().toLowerCase();

    if (texto.isEmpty) {
      return familias;
    }

    return familias.where((familia) {
      return familia.responsavel
          .toLowerCase()
          .contains(texto);
    }).toList();
  }

  // ==========================================================
  // CADASTRAR FAMÍLIA
  // ==========================================================

  Future<void> cadastrarFamilia() async {
    final responsavel =
        responsavelController.text.trim();

    final bairro =
        bairroController.text.trim();

    final endereco =
        enderecoController.text.trim();

    final telefone =
        telefoneController.text.trim();

    if (responsavel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Digite o nome do responsável pela família.',
          ),
        ),
      );

      return;
    }

    final agora = DateTime.now();

    final dataCadastro =
        '${agora.day.toString().padLeft(2, '0')}/'
        '${agora.month.toString().padLeft(2, '0')}/'
        '${agora.year}';

    final familia = Familia(
      cidadeId: widget.cidade.id!,
      responsavel: responsavel,
      bairro: bairro,
      endereco: endereco,
      telefone: telefone,
      dataCadastro: dataCadastro,
    );

    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'familias',
      familia.toMap()..remove('id'),
    );

    if (!mounted) {
      return;
    }

    responsavelController.clear();
    bairroController.clear();
    enderecoController.clear();
    telefoneController.clear();

    await carregarFamilias();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Família cadastrada com sucesso!',
        ),
      ),
    );
  }

  // ==========================================================
  // EXCLUIR FAMÍLIA
  // ==========================================================

  Future<void> excluirFamilia(Familia familia) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir família',
          ),
          content: Text(
            'Deseja realmente excluir a família de '
            '${familia.responsavel}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Excluir',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'familias',
      where: 'id = ?',
      whereArgs: [familia.id],
    );

    await carregarFamilias();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Família excluída com sucesso!',
        ),
      ),
    );
  }

  // ==========================================================
  // VISUALIZAR FAMÍLIA
  // ==========================================================

  void visualizarFamilia(Familia familia) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            familia.responsavel,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _informacao(
                  'Cidade',
                  widget.cidade.nome,
                ),

                _informacao(
                  'Bairro',
                  familia.bairro.isEmpty
                      ? 'Não informado'
                      : familia.bairro,
                ),

                _informacao(
                  'Endereço',
                  familia.endereco.isEmpty
                      ? 'Não informado'
                      : familia.endereco,
                ),

                _informacao(
                  'Telefone',
                  familia.telefone.isEmpty
                      ? 'Não informado'
                      : familia.telefone,
                ),

                _informacao(
                  'Data do cadastro',
                  familia.dataCadastro.isEmpty
                      ? 'Não informado'
                      : familia.dataCadastro,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Fechar',
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // INFORMAÇÃO
  // ==========================================================

  Widget _informacao(
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CAMPO
  // ==========================================================

  Widget _campo({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 9,
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
          elevation: 1,
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CARD DA FAMÍLIA
  // ==========================================================

  Widget _cardFamilia(
    Familia familia,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Container(
        width: double.infinity,

        // CORRIGIDO:
        // Container não possui minHeight.
        height: 45,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                familia.responsavel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),

            // VISUALIZAR
            IconButton(
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(),
              icon: const Icon(
                Icons.visibility_outlined,
                size: 19,
                color: Colors.black87,
              ),
              onPressed: () {
                visualizarFamilia(
                  familia,
                );
              },
            ),

            const SizedBox(width: 10),

            // EXCLUIR
            IconButton(
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(),
              icon: const Icon(
                Icons.delete_outline,
                size: 19,
                color: Colors.black87,
              ),
              onPressed: () {
                excluirFamilia(
                  familia,
                );
              },
            ),
          ],
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
      backgroundColor:
          const Color(0xFFE2E8FF),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // CABEÇALHO
            // ==================================================

            Container(
              height: 53,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      left: 7,
                    ),
                    child: Image.asset(
                      'imgs/logo.png',
                      width: 57,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.black,
                      size: 23,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_outline,
                      color: Colors.black,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 2),
                ],
              ),
            ),

            // ==================================================
            // ÁREA PRINCIPAL
            // ==================================================

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

                  // CONTEÚDO
                  SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 29,
                        left: 40,
                        right: 40,
                        bottom: 40,
                      ),
                      child: Column(
                        children: [
                          // ==================================================
                          // CIDADE
                          // ==================================================

                          Container(
                            width: double.infinity,
                            height: 36,
                            decoration:
                                BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(7),
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
                              widget.cidade.nome,
                              style:
                                  const TextStyle(
                                fontSize: 14,
                                color:
                                    Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // ==================================================
                          // TÍTULO
                          // ==================================================

                          const Align(
                            alignment:
                                Alignment.centerLeft,
                            child: Text(
                              'Cadastrar família',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Colors.black87,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // RESPONSÁVEL
                          _campo(
                            hint:
                                'Nome do responsável',
                            controller:
                                responsavelController,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // BAIRRO
                          _campo(
                            hint: 'Bairro',
                            controller:
                                bairroController,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // ENDEREÇO
                          _campo(
                            hint: 'Endereço',
                            controller:
                                enderecoController,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // TELEFONE
                          _campo(
                            hint: 'Telefone',
                            controller:
                                telefoneController,
                            keyboardType:
                                TextInputType.phone,
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // ==================================================
                          // CADASTRAR
                          // ==================================================

                          _botao(
                            texto:
                                'Cadastrar família',
                            aoClicar:
                                cadastrarFamilia,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // PESQUISA
                          // ==================================================

                          Container(
                            width: double.infinity,
                            height: 31,
                            decoration:
                                BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(20),
                            ),
                            child: TextField(
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
                                  color:
                                      Colors.black87,
                                ),
                                suffixIcon:
                                    pesquisaController
                                            .text
                                            .isNotEmpty
                                        ? IconButton(
                                            padding:
                                                EdgeInsets.zero,
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

                          // ==================================================
                          // FAMÍLIAS
                          // ==================================================

                          if (carregando)
                            const Padding(
                              padding:
                                  EdgeInsets.all(
                                20,
                              ),
                              child:
                                  CircularProgressIndicator(),
                            )
                          else if (familiasFiltradas
                              .isEmpty)
                            const SizedBox()
                          else
                            ...familiasFiltradas
                                .map(
                              (familia) =>
                                  _cardFamilia(
                                familia,
                              ),
                            ),
                        ],
                      ),
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