import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cidade.dart';
import '../widgets/cabecalho.dart';

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

  static const Color corPadrao = Color(0xFFE2E8FF);

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

  Widget _linhaResumo(
    String titulo,
    int valor, {
    bool destaqueNegativo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: 50,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: destaqueNegativo
                  ? Colors.red[100]
                  : corPadrao.withOpacity(0.85),
              // CORRIGIDO: BorderSide não tem método toBorder().
              // Para um contorno uniforme (mesma cor/largura nos
              // 4 lados) o certo é usar Border.all(...).
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
              '$valor',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
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
                      : RefreshIndicator(
                          onRefresh: carregarLotacao,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),

                                  // BAIRRO SELECIONADO
                                  Container(
                                    width: 192,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      // CARD BRANCO TRANSPARENTE
                                      color: Colors.white.withOpacity(0.75),
                                      border: Border.all(
                                        color: Colors.black87,
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
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.bairro,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // RESUMO
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
                                          destaqueNegativo:
                                              lotacao!.vagasDisponiveis < 0,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // TABELA POR FAIXA ETÁRIA
                                  SizedBox(
                                    width: 266,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        // CARD BRANCO TRANSPARENTE
                                        color: Colors.white.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Column(
                                        children: [
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
                                            child: Row(
                                              children: [
                                                const Expanded(
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
                                                Container(
                                                  width: 1,
                                                  color:
                                                      const Color(0xFFFF6A45),
                                                ),
                                                const Expanded(
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
                                          ...DatabaseHelper.ordemFaixasEtarias
                                              .map((faixa) {
                                            final quantidade =
                                                lotacao!.porFaixaEtaria[faixa] ??
                                                    0;

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
                                                          color:
                                                              Colors.black87,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 1,
                                                    height: double.infinity,
                                                    color:
                                                        const Color(0xFFFF6A45),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: Container(
                                                        width: 43,
                                                        height: 26,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: corPadrao
                                                              .withOpacity(
                                                                  0.85),
                                                          border: Border.all(
                                                            color: const Color(
                                                                0xFF7A82B5),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              blurRadius: 2,
                                                              offset:
                                                                  Offset(1, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          '$quantidade',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .black87,
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
                                  ),

                                  const SizedBox(height: 30),
                                ],
                              ),
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