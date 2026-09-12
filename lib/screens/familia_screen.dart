import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../models/familia.dart';
import '../database/database_helper.dart';
import '../widgets/cabecalho.dart';

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
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController pesquisaController = TextEditingController();

  List<Familia> familias = [];

  bool carregando = true;

  // Família atualmente selecionada para edição (null = modo cadastro)
  Familia? familiaSelecionada;

  bool get modoEdicao => familiaSelecionada != null;

  @override
  void initState() {
    super.initState();

    carregarFamilias();

    pesquisaController.addListener(() {
      setState(() {});
    });

    // Atualiza a tela (habilita/desabilita o botão) sempre que
    // algum campo do formulário mudar.
    responsavelController.addListener(_atualizarTela);
    bairroController.addListener(_atualizarTela);
    enderecoController.addListener(_atualizarTela);
    telefoneController.addListener(_atualizarTela);
  }

  void _atualizarTela() {
    setState(() {});
  }

  // Verdadeiro somente quando os 4 campos estão preenchidos
  bool get _todosCamposPreenchidos {
    return responsavelController.text.trim().isNotEmpty &&
        bairroController.text.trim().isNotEmpty &&
        enderecoController.text.trim().isNotEmpty &&
        telefoneController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    responsavelController.removeListener(_atualizarTela);
    bairroController.removeListener(_atualizarTela);
    enderecoController.removeListener(_atualizarTela);
    telefoneController.removeListener(_atualizarTela);

    responsavelController.dispose();
    bairroController.dispose();
    enderecoController.dispose();
    telefoneController.dispose();
    pesquisaController.dispose();

    super.dispose();
  }

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

    if (!mounted) return;

    setState(() {
      familias = lista;
      carregando = false;
    });
  }

  List<Familia> get familiasFiltradas {
    final texto = pesquisaController.text.trim().toLowerCase();

    if (texto.isEmpty) {
      return familias;
    }

    return familias.where((familia) {
      return familia.responsavel.toLowerCase().contains(texto);
    }).toList();
  }

  // ==================================================
  // VALIDAÇÃO: todos os campos precisam estar preenchidos
  // ==================================================
  bool _camposValidos() {
    final responsavel = responsavelController.text.trim();
    final bairro = bairroController.text.trim();
    final endereco = enderecoController.text.trim();
    final telefone = telefoneController.text.trim();

    if (responsavel.isEmpty ||
        bairro.isEmpty ||
        endereco.isEmpty ||
        telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de continuar.'),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> cadastrarFamilia() async {
    if (!_camposValidos()) return;

    final responsavel = responsavelController.text.trim();
    final bairro = bairroController.text.trim();
    final endereco = enderecoController.text.trim();
    final telefone = telefoneController.text.trim();

    final agora = DateTime.now();

    final dataCadastro = '${agora.day.toString().padLeft(2, '0')}/'
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

    await db.insert('familias', familia.toMap()..remove('id'));

    if (!mounted) return;

    limparFormulario();

    await carregarFamilias();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Família cadastrada com sucesso!')),
    );
  }

  // ==================================================
  // SELECIONAR FAMÍLIA PARA EDITAR
  // ==================================================
  void selecionarFamiliaParaEdicao(Familia familia) {
    setState(() {
      familiaSelecionada = familia;
      responsavelController.text = familia.responsavel;
      bairroController.text = familia.bairro;
      enderecoController.text = familia.endereco;
      telefoneController.text = familia.telefone;
    });
  }

  void cancelarEdicao() {
    setState(() {
      familiaSelecionada = null;
    });
    limparFormulario();
  }

  void limparFormulario() {
    responsavelController.clear();
    bairroController.clear();
    enderecoController.clear();
    telefoneController.clear();
  }

  // ==================================================
  // SALVAR EDIÇÃO
  // ==================================================
  Future<void> salvarEdicaoFamilia() async {
    if (familiaSelecionada == null) return;
    if (!_camposValidos()) return;

    final responsavel = responsavelController.text.trim();
    final bairro = bairroController.text.trim();
    final endereco = enderecoController.text.trim();
    final telefone = telefoneController.text.trim();

    final familiaAtualizada = Familia(
      id: familiaSelecionada!.id,
      cidadeId: familiaSelecionada!.cidadeId,
      responsavel: responsavel,
      bairro: bairro,
      endereco: endereco,
      telefone: telefone,
      dataCadastro: familiaSelecionada!.dataCadastro,
    );

    final db = await DatabaseHelper.instance.database;

    await db.update(
      'familias',
      familiaAtualizada.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [familiaSelecionada!.id],
    );

    if (!mounted) return;

    setState(() {
      familiaSelecionada = null;
    });

    limparFormulario();

    await carregarFamilias();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Família atualizada com sucesso!')),
    );
  }

  Future<void> excluirFamilia(Familia familia) async {
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

    if (confirmar != true) {
      return;
    }

    final db = await DatabaseHelper.instance.database;

    await db.delete('familias', where: 'id = ?', whereArgs: [familia.id]);

    // Se a família excluída era a que estava selecionada no formulário,
    // volta pro modo cadastro.
    if (familiaSelecionada?.id == familia.id) {
      setState(() {
        familiaSelecionada = null;
      });
      limparFormulario();
    }

    await carregarFamilias();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Família excluída com sucesso!')),
    );
  }

  void visualizarFamilia(Familia familia) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(familia.responsavel),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _informacao('Cidade', widget.cidade.nome),
                _informacao(
                  'Bairro',
                  familia.bairro.isEmpty ? 'Não informado' : familia.bairro,
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
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _informacao(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(valor),
        ],
      ),
    );
  }

  Widget _campo({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      height: 38,
      decoration: BoxDecoration(
        // CARD BRANCO 
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        ),
      ),
    );
  }

  Widget _botao({
    required String texto,
    required VoidCallback? aoClicar,
    Color corFundo = const Color(0xFFE2E8FF),
    Color corTexto = Colors.black,
    Color corBorda = Colors.black,
  }) {
    final desabilitado = aoClicar == null;

    final fundoFinal = desabilitado ? Colors.grey.shade300 : corFundo;
    final textoFinal = desabilitado ? Colors.grey.shade600 : corTexto;
    final bordaFinal = desabilitado ? Colors.grey.shade400 : corBorda;

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: OutlinedButton(
        onPressed: aoClicar,
        style: OutlinedButton.styleFrom(
          backgroundColor: fundoFinal,
          foregroundColor: textoFinal,
          padding: EdgeInsets.zero,
          side: BorderSide(color: bordaFinal, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          elevation: 1,
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textoFinal,
          ),
        ),
      ),
    );
  }

  Widget _cardFamilia(Familia familia) {
    final selecionada = familiaSelecionada?.id == familia.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          selecionarFamiliaParaEdicao(familia);
        },
        child: Container(
          width: double.infinity,
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            // CARD BRANCO 
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: selecionada
                ? Border.all(color: Colors.black87, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  familia.responsavel,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 19,
                  color: Colors.black87,
                ),
                onPressed: () {
                  visualizarFamilia(familia);
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: Colors.black87,
                ),
                onPressed: () {
                  selecionarFamiliaParaEdicao(familia);
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                  color: Colors.black87,
                ),
                onPressed: () {
                  excluirFamilia(familia);
                },
              ),
            ],
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
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 29, left: 40, right: 40, bottom: 40),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(7),
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
                              widget.cidade.nome,
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),

                          const SizedBox(height: 15),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              modoEdicao
                                  ? 'Editando família'
                                  : 'Cadastrar família',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          _campo(hint: 'Nome do responsável', controller: responsavelController),
                          const SizedBox(height: 10),
                          _campo(hint: 'Bairro', controller: bairroController),
                          const SizedBox(height: 10),
                          _campo(hint: 'Endereço', controller: enderecoController),
                          const SizedBox(height: 10),
                          _campo(
                            hint: 'Telefone',
                            controller: telefoneController,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 15),

                          // ==================================================
                          // BOTÕES: modo cadastro OU modo edição
                          // ==================================================
                          if (!modoEdicao)
                            _botao(
                              texto: 'Cadastrar família',
                              aoClicar: _todosCamposPreenchidos
                                  ? cadastrarFamilia
                                  : null,
                            )
                          else
                            Column(
                              children: [
                                _botao(
                                  texto: 'Salvar edição',
                                  aoClicar: _todosCamposPreenchidos
                                      ? salvarEdicaoFamilia
                                      : null,
                                  corFundo: Colors.black87,
                                  corTexto: Colors.white,
                                  corBorda: Colors.black87,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _botao(
                                        texto: 'Excluir',
                                        aoClicar: () {
                                          excluirFamilia(familiaSelecionada!);
                                        },
                                        corFundo: Colors.white,
                                        corTexto: Colors.red,
                                        corBorda: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _botao(
                                        texto: 'Cancelar',
                                        aoClicar: cancelarEdicao,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            height: 31,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: pesquisaController,
                              decoration: InputDecoration(
                                hintText: 'Pesquisar família',
                                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.black87),
                                suffixIcon: pesquisaController.text.isNotEmpty
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.close, size: 17),
                                        onPressed: () {
                                          pesquisaController.clear();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 10,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          if (carregando)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            )
                          else if (familiasFiltradas.isEmpty)
                            const SizedBox()
                          else
                            ...familiasFiltradas.map(
                              (familia) => _cardFamilia(familia),
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