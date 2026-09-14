import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cidade.dart';
import '../widgets/cabecalho.dart';
import '../services/acesso_admin.dart';

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

class _LotacaoScreenState extends State<LotacaoScreen>
    with WidgetsBindingObserver {
  LotacaoInfo? lotacao;
  bool carregando = true;

  static const Color corPadrao = Color(0xFFE2E8FF);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    carregarLotacao();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // ============================================================
  // ATUALIZA A LOTAÇÃO QUANDO O APP VOLTA PARA A TELA
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      carregarLotacao();
    }
  }

  // ============================================================
  // CARREGAR LOTAÇÃO
  // ============================================================

  Future<void> carregarLotacao() async {
    if (!mounted) return;

    setState(() {
      carregando = true;
    });

    try {
      final resultado =
          await DatabaseHelper.instance.buscarLotacao(
        cidadeId: widget.cidade.id!,
        bairro: widget.bairro,
      );

      if (!mounted) return;

      setState(() {
        lotacao = resultado;
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
            'Erro ao carregar lotação: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EDITAR CAPACIDADE MÁXIMA
  // ============================================================
  //
  // Só admins logados (com cadastro completo) podem alterar
  // esse número.
  //
  // Se ninguém estiver logado, exigirAcessoAdmin abre a tela
  // de login.
  //
  // Depois que o login for realizado, o LoginScreen retorna
  // para esta tela e o diálogo de capacidade é aberto.
  // ============================================================

  Future<void> editarCapacidade() async {
    // Verifica se existe um usuário autorizado.
    final podeAcessar = await exigirAcessoAdmin(context);

    if (!podeAcessar || !mounted) return;

    final controller = TextEditingController(
      text: '${lotacao?.capacidade ?? 100}',
    );

    final novaCapacidade = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        String? erro;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Capacidade máxima',
              ),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nova capacidade',
                  errorText: erro,
                ),
                onChanged: (_) {
                  if (erro != null) {
                    setDialogState(() {
                      erro = null;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancelar',
                  ),
                ),

                // ==================================================
                // BOTÃO SALVAR
                // ==================================================
                //
                // Mantém o mesmo estilo, mas com tamanho menor.
                // ==================================================

                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      final valor =
                          int.tryParse(controller.text.trim());

                      if (valor == null || valor < 0) {
                        setDialogState(() {
                          erro = 'Informe um número válido';
                        });

                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        valor,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 36),
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (novaCapacidade == null || !mounted) return;

    // ============================================================
    // SALVAR NOVA CAPACIDADE
    // ============================================================

    try {
      await DatabaseHelper.instance.salvarCapacidadeAbrigo(
        cidadeId: widget.cidade.id!,
        bairro: widget.bairro,
        capacidade: novaCapacidade,
      );

      if (!mounted) return;

      // Recarrega os dados para atualizar:
      // - capacidade máxima
      // - vagas disponíveis
      await carregarLotacao();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Capacidade máxima atualizada com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar capacidade: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // LINHA DO RESUMO
  // ============================================================
  //
  // O SizedBox reservado no final (com ou sem ícone) garante que
  // os quadrados de valor fiquem sempre na mesma coluna, retos
  // um em cima do outro, independente de a linha ter ou não o
  // ícone de editar.
  // ============================================================

  Widget _linhaResumo(
    String titulo,
    int valor, {
    bool destaqueNegativo = false,
    VoidCallback? onEditar,
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

          // Espaço reservado (com ou sem ícone) para manter o
          // alinhamento dos quadrados em todas as linhas.
          SizedBox(
            width: 22,
            height: 26,
            child: onEditar == null
                ? null
                : Center(
                    child: InkWell(
                      onTap: onEditar,
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8FF),
      body: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // CABEÇALHO
            // ====================================================

            const Cabecalho(),

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

                  carregando
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : RefreshIndicator(
                          onRefresh: carregarLotacao,
                          child: SingleChildScrollView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),

                                  // ==================================
                                  // BAIRRO SELECIONADO
                                  // ==================================

                                  Container(
                                    width: 290,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black87,
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // ==================================
                                  // RESUMO
                                  // ==================================

                                  SizedBox(
                                    width: 266,
                                    child: Column(
                                      children: [
                                        _linhaResumo(
                                          'CAPACIDADE MÁXIMA',
                                          lotacao!.capacidade,
                                          onEditar:
                                              editarCapacidade,
                                        ),

                                        _linhaResumo(
                                          'PESSOAS ACOLHIDAS',
                                          lotacao!.ocupacao,
                                        ),

                                        _linhaResumo(
                                          'VAGAS DISPONÍVEIS',
                                          lotacao!.vagasDisponiveis,
                                          destaqueNegativo:
                                              lotacao!.vagasDisponiveis <
                                                  0,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // ==================================
                                  // TABELA POR FAIXA ETÁRIA
                                  // ==================================
                                  //
                                  // Largura aumentada (266 -> 274) e
                                  // margem interna reduzida (6 -> 3)
                                  // para o bloco terminar alinhado com
                                  // os quadrados do resumo acima.
                                  // ==================================

                                  SizedBox(
                                    width: 274,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(0.55),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: Column(
                                        children: [
                                          // ============================
                                          // CABEÇALHO DA TABELA
                                          // ============================

                                          Container(
                                            height: 28,
                                            decoration:
                                                const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color:
                                                      Color(0xFFFF6A45),
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
                                                        color: Colors
                                                            .black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Container(
                                                  width: 1,
                                                  color:
                                                      const Color(
                                                    0xFFFF6A45,
                                                  ),
                                                ),

                                                const Expanded(
                                                  flex: 2,
                                                  child: Center(
                                                    child: Text(
                                                      'OCUPAÇÃO',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // ============================
                                          // FAIXAS ETÁRIAS
                                          //
                                          // A ORDEM É A MESMA DO BANCO.
                                          // ============================

                                          ...DatabaseHelper
                                              .ordemFaixasEtarias
                                              .map(
                                            (faixa) {
                                              final quantidade =
                                                  lotacao!
                                                          .porFaixaEtaria[
                                                      faixa] ??
                                                  0;

                                              return Container(
                                                height: 65,
                                                decoration:
                                                    const BoxDecoration(
                                                  border: Border(
                                                    bottom:
                                                        BorderSide(
                                                      color: Color(
                                                        0xFFFF6A45,
                                                      ),
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
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .black87,
                                                          ),
                                                          textAlign:
                                                              TextAlign
                                                                  .center,
                                                        ),
                                                      ),
                                                    ),

                                                    Container(
                                                      width: 1,
                                                      height:
                                                          double.infinity,
                                                      color:
                                                          const Color(
                                                        0xFFFF6A45,
                                                      ),
                                                    ),

                                                    Expanded(
                                                      flex: 2,
                                                      child: Center(
                                                        child:
                                                            Container(
                                                          width: 43,
                                                          height: 26,
                                                          alignment:
                                                              Alignment
                                                                  .center,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: corPadrao
                                                                .withOpacity(
                                                              0.85,
                                                            ),
                                                            border:
                                                                Border.all(
                                                              color:
                                                                  const Color(
                                                                0xFF7A82B5,
                                                              ),
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              7,
                                                            ),
                                                            boxShadow:
                                                                const [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius:
                                                                    2,
                                                                offset:
                                                                    Offset(
                                                                  1,
                                                                  2,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Text(
                                                            '$quantidade',
                                                            style:
                                                                const TextStyle(
                                                              fontSize:
                                                                  12,
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
                                            },
                                          ),
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