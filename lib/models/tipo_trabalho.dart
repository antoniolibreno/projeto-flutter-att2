class TipoTrabalho {
  final int id;
  String _descricao;
  double _valorPadrao;

  TipoTrabalho({
    required this.id,
    required String descricao,
    required double valorPadrao,
  })  : _descricao = _validarDescricao(descricao),
        _valorPadrao = _validarValor(valorPadrao);

  factory TipoTrabalho.fromMap(Map<String, dynamic> map) {
    return TipoTrabalho(
      id: map['id_trabalho'] as int,
      descricao: map['descricao'] as String,
      valorPadrao: (map['valor_padrao'] as num).toDouble(),
    );
  }

  String get descricao => _descricao;

  set descricao(String valor) => _descricao = _validarDescricao(valor);

  double get valorPadrao => _valorPadrao;

  void reajustarValor(double novoValor) {
    _valorPadrao = _validarValor(novoValor);
  }

  TipoTrabalho copyWith({String? descricao, double? valorPadrao}) {
    return TipoTrabalho(
      id: id,
      descricao: descricao ?? _descricao,
      valorPadrao: valorPadrao ?? _valorPadrao,
    );
  }

  Map<String, dynamic> toMap() => {
        'id_trabalho': id,
        'descricao': _descricao,
        'valor_padrao': _valorPadrao,
      };

  @override
  String toString() =>
      'TipoTrabalho(id: $id, descricao: $_descricao, valorPadrao: R\$ ${_valorPadrao.toStringAsFixed(2)})';

  static String _validarDescricao(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) {
      throw ArgumentError('A descrição do tipo de trabalho não pode ser vazia.');
    }
    return texto;
  }

  static double _validarValor(double valor) {
    if (valor <= 0) {
      throw ArgumentError('O valor padrão deve ser maior que zero.');
    }
    return valor;
  }
}
