import 'package:flutter/material.dart';

import '../models/familia.dart';

class FamiliaDetalhesScreen extends StatelessWidget {
  final Familia familia;

  const FamiliaDetalhesScreen({
    super.key,
    required this.familia,
  });

  // ==========================================================
  // CAMPO DE INFORMAÇÃO
  // ==========================================================

  Widget _informacao({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 20,
            color: Colors.black87,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  valor.isEmpty ? 'Não informado' : valor,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),

            // ==================================================
            // CONTEÚDO
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
                              // TÍTULO
                              // ==========================================

                              Container(
                                width: double.infinity,
                                height: 36,
                                alignment: Alignment.center,

                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(
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

                                child: Text(
                                  familia.responsavel,
                                  textAlign:
                                      TextAlign.center,

                                  style:
                                      const TextStyle(
                                    fontSize: 14,
                                    color:
                                        Colors.black87,
                                    fontWeight:
                                        FontWeight.normal,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              const Text(
                                'Informações da família',
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

                              _informacao(
                                titulo:
                                    'Responsável',
                                valor:
                                    familia.responsavel,
                                icone:
                                    Icons.person_outline,
                              ),

                              // ==========================================
                              // BAIRRO
                              // ==========================================

                              _informacao(
                                titulo:
                                    'Bairro',
                                valor:
                                    familia.bairro,
                                icone:
                                    Icons.location_on_outlined,
                              ),

                              // ==========================================
                              // ENDEREÇO
                              // ==========================================

                              _informacao(
                                titulo:
                                    'Endereço',
                                valor:
                                    familia.endereco,
                                icone:
                                    Icons.home_outlined,
                              ),

                              // ==========================================
                              // TELEFONE
                              // ==========================================

                              _informacao(
                                titulo:
                                    'Telefone',
                                valor:
                                    familia.telefone,
                                icone:
                                    Icons.phone_outlined,
                              ),

                              // ==========================================
                              // DATA
                              // ==========================================

                              _informacao(
                                titulo:
                                    'Data do cadastro',
                                valor:
                                    familia.dataCadastro,
                                icone:
                                    Icons.calendar_today_outlined,
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