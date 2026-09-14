import 'package:flutter/material.dart';

import '../models/familia.dart';
import '../models/membro_familia.dart';
import '../services/banco_service.dart';
import '../widgets/cabecalho.dart';
import '../database/database_helper.dart';

class FamiliaDetalhesScreen extends StatefulWidget {
  final Familia familia;

  const FamiliaDetalhesScreen({
    super.key,
    required this.familia,
  });

  @override
  State<FamiliaDetalhesScreen> createState() =>
      _FamiliaDetalhesScreenState();
}

class _FamiliaDetalhesScreenState
    extends State<FamiliaDetalhesScreen> {
  final BancoService banco = BancoService();

  final _formKey = GlobalKey<FormState>();

  late Familia familia;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final nacionalidadeController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();

  final qualBeneficioOutroController =
      TextEditingController();

  final qualAposentadoOutroController =
      TextEditingController();

  final qualComorbidadeController =
      TextEditingController();

  final qualMedicacaoController =
      TextEditingController();

  final qualDeficienciaController =
      TextEditingController();

  final quaisDocumentosController =
      TextEditingController();

  final obsController = TextEditingController();

  // ============================================================
  // DADOS
  // ============================================================

  DateTime? dataNascimento;
  DateTime dataCadastro = DateTime.now();

  bool editando = false;
  bool salvando = false;
  bool excluindo = false;
  bool carregandoMembros = true;

  String? etnia;
  String? identidadeGenero;
  String? situacaoTrabalho;
  String? rendaMensal;

  String? cadastroUnico;

  String? recebeBeneficio;
  String? qualBeneficio;

  String? aposentadoPensionista;
  String? qualAposentado;

  String? possuiComorbidade;
  String? usoMedicacaoContinuo;
  String? possuiDeficiencia;

  String? houvePerdasMateriais;
  final Set<String> perdasMateriaisSelecionadas = {};

  String? houvePerdaDocumentacao;

  final List<MembroFamilia> membros = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    familia = widget.familia;

    _preencherFormulario();
    _carregarMembros();
  }

  // ============================================================
  // PREENCHER FORMULÁRIO
  // ============================================================

  void _preencherFormulario() {
    nomeController.text = familia.responsavel;
    enderecoController.text = familia.endereco;
    nacionalidadeController.text = familia.nacionalidade;
    cpfController.text = familia.cpf;
    telefoneController.text = familia.telefone;

    qualBeneficioOutroController.text =
        familia.qualBeneficioAssistenciaOutro;

    qualAposentadoOutroController.text =
        familia.qualAposentadoPensionistaOutro;

    qualComorbidadeController.text =
        familia.qualComorbidade;

    qualMedicacaoController.text =
        familia.qualMedicacao;

    qualDeficienciaController.text =
        familia.qualDeficiencia;

    quaisDocumentosController.text =
        familia.quaisDocumentosPerdidos;

    obsController.text = familia.obs;

    dataNascimento =
        _converterData(familia.dataNascimento);

    dataCadastro =
        _converterData(familia.dataCadastro) ??
            DateTime.now();

    etnia = familia.etnia.isEmpty
        ? null
        : familia.etnia;

    identidadeGenero =
        familia.identidadeGenero.isEmpty
            ? null
            : familia.identidadeGenero;

    situacaoTrabalho =
        familia.situacaoTrabalho.isEmpty
            ? null
            : familia.situacaoTrabalho;

    rendaMensal =
        familia.rendaMensal.isEmpty
            ? null
            : familia.rendaMensal;

    cadastroUnico =
        familia.cadastroUnico.isEmpty
            ? null
            : familia.cadastroUnico;

    recebeBeneficio =
        familia.recebeBeneficioAssistencia.isEmpty
            ? null
            : familia.recebeBeneficioAssistencia;

    qualBeneficio =
        familia.qualBeneficioAssistencia.isEmpty
            ? null
            : familia.qualBeneficioAssistencia;

    aposentadoPensionista =
        familia.aposentadoPensionista.isEmpty
            ? null
            : familia.aposentadoPensionista;

    qualAposentado =
        familia.qualAposentadoPensionista.isEmpty
            ? null
            : familia.qualAposentadoPensionista;

    possuiComorbidade =
        familia.possuiComorbidade.isEmpty
            ? null
            : familia.possuiComorbidade;

    usoMedicacaoContinuo =
        familia.usoMedicacaoContinuo.isEmpty
            ? null
            : familia.usoMedicacaoContinuo;

    possuiDeficiencia =
        familia.possuiDeficiencia.isEmpty
            ? null
            : familia.possuiDeficiencia;

    houvePerdasMateriais =
        familia.houvePerdasMateriais.isEmpty
            ? null
            : familia.houvePerdasMateriais;

    houvePerdaDocumentacao =
        familia.houvePerdaDocumentacao.isEmpty
            ? null
            : familia.houvePerdaDocumentacao;

    perdasMateriaisSelecionadas.clear();

    if (familia.quaisPerdasMateriais.trim().isNotEmpty) {
      perdasMateriaisSelecionadas.addAll(
        familia.quaisPerdasMateriais
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      );
    }
  }

  DateTime? _converterData(String valor) {
    if (valor.trim().isEmpty) {
      return null;
    }

    try {
      final partes = valor.split('/');

      if (partes.length == 3) {
        return DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
      }

      return DateTime.tryParse(valor);
    } catch (_) {
      return null;
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  // ============================================================
  // MEMBROS
  // ============================================================

  Future<void> _carregarMembros() async {
    if (familia.id == null) {
      setState(() {
        carregandoMembros = false;
      });
      return;
    }

    try {
      final lista =
          await banco.listarMembros(familia.id!);

      if (!mounted) return;

      setState(() {
        membros.clear();
        membros.addAll(lista);
        carregandoMembros = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        carregandoMembros = false;
      });
    }
  }

  Future<void> abrirDialogoMembro() async {
    if (!editando) return;

    final nomeMembroController =
        TextEditingController();

    final idadeMembroController =
        TextEditingController();

    final escolaridadeMembroController =
        TextEditingController();

    String? parentesco;
    String? identidadeGeneroMembro;

    final resultado =
        await showDialog<MembroFamilia>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Adicionar membro',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    TextField(
                      controller:
                          nomeMembroController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Nome completo',
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value: parentesco,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Parentesco',
                      ),
                      items: const [
                        'Marido',
                        'Esposa',
                        'Companheiro/a',
                        'Filho/a',
                        'Pai',
                        'Mãe',
                        'Avô/Avó',
                        'Outro',
                      ].map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        setDialogState(() {
                          parentesco =
                              valor;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextField(
                      controller:
                          idadeMembroController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText: 'Idade',
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextField(
                      controller:
                          escolaridadeMembroController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Escolaridade',
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value:
                          identidadeGeneroMembro,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Identidade de gênero',
                      ),
                      items: const [
                        'Feminino',
                        'Masculino',
                        'Mulher trans',
                        'Homem trans',
                        'Não-binário',
                      ].map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        setDialogState(() {
                          identidadeGeneroMembro =
                              valor;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nomeMembroController
                        .text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    Navigator.pop(
                      context,
                      MembroFamilia(
                        nome:
                            nomeMembroController
                                .text
                                .trim(),
                        parentesco:
                            parentesco ?? '',
                        idade:
                            int.tryParse(
                                  idadeMembroController
                                      .text
                                      .trim(),
                                ) ??
                                0,
                        escolaridade:
                            escolaridadeMembroController
                                .text
                                .trim(),
                        identidadeGenero:
                            identidadeGeneroMembro ??
                                '',
                      ),
                    );
                  },
                  child:
                      const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    nomeMembroController.dispose();
    idadeMembroController.dispose();
    escolaridadeMembroController.dispose();

    if (resultado != null) {
      setState(() {
        membros.add(resultado);
      });
    }
  }

  void removerMembro(int index) {
    if (!editando) return;

    setState(() {
      membros.removeAt(index);
    });
  }

  // ============================================================
  // EDITAR
  // ============================================================

  void iniciarEdicao() {
    setState(() {
      editando = true;
    });
  }

  // ============================================================
  // CANCELAR
  // ============================================================

  Future<void> cancelarEdicao() async {
    _preencherFormulario();

    setState(() {
      editando = false;
      carregandoMembros = true;
    });

    await _carregarMembros();
  }

  // ============================================================
  // SALVAR ALTERAÇÕES
  // ============================================================

  Future<void> salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    final familiaAtualizada = Familia(
      id: familia.id,
      cidadeId: familia.cidadeId,
      responsavel:
          nomeController.text.trim(),
      bairro: familia.bairro,
      endereco:
          enderecoController.text.trim(),
      telefone:
          telefoneController.text.trim(),
      dataCadastro:
          _formatarData(dataCadastro),
      dataNascimento:
          dataNascimento != null
              ? _formatarData(dataNascimento!)
              : '',
      nacionalidade:
          nacionalidadeController.text.trim(),
      cpf: cpfController.text.trim(),
      etnia: etnia ?? '',
      identidadeGenero:
          identidadeGenero ?? '',
      situacaoTrabalho:
          situacaoTrabalho ?? '',
      rendaMensal:
          rendaMensal ?? '',
      cadastroUnico:
          cadastroUnico ?? '',
      recebeBeneficioAssistencia:
          recebeBeneficio ?? '',
      qualBeneficioAssistencia:
          qualBeneficio ?? '',
      qualBeneficioAssistenciaOutro:
          qualBeneficioOutroController
              .text
              .trim(),
      aposentadoPensionista:
          aposentadoPensionista ?? '',
      qualAposentadoPensionista:
          qualAposentado ?? '',
      qualAposentadoPensionistaOutro:
          qualAposentadoOutroController
              .text
              .trim(),
      possuiComorbidade:
          possuiComorbidade ?? '',
      qualComorbidade:
          qualComorbidadeController
              .text
              .trim(),
      usoMedicacaoContinuo:
          usoMedicacaoContinuo ?? '',
      qualMedicacao:
          qualMedicacaoController
              .text
              .trim(),
      possuiDeficiencia:
          possuiDeficiencia ?? '',
      qualDeficiencia:
          qualDeficienciaController
              .text
              .trim(),
      houvePerdasMateriais:
          houvePerdasMateriais ?? '',
      quaisPerdasMateriais:
          perdasMateriaisSelecionadas
              .join(', '),
      houvePerdaDocumentacao:
          houvePerdaDocumentacao ?? '',
      quaisDocumentosPerdidos:
          quaisDocumentosController
              .text
              .trim(),
      obs: obsController.text.trim(),
    );

    try {
      await banco.atualizarFamiliaCompleta(
        familiaAtualizada,
        membros,
      );

      if (!mounted) return;

      setState(() {
        familia = familiaAtualizada;
        editando = false;
        salvando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Família atualizada com sucesso!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao atualizar família: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EXCLUIR
  // ============================================================

  Future<void> excluirFamilia() async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir família',
          ),
          content: Text(
            'Tem certeza que deseja excluir a família de ${familia.responsavel}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    setState(() {
      excluindo = true;
    });

    try {
      final db =
          await DatabaseHelper.instance.database;

      await db.delete(
        'familias',
        where: 'id = ?',
        whereArgs: [familia.id],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Família excluída com sucesso!',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        excluindo = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao excluir família: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DATA
  // ============================================================

  Future<void> selecionarDataNascimento() async {
    if (!editando) return;

    final data =
        await showDatePicker(
      context: context,
      initialDate:
          dataNascimento ??
              DateTime(2000),
      firstDate:
          DateTime(1900),
      lastDate:
          DateTime.now(),
    );

    if (data != null) {
      setState(() {
        dataNascimento = data;
      });
    }
  }

  // ============================================================
  // COMPONENTES - MESMO DESIGN DO FAMILIA_SCREEN
  // ============================================================

  Widget _cardPergunta(Widget child) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 14),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _campo({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.75),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        enabled: editando,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          prefixIcon: Icon(
            icon,
            size: 19,
            color: Colors.black87,
          ),
          border:
              InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
        ),
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
        top: 4,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight:
              FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _pergunta(String texto) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 4,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _grupoOpcoes({
    required String pergunta,
    required List<String> opcoes,
    required String? valor,
    required ValueChanged<String?> onChanged,
  }) {
    return _cardPergunta(
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _pergunta(pergunta),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            children:
                opcoes.map((opcao) {
              return SizedBox(
                width: opcao.length > 18
                    ? double.infinity
                    : 165,
                child:
                    RadioListTile<
                        String>(
                  value: opcao,
                  groupValue: valor,
                  onChanged:
                      editando
                          ? onChanged
                          : null,
                  dense: true,
                  contentPadding:
                      EdgeInsets.zero,
                  visualDensity:
                      VisualDensity
                          .compact,
                  title: Text(
                    opcao,
                    style:
                        const TextStyle(
                      fontSize: 12.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _grupoSimNao({
    required String pergunta,
    required String? valor,
    required ValueChanged<String?> onChanged,
  }) {
    return _cardPergunta(
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _pergunta(pergunta),
          Row(
            children:
                ['Sim', 'Não']
                    .map(
              (opcao) {
                return Expanded(
                  child:
                      RadioListTile<
                          String>(
                    value: opcao,
                    groupValue: valor,
                    onChanged:
                        editando
                            ? onChanged
                            : null,
                    dense: true,
                    contentPadding:
                        EdgeInsets.zero,
                    visualDensity:
                        VisualDensity
                            .compact,
                    title: Text(
                      opcao,
                      style:
                          const TextStyle(
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _grupoCheckbox({
    required String pergunta,
    required List<String> opcoes,
    required Set<String> selecionados,
    required VoidCallback onChanged,
  }) {
    return _cardPergunta(
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _pergunta(pergunta),
          ...opcoes.map(
            (opcao) {
              return CheckboxListTile(
                value: selecionados
                    .contains(opcao),
                onChanged:
                    editando
                        ? (marcado) {
                            if (marcado ==
                                true) {
                              selecionados
                                  .add(
                                      opcao);
                            } else {
                              selecionados
                                  .remove(
                                      opcao);
                            }

                            onChanged();
                          }
                        : null,
                dense: true,
                contentPadding:
                    EdgeInsets.zero,
                controlAffinity:
                    ListTileControlAffinity
                        .leading,
                visualDensity:
                    VisualDensity
                        .compact,
                title: Text(
                  opcao,
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _campoData({
    required String label,
    required DateTime? data,
    required VoidCallback onTap,
  }) {
    return _cardPergunta(
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _pergunta(label),
          InkWell(
            onTap:
                editando
                    ? onTap
                    : null,
            child: Container(
              width: double.infinity,
              height: 45,
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(
                        0.85),
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
                    color:
                        Colors.black87,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    data != null
                        ? _formatarData(
                            data,
                          )
                        : 'Selecionar data',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD DOS MEMBROS - MESMO MODELO
  // ============================================================

  Widget _cardMembro(int index) {
    final membro =
        membros[index];

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white
            .withOpacity(0.75),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset:
                Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color: const Color(
                0xFFE2E8FF,
              ).withOpacity(0.85),
              borderRadius:
                  const BorderRadius
                      .only(
                topLeft:
                    Radius.circular(
                  12,
                ),
                topRight:
                    Radius.circular(
                  12,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${index + 1} - ${membro.nome}',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
                if (editando)
                  InkWell(
                    onTap: () =>
                        removerMembro(
                            index),
                    child:
                        const Icon(
                      Icons.close,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(
              12,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Parentesco: ${membro.parentesco}',
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  'Idade: ${membro.idade}',
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  'Escolaridade: ${membro.escolaridade}',
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  'Id. de Gênero: ${membro.identidadeGenero}',
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTÃO
  //
  // "width" é opcional (default = ocupa a largura toda). Passar
  // um valor menor deixa o botão específico mais compacto sem
  // afetar os outros que usam este mesmo componente.
  // ============================================================

  Widget _botao({
    required String texto,
    required VoidCallback? aoClicar,
    bool carregando = false,
    double width = double.infinity,
  }) {
    return SizedBox(
      width: width,
      height: 38,
      child: OutlinedButton(
        onPressed: aoClicar,
        style:
            OutlinedButton.styleFrom(
          backgroundColor:
              const Color(
            0xFFE2E8FF,
          ),
          foregroundColor:
              Colors.black,
          padding:
              EdgeInsets.zero,
          side:
              const BorderSide(
            color: Colors.black,
            width: 1,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              7,
            ),
          ),
        ),
        child: carregando
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      Colors.black,
                ),
              )
            : Text(
                texto,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 14,
                  color:
                      Colors.black,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final secoes = <Widget>[
      // ==========================================================
      // BAIRRO
      // ==========================================================

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
              color: Colors.black26,
              blurRadius: 2,
              offset:
                  Offset(1, 2),
            ),
          ],
        ),
        alignment:
            Alignment.center,
        child: Text(
          familia.bairro,
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

      // ==========================================================
      // TÍTULO
      // ==========================================================

      Text(
        editando
            ? 'Editar família'
            : 'Detalhes da família',
        textAlign:
            TextAlign.center,
        style:
            const TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.bold,
          color:
              Colors.black87,
        ),
      ),

      const SizedBox(
        height: 14,
      ),

      // ==========================================================
      // IDENTIFICAÇÃO
      // ==========================================================

      const Text(
        'Identificação pessoal da referência familiar e da família',
        style: TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.bold,
          color:
              Colors.black87,
        ),
      ),

      const SizedBox(
        height: 14,
      ),

      _campo(
        hint: 'Nome completo *',
        icon:
            Icons.person_outline,
        controller:
            nomeController,
        validator: (valor) {
          if (valor == null ||
              valor.trim().isEmpty) {
            return 'Informe o nome';
          }

          return null;
        },
      ),

      const SizedBox(
        height: 12,
      ),

      _campoData(
        label: 'Data de Nasc:',
        data: dataNascimento,
        onTap:
            selecionarDataNascimento,
      ),

      _campo(
        hint: 'Endereço completo *',
        icon:
            Icons.home_outlined,
        controller:
            enderecoController,
        maxLines: 2,
        validator: (valor) {
          if (valor == null ||
              valor.trim().isEmpty) {
            return 'Informe o endereço';
          }

          return null;
        },
      ),

      const SizedBox(
        height: 12,
      ),

      _campo(
        hint: 'Nacionalidade *',
        icon: Icons.public,
        controller:
            nacionalidadeController,
        validator: (valor) {
          if (valor == null ||
              valor.trim().isEmpty) {
            return 'Informe a nacionalidade';
          }

          return null;
        },
      ),

      const SizedBox(
        height: 12,
      ),

      _campo(
        hint: 'CPF *',
        icon:
            Icons.badge_outlined,
        controller: cpfController,
        keyboardType:
            TextInputType.number,
        validator: (valor) {
          if (valor == null ||
              valor.trim().isEmpty) {
            return 'Informe o CPF';
          }

          return null;
        },
      ),

      const SizedBox(
        height: 12,
      ),

      _campo(
        hint: 'Tel. *',
        icon:
            Icons.phone_outlined,
        controller:
            telefoneController,
        keyboardType:
            TextInputType.phone,
        validator: (valor) {
          if (valor == null ||
              valor.trim().isEmpty) {
            return 'Informe o telefone';
          }

          return null;
        },
      ),

      const SizedBox(
        height: 18,
      ),

      // ==========================================================
      // PERFIL SOCIOECONÔMICO
      // ==========================================================

      _tituloSecao(
        'Perfil socioeconômico',
      ),

      _grupoOpcoes(
        pergunta:
            'Autodeclaração étnico-racial:',
        opcoes: const [
          'preta',
          'parda',
          'branca',
          'amarela',
          'indígena',
        ],
        valor: etnia,
        onChanged: (v) {
          setState(() {
            etnia = v;
          });
        },
      ),

      _grupoOpcoes(
        pergunta:
            'Identidade de gênero:',
        opcoes: const [
          'mulher cis',
          'homem cis',
          'mulher trans',
          'homem trans',
          'não-binário',
        ],
        valor:
            identidadeGenero,
        onChanged: (v) {
          setState(() {
            identidadeGenero =
                v;
          });
        },
      ),

      _grupoOpcoes(
        pergunta:
            'Trabalhador/a:',
        opcoes: const [
          'Empregado/a CLT/Servidor/a Público',
          'Desempregado/a',
          'Trabalhador/a informal',
          'Agricultor/a familiar',
          'Autônomo/a',
        ],
        valor:
            situacaoTrabalho,
        onChanged: (v) {
          setState(() {
            situacaoTrabalho =
                v;
          });
        },
      ),

      _grupoOpcoes(
        pergunta:
            'Renda mensal família (bruta):',
        opcoes: const [
          '0 a 0,5 salário-mínimo',
          '0,5 a 01 salário-mínimo',
          '01 a 02 salários-mínimos',
          '02 a 03 salários-mínimos',
          '03 ou mais salários-mínimos',
        ],
        valor: rendaMensal,
        onChanged: (v) {
          setState(() {
            rendaMensal = v;
          });
        },
      ),

      _grupoSimNao(
        pergunta:
            'Possui Cadastro Único (CadÚnico):',
        valor: cadastroUnico,
        onChanged: (v) {
          setState(() {
            cadastroUnico = v;
          });
        },
      ),

      _grupoSimNao(
        pergunta:
            'Alguém da família recebe algum benefício da Assistência Social:',
        valor:
            recebeBeneficio,
        onChanged: (v) {
          setState(() {
            recebeBeneficio = v;
          });
        },
      ),

      if (recebeBeneficio ==
          'Sim') ...[
        _grupoOpcoes(
          pergunta:
              'Se sim, qual:',
          opcoes: const [
            'Bolsa Família',
            'Benefício de Prestação Continuada',
            'Outro',
          ],
          valor:
              qualBeneficio,
          onChanged: (v) {
            setState(() {
              qualBeneficio =
                  v;
            });
          },
        ),
        if (qualBeneficio ==
            'Outro')
          Padding(
            padding:
                const EdgeInsets
                    .only(
              bottom: 14,
            ),
            child: _campo(
              hint: 'Qual:',
              icon:
                  Icons.edit_outlined,
              controller:
                  qualBeneficioOutroController,
            ),
          ),
      ],

      _grupoSimNao(
        pergunta:
            'Alguém da família aposentado/a ou pensionista do INSS:',
        valor:
            aposentadoPensionista,
        onChanged: (v) {
          setState(() {
            aposentadoPensionista =
                v;
          });
        },
      ),

      if (aposentadoPensionista ==
          'Sim') ...[
        _grupoOpcoes(
          pergunta:
              'Se sim, qual:',
          opcoes: const [
            'Aposentado/a',
            'Pensão por morte',
            'Auxílio doença',
            'Outro',
          ],
          valor:
              qualAposentado,
          onChanged: (v) {
            setState(() {
              qualAposentado =
                  v;
            });
          },
        ),
        if (qualAposentado ==
            'Outro')
          Padding(
            padding:
                const EdgeInsets
                    .only(
              bottom: 14,
            ),
            child: _campo(
              hint: 'Qual:',
              icon:
                  Icons.edit_outlined,
              controller:
                  qualAposentadoOutroController,
            ),
          ),
      ],

      _grupoSimNao(
        pergunta:
            'Alguém da família possui alguma comorbidade:',
        valor:
            possuiComorbidade,
        onChanged: (v) {
          setState(() {
            possuiComorbidade =
                v;
          });
        },
      ),

      if (possuiComorbidade ==
          'Sim')
        Padding(
          padding:
              const EdgeInsets
                  .only(
            bottom: 14,
          ),
          child: _campo(
            hint: 'Se sim, qual:',
            icon:
                Icons.edit_outlined,
            controller:
                qualComorbidadeController,
          ),
        ),

      _grupoSimNao(
        pergunta:
            'Alguém da família faz uso de medicação de uso contínuo:',
        valor:
            usoMedicacaoContinuo,
        onChanged: (v) {
          setState(() {
            usoMedicacaoContinuo =
                v;
          });
        },
      ),

      if (usoMedicacaoContinuo ==
          'Sim')
        Padding(
          padding:
              const EdgeInsets
                  .only(
            bottom: 14,
          ),
          child: _campo(
            hint: 'Se sim, qual:',
            icon:
                Icons.edit_outlined,
            controller:
                qualMedicacaoController,
          ),
        ),

      _grupoSimNao(
        pergunta:
            'Alguém da família possui alguma deficiência:',
        valor:
            possuiDeficiencia,
        onChanged: (v) {
          setState(() {
            possuiDeficiencia =
                v;
          });
        },
      ),

      if (possuiDeficiencia ==
          'Sim')
        Padding(
          padding:
              const EdgeInsets
                  .only(
            bottom: 14,
          ),
          child: _campo(
            hint: 'Se sim, qual:',
            icon:
                Icons.edit_outlined,
            controller:
                qualDeficienciaController,
          ),
        ),

      _grupoSimNao(
        pergunta:
            'Houve perdas materiais:',
        valor:
            houvePerdasMateriais,
        onChanged: (v) {
          setState(() {
            houvePerdasMateriais =
                v;
          });
        },
      ),

      if (houvePerdasMateriais ==
          'Sim')
        _grupoCheckbox(
          pergunta:
              'Se sim, quais:',
          opcoes: const [
            'Móveis',
            'Eletrodomésticos',
            'Vestuário',
            'Casa',
            'Automóvel',
          ],
          selecionados:
              perdasMateriaisSelecionadas,
          onChanged: () {
            setState(() {});
          },
        ),

      _grupoSimNao(
        pergunta:
            'Houve perda de documentação:',
        valor:
            houvePerdaDocumentacao,
        onChanged: (v) {
          setState(() {
            houvePerdaDocumentacao =
                v;
          });
        },
      ),

      if (houvePerdaDocumentacao ==
          'Sim')
        Padding(
          padding:
              const EdgeInsets
                  .only(
            bottom: 14,
          ),
          child: _campo(
            hint:
                'Se sim, quais documentos:',
            icon:
                Icons.edit_outlined,
            controller:
                quaisDocumentosController,
          ),
        ),

      const SizedBox(
        height: 8,
      ),

      // ==========================================================
      // COMPOSIÇÃO FAMILIAR
      // ==========================================================

      _tituloSecao(
        'Composição Familiar',
      ),

      if (carregandoMembros)
        const Padding(
          padding:
              EdgeInsets.symmetric(
            vertical: 15,
          ),
          child: Center(
            child:
                CircularProgressIndicator(),
          ),
        )
      else ...[
        ...List.generate(
          membros.length,
          (index) =>
              _cardMembro(index),
        ),

        SizedBox(
          width: double.infinity,
          child:
              OutlinedButton.icon(
            onPressed:
                editando
                    ? abrirDialogoMembro
                    : null,
            icon:
                const Icon(
              Icons.add,
              size: 18,
            ),
            label:
                const Text(
              'Adicionar membro',
            ),
            style:
                OutlinedButton.styleFrom(
              backgroundColor:
                  Colors.white
                      .withOpacity(
                          0.75),
              foregroundColor:
                  Colors.black87,
              side:
                  const BorderSide(
                color: Colors.black,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  7,
                ),
              ),
            ),
          ),
        ),
      ],

      const SizedBox(
        height: 18,
      ),

      // ==========================================================
      // OBS
      // ==========================================================

      _tituloSecao('OBS'),

      _campo(
        hint: 'Observações',
        icon:
            Icons.notes_outlined,
        controller:
            obsController,
        maxLines: 4,
      ),

      const SizedBox(
        height: 22,
      ),

      // ==========================================================
      // BOTÕES
      //
      // O botão "Excluir" agora usa uma largura menor (180) e fica
      // centralizado, diferente dos outros botões desta tela, que
      // continuam ocupando a largura toda.
      // ==========================================================

      if (!editando) ...[
        _botao(
          texto: 'Editar',
          aoClicar:
              iniciarEdicao,
        ),

        const SizedBox(
          height: 10,
        ),

        _botao(
          texto: excluindo
              ? 'Excluindo...'
              : 'Excluir',
          aoClicar: excluindo
              ? null
              : excluirFamilia,
          carregando:
              excluindo,
        ),
      ] else ...[
        _botao(
          texto: 'Salvar alterações',
          aoClicar:
              salvando
                  ? null
                  : salvarAlteracoes,
          carregando:
              salvando,
        ),

        const SizedBox(
          height: 10,
        ),

        _botao(
          texto:
              'Cancelar edição',
          aoClicar:
              salvando
                  ? null
                  : cancelarEdicao,
        ),

        const SizedBox(
          height: 10,
        ),

        _botao(
          texto: excluindo
              ? 'Excluindo...'
              : 'Excluir',
          aoClicar: excluindo
              ? null
              : excluirFamilia,
          carregando:
              excluindo,
        ),
      ],

      const SizedBox(
        height: 20,
      ),
    ];

    // ============================================================
    // TELA
    // ============================================================

    return Scaffold(
      backgroundColor:
          const Color(0xFFE2E8FF),
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
                        fit:
                            BoxFit.contain,
                      ),
                    ),
                  ),

                  LayoutBuilder(
                    builder:
                        (context,
                            constraints) {
                      final paddingHorizontal =
                          constraints
                                      .maxWidth <
                                  400
                              ? 25.0
                              : 40.0;

                      return Form(
                        key: _formKey,
                        child:
                            ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              EdgeInsets.only(
                            top: 29,
                            left:
                                paddingHorizontal,
                            right:
                                paddingHorizontal,
                            bottom: 40,
                          ),
                          itemCount:
                              secoes.length,
                          itemBuilder:
                              (context,
                                  index) {
                            return secoes[
                                index];
                          },
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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nomeController.dispose();
    enderecoController.dispose();
    nacionalidadeController.dispose();
    cpfController.dispose();
    telefoneController.dispose();

    qualBeneficioOutroController
        .dispose();

    qualAposentadoOutroController
        .dispose();

    qualComorbidadeController
        .dispose();

    qualMedicacaoController
        .dispose();

    qualDeficienciaController
        .dispose();

    quaisDocumentosController
        .dispose();

    obsController.dispose();

    super.dispose();
  }
}