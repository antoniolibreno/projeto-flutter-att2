enum SituacaoAtendimento {
  aberto('Aberto'),
  emExecucao('Em execução'),
  concluido('Concluído');

  final String descricao;

  const SituacaoAtendimento(this.descricao);

  bool podeMudarPara(SituacaoAtendimento nova) => switch (this) {
        SituacaoAtendimento.aberto => nova != SituacaoAtendimento.aberto,
        SituacaoAtendimento.emExecucao => nova == SituacaoAtendimento.concluido,
        SituacaoAtendimento.concluido => false,
      };

  static SituacaoAtendimento fromName(String nome) =>
      SituacaoAtendimento.values.byName(nome);
}
