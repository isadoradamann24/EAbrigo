import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../models/familia.dart';
import '../models/membro_familia.dart';
import '../services/banco_service.dart';
import '../widgets/cabecalho.dart';

class CadastroScreen extends StatefulWidget {
  final Cidade cidade;
  final String bairro;

  /// Quando informada, a tela abre em modo de edição: os campos são
  /// pré-preenchidos com os dados dessa família (e seus membros) e
  /// o botão "Salvar" atualiza o registro em vez de criar um novo.
  final Familia? familiaExistente;

  const CadastroScreen({
    super.key,
    required this.cidade,
    required this.bairro,
    this.familiaExistente,
  });

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final BancoService banco = BancoService();

  final _formKey = GlobalKey<FormState>();

  // ==========================================================
  // CONTROLLERS - IDENTIFICAÇÃO PESSOAL
  // ==========================================================

  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final nacionalidadeController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();

  // ==========================================================
  // CONTROLLERS - CAMPOS "SE SIM, QUAL"
  // ==========================================================

  final qualBeneficioOutroController = TextEditingController();
  final qualAposentadoOutroController = TextEditingController();
  final qualComorbidadeController = TextEditingController();
  final qualMedicacaoController = TextEditingController();
  final qualDeficienciaController = TextEditingController();
  final quaisDocumentosController = TextEditingController();
  final obsController = TextEditingController();

  DateTime? dataNascimento;
  DateTime dataCadastro = DateTime.now();

  bool salvando = false;

  // ==========================================================
  // CAMPOS DE SELEÇÃO (radio / sim-não)
  // ==========================================================

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

  // ==========================================================
  // COMPOSIÇÃO FAMILIAR
  // ==========================================================

  final List<MembroFamilia> membros = [];

  bool carregandoDados = false;

  @override
  void initState() {
    super.initState();

    final existente = widget.familiaExistente;

    if (existente != null) {
      _preencherComFamiliaExistente(existente);
      _carregarMembrosExistentes(existente.id!);
    }
  }

  // ==========================================================
  // PRÉ-CARREGAR DADOS (MODO EDIÇÃO)
  // ==========================================================

  DateTime? _parseData(String data) {
    if (data.trim().isEmpty) return null;

    final partes = data.split('/');
    if (partes.length != 3) return null;

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);

    if (dia == null || mes == null || ano == null) return null;

    return DateTime(ano, mes, dia);
  }

  void _preencherComFamiliaExistente(Familia f) {
    nomeController.text = f.responsavel;
    enderecoController.text = f.endereco;
    nacionalidadeController.text = f.nacionalidade;
    cpfController.text = f.cpf;
    telefoneController.text = f.telefone;
    qualBeneficioOutroController.text = f.qualBeneficioAssistenciaOutro;
    qualAposentadoOutroController.text = f.qualAposentadoPensionistaOutro;
    qualComorbidadeController.text = f.qualComorbidade;
    qualMedicacaoController.text = f.qualMedicacao;
    qualDeficienciaController.text = f.qualDeficiencia;
    quaisDocumentosController.text = f.quaisDocumentosPerdidos;
    obsController.text = f.obs;

    dataNascimento = _parseData(f.dataNascimento);

    etnia = f.etnia.isEmpty ? null : f.etnia;
    identidadeGenero = f.identidadeGenero.isEmpty ? null : f.identidadeGenero;
    situacaoTrabalho = f.situacaoTrabalho.isEmpty ? null : f.situacaoTrabalho;
    rendaMensal = f.rendaMensal.isEmpty ? null : f.rendaMensal;
    cadastroUnico = f.cadastroUnico.isEmpty ? null : f.cadastroUnico;
    recebeBeneficio = f.recebeBeneficioAssistencia.isEmpty
        ? null
        : f.recebeBeneficioAssistencia;
    qualBeneficio = f.qualBeneficioAssistencia.isEmpty
        ? null
        : f.qualBeneficioAssistencia;
    aposentadoPensionista =
        f.aposentadoPensionista.isEmpty ? null : f.aposentadoPensionista;
    qualAposentado = f.qualAposentadoPensionista.isEmpty
        ? null
        : f.qualAposentadoPensionista;
    possuiComorbidade =
        f.possuiComorbidade.isEmpty ? null : f.possuiComorbidade;
    usoMedicacaoContinuo =
        f.usoMedicacaoContinuo.isEmpty ? null : f.usoMedicacaoContinuo;
    possuiDeficiencia =
        f.possuiDeficiencia.isEmpty ? null : f.possuiDeficiencia;
    houvePerdasMateriais =
        f.houvePerdasMateriais.isEmpty ? null : f.houvePerdasMateriais;
    houvePerdaDocumentacao =
        f.houvePerdaDocumentacao.isEmpty ? null : f.houvePerdaDocumentacao;

    if (f.quaisPerdasMateriais.trim().isNotEmpty) {
      perdasMateriaisSelecionadas.addAll(
        f.quaisPerdasMateriais.split(',').map((e) => e.trim()),
      );
    }
  }

  Future<void> _carregarMembrosExistentes(int familiaId) async {
    setState(() => carregandoDados = true);

    try {
      final lista = await banco.listarMembros(familiaId);

      if (!mounted) return;

      setState(() {
        membros.addAll(lista);
        carregandoDados = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => carregandoDados = false);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    enderecoController.dispose();
    nacionalidadeController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    qualBeneficioOutroController.dispose();
    qualAposentadoOutroController.dispose();
    qualComorbidadeController.dispose();
    qualMedicacaoController.dispose();
    qualDeficienciaController.dispose();
    quaisDocumentosController.dispose();
    obsController.dispose();
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

    final dataFormatada = _formatarData(dataCadastro);
    final nascimentoFormatado =
        dataNascimento != null ? _formatarData(dataNascimento!) : '';

    final familia = Familia(
      id: widget.familiaExistente?.id,
      cidadeId: widget.cidade.id!,
      responsavel: nomeController.text.trim(),
      bairro: widget.bairro,
      endereco: enderecoController.text.trim(),
      telefone: telefoneController.text.trim(),
      dataCadastro: dataFormatada,
      dataNascimento: nascimentoFormatado,
      nacionalidade: nacionalidadeController.text.trim(),
      cpf: cpfController.text.trim(),
      etnia: etnia ?? '',
      identidadeGenero: identidadeGenero ?? '',
      situacaoTrabalho: situacaoTrabalho ?? '',
      rendaMensal: rendaMensal ?? '',
      cadastroUnico: cadastroUnico ?? '',
      recebeBeneficioAssistencia: recebeBeneficio ?? '',
      qualBeneficioAssistencia: qualBeneficio ?? '',
      qualBeneficioAssistenciaOutro: qualBeneficioOutroController.text.trim(),
      aposentadoPensionista: aposentadoPensionista ?? '',
      qualAposentadoPensionista: qualAposentado ?? '',
      qualAposentadoPensionistaOutro:
          qualAposentadoOutroController.text.trim(),
      possuiComorbidade: possuiComorbidade ?? '',
      qualComorbidade: qualComorbidadeController.text.trim(),
      usoMedicacaoContinuo: usoMedicacaoContinuo ?? '',
      qualMedicacao: qualMedicacaoController.text.trim(),
      possuiDeficiencia: possuiDeficiencia ?? '',
      qualDeficiencia: qualDeficienciaController.text.trim(),
      houvePerdasMateriais: houvePerdasMateriais ?? '',
      quaisPerdasMateriais: perdasMateriaisSelecionadas.join(', '),
      houvePerdaDocumentacao: houvePerdaDocumentacao ?? '',
      quaisDocumentosPerdidos: quaisDocumentosController.text.trim(),
      obs: obsController.text.trim(),
    );

    final editando = widget.familiaExistente != null;

    try {
      if (editando) {
        await banco.atualizarFamiliaCompleta(familia, membros);
      } else {
        await banco.cadastrarFamiliaCompleta(familia, membros);
      }

      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Cadastro da família atualizado com sucesso!'
                : 'Família cadastrada com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Erro ao atualizar família: $e'
                : 'Erro ao cadastrar família: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // LIMPAR
  // ==========================================================

  void limparFormulario() {
    nomeController.clear();
    enderecoController.clear();
    nacionalidadeController.clear();
    cpfController.clear();
    telefoneController.clear();
    qualBeneficioOutroController.clear();
    qualAposentadoOutroController.clear();
    qualComorbidadeController.clear();
    qualMedicacaoController.clear();
    qualDeficienciaController.clear();
    quaisDocumentosController.clear();
    obsController.clear();

    setState(() {
      dataCadastro = DateTime.now();
      dataNascimento = null;
      etnia = null;
      identidadeGenero = null;
      situacaoTrabalho = null;
      rendaMensal = null;
      cadastroUnico = null;
      recebeBeneficio = null;
      qualBeneficio = null;
      aposentadoPensionista = null;
      qualAposentado = null;
      possuiComorbidade = null;
      usoMedicacaoContinuo = null;
      possuiDeficiencia = null;
      houvePerdasMateriais = null;
      perdasMateriaisSelecionadas.clear();
      houvePerdaDocumentacao = null;
      membros.clear();
    });
  }

  // ==========================================================
  // DATAS
  // ==========================================================

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> selecionarDataCadastro() async {
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

  Future<void> selecionarDataNascimento() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataNascimento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        dataNascimento = data;
      });
    }
  }

  // ==========================================================
  // COMPOSIÇÃO FAMILIAR - ADICIONAR / REMOVER MEMBRO
  // ==========================================================

  Future<void> abrirDialogoMembro() async {
    final nomeMembroController = TextEditingController();
    final idadeMembroController = TextEditingController();
    final escolaridadeMembroController = TextEditingController();
    String? parentesco;
    String? identidadeGeneroMembro;

    final resultado = await showDialog<MembroFamilia>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar membro'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nomeMembroController,
                      decoration:
                          const InputDecoration(labelText: 'Nome completo'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: parentesco,
                      decoration:
                          const InputDecoration(labelText: 'Parentesco'),
                      items: const [
                        'Marido',
                        'Esposa',
                        'Companheiro/a',
                        'Filho/a',
                        'Pai',
                        'Mãe',
                        'Avô/Avó',
                        'Outro',
                      ]
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                      onChanged: (valor) {
                        setDialogState(() => parentesco = valor);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: idadeMembroController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Idade'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: escolaridadeMembroController,
                      decoration:
                          const InputDecoration(labelText: 'Escolaridade'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: identidadeGeneroMembro,
                      decoration: const InputDecoration(
                        labelText: 'Identidade de gênero',
                      ),
                      items: const [
                        'Feminino',
                        'Masculino',
                        'Mulher trans',
                        'Homem trans',
                        'Não-binário',
                      ]
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                      onChanged: (valor) {
                        setDialogState(() => identidadeGeneroMembro = valor);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nomeMembroController.text.trim().isEmpty) return;

                    Navigator.pop(
                      context,
                      MembroFamilia(
                        nome: nomeMembroController.text.trim(),
                        parentesco: parentesco ?? '',
                        idade:
                            int.tryParse(idadeMembroController.text.trim()) ??
                                0,
                        escolaridade: escolaridadeMembroController.text.trim(),
                        identidadeGenero: identidadeGeneroMembro ?? '',
                      ),
                    );
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        membros.add(resultado);
      });
    }
  }

  void removerMembro(int index) {
    setState(() {
      membros.removeAt(index);
    });
  }

  // ==========================================================
  // WIDGETS REUTILIZÁVEIS
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
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: Icon(icon, size: 19, color: Colors.black87),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
        ),
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _pergunta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  /// Grupo de opções em radio, organizadas em Wrap (quebra linha sozinho).
  Widget _grupoOpcoes({
    required String pergunta,
    required List<String> opcoes,
    required String? valor,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pergunta(pergunta),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            children: opcoes.map((opcao) {
              return SizedBox(
                width: opcao.length > 18 ? double.infinity : 165,
                child: RadioListTile<String>(
                  value: opcao,
                  groupValue: valor,
                  onChanged: onChanged,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    opcao,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Pergunta Sim/Não, retorna o widget de campo condicional se necessário.
  Widget _grupoSimNao({
    required String pergunta,
    required String? valor,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pergunta(pergunta),
          Row(
            children: ['Sim', 'Não'].map((opcao) {
              return Expanded(
                child: RadioListTile<String>(
                  value: opcao,
                  groupValue: valor,
                  onChanged: onChanged,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: Text(opcao, style: const TextStyle(fontSize: 12.5)),
                ),
              );
            }).toList(),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pergunta(pergunta),
          ...opcoes.map((opcao) {
            return CheckboxListTile(
              value: selecionados.contains(opcao),
              onChanged: (marcado) {
                if (marcado == true) {
                  selecionados.add(opcao);
                } else {
                  selecionados.remove(opcao);
                }
                onChanged();
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              visualDensity: VisualDensity.compact,
              title: Text(opcao, style: const TextStyle(fontSize: 12.5)),
            );
          }),
        ],
      ),
    );
  }

  Widget _campoData({
    required String label,
    required DateTime? data,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pergunta(label),
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 19, color: Colors.black87),
                  const SizedBox(width: 10),
                  Text(
                    data != null ? _formatarData(data) : 'Selecionar data',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          side: const BorderSide(color: Colors.black, width: 1),
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
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
      ),
    );
  }

  Widget _cardMembro(int index) {
    final membro = membros[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${index + 1} - ${membro.nome}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => removerMembro(index),
                  child: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Parentesco: ${membro.parentesco}',
                    style: const TextStyle(fontSize: 12.5)),
                Text('Idade: ${membro.idade}',
                    style: const TextStyle(fontSize: 12.5)),
                Text('Escolaridade: ${membro.escolaridade}',
                    style: const TextStyle(fontSize: 12.5)),
                Text('Id. de Gênero: ${membro.identidadeGenero}',
                    style: const TextStyle(fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // Lista de seções montadas apenas quando visíveis pelo
    // ListView.builder — evita construir o formulário inteiro
    // de uma vez, reduzindo o custo de memória da tela.
    final secoes = <Widget>[
      // BAIRRO
      Container(
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(7),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.bairro,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
      const SizedBox(height: 18),

      if (widget.familiaExistente != null) ...[
        Text(
          'Família ${widget.familiaExistente!.responsavel}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 14),
      ],

      const Text(
        'Identificação pessoal da referência familiar e da família',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 14),

      _campo(
        hint: 'Nome completo *',
        icon: Icons.person_outline,
        controller: nomeController,
        validator: (valor) =>
            (valor == null || valor.trim().isEmpty) ? 'Informe o nome' : null,
      ),
      const SizedBox(height: 12),

      _campoData(
        label: 'Data de Nasc:',
        data: dataNascimento,
        onTap: selecionarDataNascimento,
      ),

      _campo(
        hint: 'Endereço completo',
        icon: Icons.home_outlined,
        controller: enderecoController,
        maxLines: 2,
      ),
      const SizedBox(height: 12),

      _campo(
        hint: 'Nacionalidade',
        icon: Icons.public,
        controller: nacionalidadeController,
      ),
      const SizedBox(height: 12),

      _campo(
        hint: 'CPF',
        icon: Icons.badge_outlined,
        controller: cpfController,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),

      _campo(
        hint: 'Tel.',
        icon: Icons.phone_outlined,
        controller: telefoneController,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 18),

      _tituloSecao('Perfil socioeconômico'),

      _grupoOpcoes(
        pergunta: 'Autodeclaração étnico-racial:',
        opcoes: const ['preta', 'parda', 'branca', 'amarela', 'indígena'],
        valor: etnia,
        onChanged: (v) => setState(() => etnia = v),
      ),

      _grupoOpcoes(
        pergunta: 'Identidade de gênero:',
        opcoes: const [
          'mulher cis',
          'homem cis',
          'mulher trans',
          'homem trans',
          'não-binário',
        ],
        valor: identidadeGenero,
        onChanged: (v) => setState(() => identidadeGenero = v),
      ),

      _grupoOpcoes(
        pergunta: 'Trabalhador/a:',
        opcoes: const [
          'Empregado/a CLT/Servidor/a Público',
          'Desempregado/a',
          'Trabalhador/a informal',
          'Agricultor/a familiar',
          'Autônomo/a',
        ],
        valor: situacaoTrabalho,
        onChanged: (v) => setState(() => situacaoTrabalho = v),
      ),

      _grupoOpcoes(
        pergunta: 'Renda mensal família (bruta):',
        opcoes: const [
          '0 a 0,5 salário-mínimo',
          '0,5 a 01 salário-mínimo',
          '01 a 02 salários-mínimos',
          '02 a 03 salários-mínimos',
          '03 ou mais salários-mínimos',
        ],
        valor: rendaMensal,
        onChanged: (v) => setState(() => rendaMensal = v),
      ),

      _grupoSimNao(
        pergunta: 'Possui Cadastro Único (CadÚnico):',
        valor: cadastroUnico,
        onChanged: (v) => setState(() => cadastroUnico = v),
      ),
      const SizedBox(height: 10),

      _grupoSimNao(
        pergunta:
            'Alguém da família recebe algum benefício da Assistência Social:',
        valor: recebeBeneficio,
        onChanged: (v) => setState(() => recebeBeneficio = v),
      ),
      if (recebeBeneficio == 'Sim') ...[
        _grupoOpcoes(
          pergunta: 'Se sim, qual:',
          opcoes: const [
            'Bolsa Família',
            'Benefício de Prestação Continuada',
            'Outro',
          ],
          valor: qualBeneficio,
          onChanged: (v) => setState(() => qualBeneficio = v),
        ),
        if (qualBeneficio == 'Outro')
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _campo(
              hint: 'Qual:',
              icon: Icons.edit_outlined,
              controller: qualBeneficioOutroController,
            ),
          ),
      ],

      _grupoSimNao(
        pergunta: 'Alguém da família aposentado/a ou pensionista do INSS:',
        valor: aposentadoPensionista,
        onChanged: (v) => setState(() => aposentadoPensionista = v),
      ),
      if (aposentadoPensionista == 'Sim') ...[
        _grupoOpcoes(
          pergunta: 'Se sim, qual:',
          opcoes: const [
            'Aposentado/a',
            'Pensão por morte',
            'Auxílio doença',
            'Outro',
          ],
          valor: qualAposentado,
          onChanged: (v) => setState(() => qualAposentado = v),
        ),
        if (qualAposentado == 'Outro')
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _campo(
              hint: 'Qual:',
              icon: Icons.edit_outlined,
              controller: qualAposentadoOutroController,
            ),
          ),
      ],

      _grupoSimNao(
        pergunta: 'Alguém da família possui alguma comorbidade:',
        valor: possuiComorbidade,
        onChanged: (v) => setState(() => possuiComorbidade = v),
      ),
      if (possuiComorbidade == 'Sim')
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _campo(
            hint: 'Se sim, qual:',
            icon: Icons.edit_outlined,
            controller: qualComorbidadeController,
          ),
        ),

      _grupoSimNao(
        pergunta: 'Alguém da família faz uso de medicação de uso contínuo:',
        valor: usoMedicacaoContinuo,
        onChanged: (v) => setState(() => usoMedicacaoContinuo = v),
      ),
      if (usoMedicacaoContinuo == 'Sim')
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _campo(
            hint: 'Se sim, qual:',
            icon: Icons.edit_outlined,
            controller: qualMedicacaoController,
          ),
        ),

      _grupoSimNao(
        pergunta: 'Alguém da família possui alguma deficiência:',
        valor: possuiDeficiencia,
        onChanged: (v) => setState(() => possuiDeficiencia = v),
      ),
      if (possuiDeficiencia == 'Sim')
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _campo(
            hint: 'Se sim, qual:',
            icon: Icons.edit_outlined,
            controller: qualDeficienciaController,
          ),
        ),

      _grupoSimNao(
        pergunta: 'Houve perdas materiais:',
        valor: houvePerdasMateriais,
        onChanged: (v) => setState(() => houvePerdasMateriais = v),
      ),
      if (houvePerdasMateriais == 'Sim')
        _grupoCheckbox(
          pergunta: 'Se sim, quais:',
          opcoes: const [
            'Móveis',
            'Eletrodomésticos',
            'Vestuário',
            'Casa',
            'Automóvel',
          ],
          selecionados: perdasMateriaisSelecionadas,
          onChanged: () => setState(() {}),
        ),

      _grupoSimNao(
        pergunta: 'Houve perda de documentação:',
        valor: houvePerdaDocumentacao,
        onChanged: (v) => setState(() => houvePerdaDocumentacao = v),
      ),
      if (houvePerdaDocumentacao == 'Sim')
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _campo(
            hint: 'Se sim, quais documentos:',
            icon: Icons.edit_outlined,
            controller: quaisDocumentosController,
          ),
        ),

      const SizedBox(height: 8),
      _tituloSecao('Composição Familiar'),

      ...List.generate(membros.length, (index) => _cardMembro(index)),

      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: abrirDialogoMembro,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Adicionar membro'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),

      _tituloSecao('OBS'),
      _campo(
        hint: 'Observações',
        icon: Icons.notes_outlined,
        controller: obsController,
        maxLines: 4,
      ),
      const SizedBox(height: 22),

      _botao(
        texto: 'Salvar família',
        aoClicar: salvando ? null : salvarFamilia,
        carregando: salvando,
      ),
      const SizedBox(height: 10),

      _botao(
        texto: 'Limpar formulário',
        aoClicar: salvando ? null : limparFormulario,
      ),
      const SizedBox(height: 20),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8FF),
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO
            const Cabecalho(),

            // CONTEÚDO
            Expanded(
              child: Stack(
                children: [
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
                  if (carregandoDados)
                    const Center(child: CircularProgressIndicator()),

                  if (!carregandoDados)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final paddingHorizontal =
                          constraints.maxWidth < 400 ? 25.0 : 40.0;

                      return Form(
                        key: _formKey,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: 29,
                            left: paddingHorizontal,
                            right: paddingHorizontal,
                            bottom: 40,
                          ),
                          // Constrói/recicla só as seções visíveis
                          // na tela, em vez de montar o formulário
                          // inteiro de uma só vez.
                          itemCount: secoes.length,
                          itemBuilder: (context, index) => secoes[index],
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