import 'package:flutter/material.dart';

class LotacaoScreen extends StatelessWidget {
  final String bairro;

  const LotacaoScreen({
    super.key,
    required this.bairro,
  });

  @override
  Widget build(BuildContext context) {
    // Valores fictícios de lotação
    final List<Map<String, dynamic>> faixasEtarias = [
      {
        'idade': 'Até 2 anos',
        'lotacao': 30,
      },
      {
        'idade': '3 a 9 anos',
        'lotacao': 18,
      },
      {
        'idade': '10 a 12 anos',
        'lotacao': 12,
      },
      {
        'idade': '13 a 17 anos',
        'lotacao': 15,
      },
      {
        'idade': '18 a 59 anos',
        'lotacao': 42,
      },
      {
        'idade': 'A partir de 60 anos',
        'lotacao': 20,
      },
    ];

    // Cor padrão usada nos cards/botões
    const Color corPadrao = Color(0xFFE2E8FF);

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
            // Logo
            Image.asset(
              'assets/logo.png',
              height: 42,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 42,
                  height: 42,
                );
              },
            ),

            const Spacer(),

            // Menu
            const Icon(
              Icons.menu,
              color: Colors.black87,
              size: 26,
            ),

            const SizedBox(width: 10),

            // Perfil
            const Icon(
              Icons.person_outline,
              color: Colors.black87,
              size: 27,
            ),
          ],
        ),
      ),

      // =========================
      // CORPO
      // =========================
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFE2E8FF),

        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 55),

              // =========================
              // BAIRRO SELECIONADO
              // =========================
              Container(
                width: 192,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  bairro,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 33),

              // =========================
              // TABELA
              // =========================
              SizedBox(
                width: 266,
                child: Column(
                  children: [
                    // =========================
                    // CABEÇALHO
                    // =========================
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
                          // IDADE
                          const Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                'IDADE',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),

                          // Divisória
                          Container(
                            width: 1,
                            color: const Color(0xFFFF6A45),
                          ),

                          // LOTAÇÃO
                          const Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'LOTAÇÃO',
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

                    // =========================
                    // LINHAS DA TABELA
                    // =========================
                    ...faixasEtarias.map(
                      (faixa) {
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
                              // =========================
                              // IDADE
                              // =========================
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    faixa['idade'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              // =========================
                              // DIVISÓRIA
                              // =========================
                              Container(
                                width: 1,
                                height: double.infinity,
                                color: const Color(0xFFFF6A45),
                              ),

                              // =========================
                              // LOTAÇÃO
                              // =========================
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
                                      '${faixa['lotacao']}',
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
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}