import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../widgets/cabecalho.dart';
import 'bairro_screen.dart';

class ControleScreen extends StatefulWidget {
  final Cidade cidade;

  const ControleScreen({
    super.key,
    required this.cidade,
  });

  @override
  State<ControleScreen> createState() => _ControleScreenState();
}

class _ControleScreenState extends State<ControleScreen> {
  String? bairroSelecionado;

  List<String> bairrosDaCidade(String nomeCidade) {
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

  void abrirBairro(String bairro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BairroScreen(
          cidade: widget.cidade,
          bairro: bairro,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bairros = bairrosDaCidade(widget.cidade.nome);

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
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 48,
                      left: 34,
                      right: 34,
                    ),
                    child: Column(
                      children: [
                        // CIDADE
                        SizedBox(
                          width: double.infinity,
                          height: 31,
                          child: Container(
                            decoration: BoxDecoration(
                              // CARD BRANCO TRANSPARENTE
                              color: Colors.white.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: Colors.black87,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.cidade.nome,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // SELEÇÃO DO BAIRRO
                        SizedBox(
                          width: 157,
                          height: 31,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              // CARD BRANCO TRANSPARENTE
                              color: Colors.white.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: bairros.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Nenhum abrigo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: bairroSelecionado,
                                      hint: const Text(
                                        'Abrigos',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Colors.black87,
                                      ),
                                      dropdownColor: Colors.white,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 11,
                                      ),
                                      items: bairros.map((bairro) {
                                        return DropdownMenuItem<String>(
                                          value: bairro,
                                          child: Text(
                                            bairro,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (valor) {
                                        if (valor == null) return;

                                        setState(() {
                                          bairroSelecionado = valor;
                                        });
                                        abrirBairro(valor);
                                      },
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
          ],
        ),
      ),
    );
  }
}