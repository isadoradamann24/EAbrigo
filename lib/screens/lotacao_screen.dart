import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cidade.dart';

class LotacaoScreen extends StatefulWidget {
  final Cidade cidade;
  final String bairro;

  const LotacaoScreen({
    super.key,
    required this.cidade,
    required this.bairro,
  });

  @override
  State<LotacaoScreen> createState() => _LotacaoScreenState();
}

class _LotacaoScreenState extends State<LotacaoScreen> {
  LotacaoInfo? lotacao;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarLotacao();
  }

  Future<void> carregarLotacao() async {
    setState(() {
      carregando = true;
    });

    final resultado = await DatabaseHelper.instance.buscarLotacao(
      cidadeId: widget.cidade.id!,
      bairro: widget.bairro,
    );

    if (!mounted) return;

    setState(() {
      lotacao = resultado;
      carregando = false;
    });
  }

  // Cor padrão usada nos cards/botões
  static const Color corPadrao = Color(0xFFE2E8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8FF),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'imgs/logo.png',
              height: 42,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(width: 42, height: 42);
              },
            ),
            const Spacer(),
            const Icon(Icons.menu, color: Colors.black87, size: 26),
            const SizedBox(width: 10),
            const Icon(Icons.person_outline, color: Colors.black87, size: 27),
          ],
        ),
      ),

      // =========================
      // CORPO
      // =========================
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 55),

                    // =========================
                    // ABRIGO SELECIONADO
                    // =========================
                    Container(
                      width: 192,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black87, width: 1),
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
                        widget.bairro,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =========================
                    // RESUMO: CAPACIDADE / ACOLHIDAS / VAGAS
                    // =========================
                    SizedBox(
                      width: 266,
                      child: Column(
                        children: [
                          _linhaResumo(
                            'CAPACIDADE MÁXIMA',
                            lotacao!.capacidade,
                          ),
                          _linhaResumo(
                            'PESSOAS ACOLHIDAS',
                            lotacao!.ocupacao,
                          ),
                          _linhaResumo(
                            'VAGAS DISPONÍVEIS',
                            lotacao!.vagasDisponiveis,
                            destaqueNegativo: lotacao!.vagasDisponiveis < 0,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =========================
                    // TABELA POR FAIXA ETÁRIA
                    // =========================
                    SizedBox(
                      width: 266,
                      child: Column(
                        children: [
                          // CABEÇALHO
                          Container(
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFFF6A45),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      'FAIXA ETÁRIA',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 1,
                                  child: ColoredBox(color: Color(0xFFFF6A45)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      'OCUPAÇÃO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // LINHAS
                          ...DatabaseHelper.ordemFaixasEtarias.map((faixa) {
                            final quantidade = lotacao!.porFaixaEtaria[faixa] ?? 0;

                            return Container(
                              height: 65,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFFF6A45),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Text(
                                        faixa,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: double.infinity,
                                    color: const Color(0xFFFF6A45),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Container(
                                        width: 43,
                                        height: 26,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: corPadrao,
                                          border: Border.all(
                                            color: const Color(0xFF7A82B5),
                                            width: 1,
                                          ),
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
                                          '$quantidade',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _linhaResumo(String titulo, int valor, {bool destaqueNegativo = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Container(
            width: 50,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: destaqueNegativo ? Colors.red[100] : corPadrao,
              border: Border.all(color: const Color(0xFF7A82B5), width: 1),
              borderRadius: BorderRadius.circular(7),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2)),
              ],
            ),
            child: Text(
              '$valor',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}