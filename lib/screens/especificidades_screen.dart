import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cidade.dart';
import '../widgets/cabecalho.dart';

class EspecificidadesScreen extends StatefulWidget {
  final Cidade cidade;
  final String bairro;

  const EspecificidadesScreen({
    super.key,
    required this.cidade,
    required this.bairro,
  });

  @override
  State<EspecificidadesScreen> createState() =>
      _EspecificidadesScreenState();
}

class _EspecificidadesScreenState
    extends State<EspecificidadesScreen> {
  List<EspecificidadeFamilia> especificidades = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();

    carregarEspecificidades();
  }


  // CARREGAR ESPECIFICIDADES


  Future<void> carregarEspecificidades() async {
    if (!mounted) return;

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resultado =
          await DatabaseHelper.instance.buscarEspecificidades(
        cidadeId: widget.cidade.id!,
        bairro: widget.bairro,
      );

      if (!mounted) return;

      setState(() {
        especificidades = resultado;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Erro ao carregar especificidades: $e';
      });
    }
  }


  // TAG DE UMA NECESSIDADE (comorbidade / deficiência / medicação)


  Widget _tag(String rotulo, String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8FF),
        border: Border.all(
          color: const Color(0xFF7A82B5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$rotulo: $valor',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }


  // CARD DE CADA FAMÍLIA COM NECESSIDADE


  Widget _cardFamilia(EspecificidadeFamilia item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border.all(
          color: Colors.black87,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.responsavel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          if (item.comorbidade != null)
            _tag('Comorbidade', item.comorbidade!),

          if (item.deficiencia != null)
            _tag('Deficiência', item.deficiencia!),

          if (item.medicacaoContinua != null)
            _tag('Medicação contínua', item.medicacaoContinua!),
        ],
      ),
    );
  }


  // TELA


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8FF),
      body: SafeArea(
        child: Column(
          children: [
          
            // CABEÇALHO
          

            const Cabecalho(),

          
            // TÍTULO DA TELA + VOLTAR
          

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'Especificidades — ${widget.bairro}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Espaço reservado do mesmo tamanho do botão
                  // de voltar, pra manter o título centralizado.
                  const SizedBox(width: 48),
                ],
              ),
            ),

          
            // CONTEÚDO
          

            Expanded(
              child: carregando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : erro != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  erro!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: carregarEspecificidades,
                                  child: const Text(
                                    'Tentar novamente',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : especificidades.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Nenhuma pessoa com comorbidade, '
                                  'deficiência ou uso contínuo de '
                                  'medicação cadastrada no bairro '
                                  '${widget.bairro}.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: carregarEspecificidades,
                              child: ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                itemCount: especificidades.length,
                                itemBuilder: (context, index) {
                                  return _cardFamilia(
                                    especificidades[index],
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}