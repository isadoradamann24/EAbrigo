class Familia {
  final int? id;
  final int cidadeId;
  final String bairro;
  final String dataCadastro;

  // ==========================================================
  // IDENTIFICAÇÃO PESSOAL DA REFERÊNCIA FAMILIAR
  // ==========================================================
  final String responsavel; // nome completo da referência
  final String dataNascimento;
  final String endereco; // endereço completo
  final String nacionalidade;
  final String cpf;
  final String telefone;

  // ==========================================================
  // PERFIL SOCIOECONÔMICO
  // ==========================================================
  final String etnia; // preta / parda / branca / amarela / indígena
  final String identidadeGenero; // mulher cis / homem cis / mulher trans / homem trans / não-binário
  final String situacaoTrabalho;
  final String rendaMensal;

  final String cadastroUnico; // Sim / Não

  final String recebeBeneficioAssistencia; // Sim / Não
  final String qualBeneficioAssistencia;
  final String qualBeneficioAssistenciaOutro;

  final String aposentadoPensionista; // Sim / Não
  final String qualAposentadoPensionista;
  final String qualAposentadoPensionistaOutro;

  final String possuiComorbidade; // Sim / Não
  final String qualComorbidade;

  final String usoMedicacaoContinuo; // Sim / Não
  final String qualMedicacao;

  final String possuiDeficiencia; // Sim / Não
  final String qualDeficiencia;

  final String houvePerdasMateriais; // Sim / Não
  final String quaisPerdasMateriais; // itens separados por vírgula

  final String houvePerdaDocumentacao; // Sim / Não
  final String quaisDocumentosPerdidos;

  final String obs;

  Familia({
    this.id,
    required this.cidadeId,
    required this.responsavel,
    this.bairro = '',
    this.endereco = '',
    this.telefone = '',
    this.dataCadastro = '',
    this.dataNascimento = '',
    this.nacionalidade = '',
    this.cpf = '',
    this.etnia = '',
    this.identidadeGenero = '',
    this.situacaoTrabalho = '',
    this.rendaMensal = '',
    this.cadastroUnico = '',
    this.recebeBeneficioAssistencia = '',
    this.qualBeneficioAssistencia = '',
    this.qualBeneficioAssistenciaOutro = '',
    this.aposentadoPensionista = '',
    this.qualAposentadoPensionista = '',
    this.qualAposentadoPensionistaOutro = '',
    this.possuiComorbidade = '',
    this.qualComorbidade = '',
    this.usoMedicacaoContinuo = '',
    this.qualMedicacao = '',
    this.possuiDeficiencia = '',
    this.qualDeficiencia = '',
    this.houvePerdasMateriais = '',
    this.quaisPerdasMateriais = '',
    this.houvePerdaDocumentacao = '',
    this.quaisDocumentosPerdidos = '',
    this.obs = '',
  });

  // Converte a família para um Map que pode ser salvo no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cidade_id': cidadeId,
      'responsavel': responsavel,
      'bairro': bairro,
      'endereco': endereco,
      'telefone': telefone,
      'data_cadastro': dataCadastro,
      'data_nascimento': dataNascimento,
      'nacionalidade': nacionalidade,
      'cpf': cpf,
      'etnia': etnia,
      'identidade_genero': identidadeGenero,
      'situacao_trabalho': situacaoTrabalho,
      'renda_mensal': rendaMensal,
      'cadastro_unico': cadastroUnico,
      'recebe_beneficio_assistencia': recebeBeneficioAssistencia,
      'qual_beneficio_assistencia': qualBeneficioAssistencia,
      'qual_beneficio_assistencia_outro': qualBeneficioAssistenciaOutro,
      'aposentado_pensionista': aposentadoPensionista,
      'qual_aposentado_pensionista': qualAposentadoPensionista,
      'qual_aposentado_pensionista_outro': qualAposentadoPensionistaOutro,
      'possui_comorbidade': possuiComorbidade,
      'qual_comorbidade': qualComorbidade,
      'uso_medicacao_continuo': usoMedicacaoContinuo,
      'qual_medicacao': qualMedicacao,
      'possui_deficiencia': possuiDeficiencia,
      'qual_deficiencia': qualDeficiencia,
      'houve_perdas_materiais': houvePerdasMateriais,
      'quais_perdas_materiais': quaisPerdasMateriais,
      'houve_perda_documentacao': houvePerdaDocumentacao,
      'quais_documentos_perdidos': quaisDocumentosPerdidos,
      'obs': obs,
    };
  }

  // Converte os dados do SQLite para um objeto Familia.
  factory Familia.fromMap(Map<String, dynamic> map) {
    return Familia(
      id: map['id'],
      cidadeId: map['cidade_id'],
      responsavel: map['responsavel'] ?? '',
      bairro: map['bairro'] ?? '',
      endereco: map['endereco'] ?? '',
      telefone: map['telefone'] ?? '',
      dataCadastro: map['data_cadastro'] ?? '',
      dataNascimento: map['data_nascimento'] ?? '',
      nacionalidade: map['nacionalidade'] ?? '',
      cpf: map['cpf'] ?? '',
      etnia: map['etnia'] ?? '',
      identidadeGenero: map['identidade_genero'] ?? '',
      situacaoTrabalho: map['situacao_trabalho'] ?? '',
      rendaMensal: map['renda_mensal'] ?? '',
      cadastroUnico: map['cadastro_unico'] ?? '',
      recebeBeneficioAssistencia: map['recebe_beneficio_assistencia'] ?? '',
      qualBeneficioAssistencia: map['qual_beneficio_assistencia'] ?? '',
      qualBeneficioAssistenciaOutro:
          map['qual_beneficio_assistencia_outro'] ?? '',
      aposentadoPensionista: map['aposentado_pensionista'] ?? '',
      qualAposentadoPensionista: map['qual_aposentado_pensionista'] ?? '',
      qualAposentadoPensionistaOutro:
          map['qual_aposentado_pensionista_outro'] ?? '',
      possuiComorbidade: map['possui_comorbidade'] ?? '',
      qualComorbidade: map['qual_comorbidade'] ?? '',
      usoMedicacaoContinuo: map['uso_medicacao_continuo'] ?? '',
      qualMedicacao: map['qual_medicacao'] ?? '',
      possuiDeficiencia: map['possui_deficiencia'] ?? '',
      qualDeficiencia: map['qual_deficiencia'] ?? '',
      houvePerdasMateriais: map['houve_perdas_materiais'] ?? '',
      quaisPerdasMateriais: map['quais_perdas_materiais'] ?? '',
      houvePerdaDocumentacao: map['houve_perda_documentacao'] ?? '',
      quaisDocumentosPerdidos: map['quais_documentos_perdidos'] ?? '',
      obs: map['obs'] ?? '',
    );
  }

  // Cria uma cópia da família permitindo alterar alguns campos.
  Familia copyWith({
    int? id,
    int? cidadeId,
    String? responsavel,
    String? bairro,
    String? endereco,
    String? telefone,
    String? dataCadastro,
    String? dataNascimento,
    String? nacionalidade,
    String? cpf,
    String? etnia,
    String? identidadeGenero,
    String? situacaoTrabalho,
    String? rendaMensal,
    String? cadastroUnico,
    String? recebeBeneficioAssistencia,
    String? qualBeneficioAssistencia,
    String? qualBeneficioAssistenciaOutro,
    String? aposentadoPensionista,
    String? qualAposentadoPensionista,
    String? qualAposentadoPensionistaOutro,
    String? possuiComorbidade,
    String? qualComorbidade,
    String? usoMedicacaoContinuo,
    String? qualMedicacao,
    String? possuiDeficiencia,
    String? qualDeficiencia,
    String? houvePerdasMateriais,
    String? quaisPerdasMateriais,
    String? houvePerdaDocumentacao,
    String? quaisDocumentosPerdidos,
    String? obs,
  }) {
    return Familia(
      id: id ?? this.id,
      cidadeId: cidadeId ?? this.cidadeId,
      responsavel: responsavel ?? this.responsavel,
      bairro: bairro ?? this.bairro,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      nacionalidade: nacionalidade ?? this.nacionalidade,
      cpf: cpf ?? this.cpf,
      etnia: etnia ?? this.etnia,
      identidadeGenero: identidadeGenero ?? this.identidadeGenero,
      situacaoTrabalho: situacaoTrabalho ?? this.situacaoTrabalho,
      rendaMensal: rendaMensal ?? this.rendaMensal,
      cadastroUnico: cadastroUnico ?? this.cadastroUnico,
      recebeBeneficioAssistencia:
          recebeBeneficioAssistencia ?? this.recebeBeneficioAssistencia,
      qualBeneficioAssistencia:
          qualBeneficioAssistencia ?? this.qualBeneficioAssistencia,
      qualBeneficioAssistenciaOutro: qualBeneficioAssistenciaOutro ??
          this.qualBeneficioAssistenciaOutro,
      aposentadoPensionista:
          aposentadoPensionista ?? this.aposentadoPensionista,
      qualAposentadoPensionista:
          qualAposentadoPensionista ?? this.qualAposentadoPensionista,
      qualAposentadoPensionistaOutro: qualAposentadoPensionistaOutro ??
          this.qualAposentadoPensionistaOutro,
      possuiComorbidade: possuiComorbidade ?? this.possuiComorbidade,
      qualComorbidade: qualComorbidade ?? this.qualComorbidade,
      usoMedicacaoContinuo: usoMedicacaoContinuo ?? this.usoMedicacaoContinuo,
      qualMedicacao: qualMedicacao ?? this.qualMedicacao,
      possuiDeficiencia: possuiDeficiencia ?? this.possuiDeficiencia,
      qualDeficiencia: qualDeficiencia ?? this.qualDeficiencia,
      houvePerdasMateriais:
          houvePerdasMateriais ?? this.houvePerdasMateriais,
      quaisPerdasMateriais:
          quaisPerdasMateriais ?? this.quaisPerdasMateriais,
      houvePerdaDocumentacao:
          houvePerdaDocumentacao ?? this.houvePerdaDocumentacao,
      quaisDocumentosPerdidos:
          quaisDocumentosPerdidos ?? this.quaisDocumentosPerdidos,
      obs: obs ?? this.obs,
    );
  }
}