import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../models/familia.dart';
import '../services/banco_service.dart';

class CadastroScreen extends StatefulWidget {
  final Cidade cidade;
  final String bairro;

  const CadastroScreen({
    super.key,
    required this.cidade,
    required this.bairro,
  });

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final BancoService banco = BancoService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController responsavelController =
      TextEditingController();

  final TextEditingController enderecoController =
      TextEditingController();

  final TextEditingController telefoneController =
      TextEditingController();

  DateTime dataCadastro = DateTime.now();

  bool salvando = false;

  @override
  void dispose() {
    responsavelController.dispose();
    enderecoController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SALVAR FAMÍLIA
  // ==========================================================

  Future<void> salvarFamilia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    final dataFormatada =
        '${dataCadastro.day.toString().padLeft(2, '0')}/'
        '${dataCadastro.month.toString().padLeft(2, '0')}/'
        '${dataCadastro.year}';

    final familia = Familia(
      cidadeId: widget.cidade.id!,
      responsavel: responsavelController.text.trim(),
      bairro: widget.bairro,
      endereco: enderecoController.text.trim(),
      telefone: telefoneController.text.trim(),
      dataCadastro: dataFormatada,
    );

    try {
      await banco.cadastrarFamilia(familia);

      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Família cadastrada com sucesso!',
          ),
        ),
      );

      // Volta para a página do bairro
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao cadastrar família: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // LIMPAR
  // ==========================================================

  void limparFormulario() {
    responsavelController.clear();
    enderecoController.clear();
    telefoneController.clear();

    setState(() {
      dataCadastro = DateTime.now();
    });
  }

  // ==========================================================
  // DATA
  // ==========================================================

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataCadastro,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        dataCadastro = data;
      });
    }
  }

  // ==========================================================
  // CAMPO
  // ==========================================================

  Widget _campo({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,

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

          prefixIcon: Icon(
            icon,
            size: 19,
            color: Colors.black87,
          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BOTÃO
  // ==========================================================

  Widget _botao({
    required String texto,
    required VoidCallback? aoClicar,
    bool carregando = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 38,

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

        child: carregando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
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

            Container(
              height: 53,
              width: double.infinity,
              color: Colors.white,

              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
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
            // CONTEÚDO
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
                  // FORMULÁRIO
                  // ==================================================

                  LayoutBuilder(
                    builder: (context, constraints) {
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

                          child: Form(
                            key: _formKey,

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,

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

                                    border:
                                        Border.all(
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
                                  height: 18,
                                ),

                                // ==========================================
                                // TÍTULO
                                // ==========================================

                                const Text(
                                  'Cadastrar Família',

                                  textAlign:
                                      TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.black87,
                                  ),
                                ),

                                const SizedBox(
                                  height: 18,
                                ),

                                // ==========================================
                                // RESPONSÁVEL
                                // ==========================================

                                _campo(
                                  hint:
                                      'Nome do responsável *',

                                  icon:
                                      Icons.person_outline,

                                  controller:
                                      responsavelController,

                                  validator:
                                      (valor) {
                                    if (valor ==
                                            null ||
                                        valor
                                            .trim()
                                            .isEmpty) {
                                      return 'Informe o responsável';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                // ==========================================
                                // ENDEREÇO
                                // ==========================================

                                _campo(
                                  hint: 'Endereço',

                                  icon:
                                      Icons.home_outlined,

                                  controller:
                                      enderecoController,

                                  maxLines: 2,
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                // ==========================================
                                // TELEFONE
                                // ==========================================

                                _campo(
                                  hint: 'Telefone',

                                  icon:
                                      Icons.phone_outlined,

                                  controller:
                                      telefoneController,

                                  keyboardType:
                                      TextInputType.phone,
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                // ==========================================
                                // DATA
                                // ==========================================

                                InkWell(
                                  onTap:
                                      selecionarData,

                                  child: Container(
                                    width:
                                        double.infinity,
                                    height: 45,

                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 14,
                                    ),

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

                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .calendar_today,
                                          size: 19,
                                          color: Colors
                                              .black87,
                                        ),

                                        const SizedBox(
                                          width: 10,
                                        ),

                                        Text(
                                          '${dataCadastro.day.toString().padLeft(2, '0')}/'
                                          '${dataCadastro.month.toString().padLeft(2, '0')}/'
                                          '${dataCadastro.year}',

                                          style:
                                              const TextStyle(
                                            fontSize: 13,
                                            color: Colors
                                                .black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 22,
                                ),

                                // ==========================================
                                // SALVAR
                                // ==========================================

                                _botao(
                                  texto:
                                      'Salvar família',

                                  aoClicar:
                                      salvando
                                          ? null
                                          : salvarFamilia,

                                  carregando:
                                      salvando,
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                // ==========================================
                                // LIMPAR
                                // ==========================================

                                _botao(
                                  texto:
                                      'Limpar formulário',

                                  aoClicar:
                                      salvando
                                          ? null
                                          : limparFormulario,
                                ),
                              ],
                            ),
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