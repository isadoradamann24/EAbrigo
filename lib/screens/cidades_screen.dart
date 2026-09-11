import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../services/banco_service.dart';
import '../widgets/cabecalho.dart';
import 'controle_screen.dart';

class CidadesScreen extends StatefulWidget {
  const CidadesScreen({super.key});

  @override
  State<CidadesScreen> createState() => _CidadesScreenState();
}

class _CidadesScreenState extends State<CidadesScreen> {
  final BancoService banco = BancoService();

  List<Cidade> cidades = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarCidades();
  }

  Future<void> carregarCidades() async {
    setState(() => carregando = true);

    final resultado = await banco.listarCidades();

    if (!mounted) return;

    setState(() {
      cidades = resultado;
      carregando = false;
    });
  }

  void selecionarCidade(Cidade cidade) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ControleScreen(cidade: cidade)),
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
            // CABEÇALHO (logo + menu + login)
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

                  carregando
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: carregarCidades,
                          child: cidades.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 150),
                                    Center(
                                      child: Text(
                                        'Nenhuma cidade cadastrada.',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                    top: 30,
                                    bottom: 60,
                                  ),
                                  itemCount: cidades.length,
                                  itemBuilder: (context, index) {
                                    final cidade = cidades[index];

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: Center(
                                        child: SizedBox(
                                          width: 195,
                                          height: 34,
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                selecionarCidade(cidade),
                                            style: OutlinedButton.styleFrom(
                                              // CARD BRANCO TRANSPARENTE
                                              // (deixa a marca d'água
                                              // aparecer por trás)
                                              backgroundColor:
                                                  Colors.white.withOpacity(
                                                0.75,
                                              ),
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
                                              cidade.nome,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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