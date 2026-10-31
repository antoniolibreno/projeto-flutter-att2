import 'item_atendimento.dart';
import 'situacao_atendimento.dart';
import 'tipo_trabalho.dart';
import 'veiculo.dart';

class Atendimento {
  static const double limiteDesconto = 0.10;

  final int id;
  final Veiculo veiculo;
  final DateTime dataEntrada;
  final String problemaRelatado;
  SituacaoAtendimento _situacao;
  final List<ItemAtendimento> _itens;

  Atendimento._({
    required this.id,
    required this.veiculo,
    required this.dataEntrada,
    required String problemaRelatado,
    required SituacaoAtendimento situacao,
    required List<ItemAtendimento> itens,
  })  : problemaRelatado = _validarProblema(problemaRelatado),
        _situacao = situacao,
        _itens = List<ItemAtendimento>.of(itens) {
    if (_situacao == SituacaoAtendimento.concluido && _itens.isEmpty) {
      throw StateError('Um atendimento concluído precisa ter pelo menos um trabalho.');
    }
    veiculo.registrarAtendimento(this);
  }

  factory Atendimento({
    required int id,
    required Veiculo veiculo,
    required String problemaRelatado,
    DateTime? dataEntrada,
  }) {
    return Atendimento._(
      id: id,
      veiculo: veiculo,
      dataEntrada: dataEntrada ?? DateTime.now(),
      problemaRelatado: problemaRelatado,
      situacao: SituacaoAtendimento.aberto,
      itens: const <ItemAtendimento>[],
    );
  }

  factory Atendimento.fromMap(Map<String, dynamic> map) {
    final itens = (map['itens'] as List<dynamic>? ?? const [])
        .map((e) => ItemAtendimento.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Atendimento._(
      id: map['id_atendimento'] as int,
      veiculo: Veiculo.fromMap(Map<String, dynamic>.from(map['veiculo'] as Map)),
      dataEntrada: DateTime.parse(map['data_entrada'] as String),
      problemaRelatado: map['problema_relatado'] as String,
      situacao: SituacaoAtendimento.fromName(map['situacao'] as String),
      itens: itens,
    );
  }

  SituacaoAtendimento get situacao => _situacao;

  List<ItemAtendimento> get itens => List.unmodifiable(_itens);

  void adicionarTrabalho(TipoTrabalho trabalho, {double? valorCobrado}) {
    _garantirNaoConcluido();

    final valor = valorCobrado ?? trabalho.valorPadrao;
    final valorMinimo = trabalho.valorPadrao * (1 - limiteDesconto);
    if (valor < valorMinimo) {
      throw ArgumentError(
        'O desconto máximo permitido é de ${(limiteDesconto * 100).toStringAsFixed(0)}%. '
        'Valor mínimo para ${trabalho.descricao}: ${_formatarMoeda(valorMinimo)}.',
      );
    }

    final proximoId = _itens.fold<int>(0, (maior, i) => i.id > maior ? i.id : maior) + 1;
    _itens.add(ItemAtendimento(id: proximoId, tipoTrabalho: trabalho, valorCobrado: valor));
  }

  bool removerTrabalho(int idItem) {
    if (_situacao == SituacaoAtendimento.concluido) {
      return false;
    }
    final quantidadeAntes = _itens.length;
    _itens.removeWhere((i) => i.id == idItem);
    return _itens.length < quantidadeAntes;
  }

  double calcularTotal() =>
      _itens.fold<double>(0, (total, item) => total + item.valorCobrado);

  void alterarSituacao(SituacaoAtendimento novaSituacao) {
    if (novaSituacao == _situacao) {
      return;
    }
    if (!_situacao.podeMudarPara(novaSituacao)) {
      throw StateError(
        'Transição de ${_situacao.descricao} para ${novaSituacao.descricao} não é permitida.',
      );
    }
    if (novaSituacao == SituacaoAtendimento.concluido && _itens.isEmpty) {
      throw StateError('Não é possível concluir um atendimento sem trabalhos.');
    }
    _situacao = novaSituacao;
  }

  bool estaEmAndamento() => _situacao != SituacaoAtendimento.concluido;

  String gerarResumo() {
    final buffer = StringBuffer()
      ..writeln('Atendimento #$id')
      ..writeln('Veículo: ${veiculo.marca} ${veiculo.modelo} (${veiculo.placa})')
      ..writeln('Responsável: ${veiculo.responsavel.nome}')
      ..writeln('Entrada: ${_formatarData(dataEntrada)}')
      ..writeln('Problema relatado: $problemaRelatado')
      ..writeln('Situação: ${_situacao.descricao}')
      ..writeln('Trabalhos:');

    if (_itens.isEmpty) {
      buffer.writeln('  nenhum trabalho registrado');
    }
    for (final item in _itens) {
      buffer.writeln('  ${item.id}. ${item.descrever()}');
    }

    buffer.write('Total: ${_formatarMoeda(calcularTotal())}');
    return buffer.toString();
  }

  bool concluir() {
    if (_situacao == SituacaoAtendimento.concluido || _itens.isEmpty) {
      return false;
    }
    _situacao = SituacaoAtendimento.concluido;
    return true;
  }

  Atendimento copyWith({
    String? problemaRelatado,
    SituacaoAtendimento? situacao,
    List<ItemAtendimento>? itens,
  }) {
    final novaSituacao = situacao ?? _situacao;

    if (novaSituacao != _situacao && !_situacao.podeMudarPara(novaSituacao)) {
      throw StateError(
        'Transição de ${_situacao.descricao} para ${novaSituacao.descricao} não é permitida.',
      );
    }
    if (_situacao == SituacaoAtendimento.concluido && itens != null) {
      throw StateError('Não é possível alterar os trabalhos de um atendimento concluído.');
    }

    return Atendimento._(
      id: id,
      veiculo: veiculo,
      dataEntrada: dataEntrada,
      problemaRelatado: problemaRelatado ?? this.problemaRelatado,
      situacao: novaSituacao,
      itens: itens ?? _itens,
    );
  }

  Map<String, dynamic> toMap() => {
        'id_atendimento': id,
        'placa_veiculo': veiculo.placa,
        'veiculo': veiculo.toMap(),
        'data_entrada': dataEntrada.toIso8601String(),
        'problema_relatado': problemaRelatado,
        'situacao': _situacao.name,
        'itens': _itens.map((i) => i.toMap()).toList(),
        'total': calcularTotal(),
      };

  @override
  String toString() =>
      'Atendimento(id: $id, placa: ${veiculo.placa}, dataEntrada: ${_formatarData(dataEntrada)}, '
      'situacao: ${_situacao.descricao}, itens: ${_itens.length}, total: ${_formatarMoeda(calcularTotal())})';

  void _garantirNaoConcluido() {
    if (_situacao == SituacaoAtendimento.concluido) {
      throw StateError('O atendimento já foi concluído e não pode ser alterado.');
    }
  }

  static String _validarProblema(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) {
      throw ArgumentError('O problema relatado não pode ser vazio.');
    }
    return texto;
  }

  static String _formatarMoeda(double valor) => 'R\$ ${valor.toStringAsFixed(2)}';

  static String _formatarData(DateTime data) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} ${dois(data.hour)}:${dois(data.minute)}';
  }
}