import 'package:oficina/oficina.dart';

void main() {
  final pessoa = PessoaResponsavel(
    id: 1,
    nome: 'Carlos Silva',
    documento: '123.456.789-09',
    telefone: '(45) 99999-1234',
    email: 'carlos@email.com',
  );

  final veiculo = Veiculo(
    placa: 'ABC1D23',
    marca: 'Volkswagen',
    modelo: 'Gol',
    ano: 2018,
    responsavel: pessoa,
  );

  final trocaOleo = TipoTrabalho(id: 1, descricao: 'Troca de óleo', valorPadrao: 150);
  final freios = TipoTrabalho(id: 2, descricao: 'Revisão de freios', valorPadrao: 280);

  final atendimento = Atendimento(
    id: 1,
    veiculo: veiculo,
    problemaRelatado: 'Barulho ao frear',
  );

  print('Concluir sem trabalhos: ${atendimento.concluir()}');

  atendimento.alterarSituacao(SituacaoAtendimento.emExecucao);
  atendimento.adicionarTrabalho(trocaOleo);
  atendimento.adicionarTrabalho(freios, valorCobrado: 260);

  freios.reajustarValor(300);

  print(atendimento.gerarResumo());
  print('Concluir com trabalhos: ${atendimento.concluir()}');
  print('Em andamento: ${atendimento.estaEmAndamento()}');

  final reconstruido = Atendimento.fromMap(atendimento.toMap());
  print(reconstruido);

  print(pessoa.listarVeiculos());
  print(veiculo.consultarHistorico());
}
