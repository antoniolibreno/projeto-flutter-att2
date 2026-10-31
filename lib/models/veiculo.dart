import 'atendimento.dart';
import 'pessoa_responsavel.dart';

class Veiculo {
  final String placa;
  String _marca;
  String _modelo;
  int _ano;
  PessoaResponsavel _responsavel;
  final List<Atendimento> _historico = [];

  Veiculo({
    required String placa,
    required String marca,
    required String modelo,
    required int ano,
    required PessoaResponsavel responsavel,
  })  : placa = _validarPlaca(placa),
        _marca = _validarTexto(marca, 'marca'),
        _modelo = _validarTexto(modelo, 'modelo'),
        _ano = _validarAno(ano),
        _responsavel = responsavel {
    _responsavel.vincularVeiculo(this);
  }

  factory Veiculo.fromMap(Map<String, dynamic> map) {
    return Veiculo(
      placa: map['placa'] as String,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      ano: map['ano'] as int,
      responsavel: PessoaResponsavel.fromMap(
        Map<String, dynamic>.from(map['responsavel'] as Map),
      ),
    );
  }

  String get marca => _marca;
  set marca(String valor) => _marca = _validarTexto(valor, 'marca');

  String get modelo => _modelo;
  set modelo(String valor) => _modelo = _validarTexto(valor, 'modelo');

  int get ano => _ano;
  set ano(int valor) => _ano = _validarAno(valor);

  PessoaResponsavel get responsavel => _responsavel;
  set responsavel(PessoaResponsavel novo) {
    _responsavel.desvincularVeiculo(this);
    _responsavel = novo;
    _responsavel.vincularVeiculo(this);
  }

  List<Atendimento> consultarHistorico() {
    final lista = List<Atendimento>.of(_historico)
      ..sort((a, b) => a.dataEntrada.compareTo(b.dataEntrada));
    return List.unmodifiable(lista);
  }

  void registrarAtendimento(Atendimento atendimento) {
    if (atendimento.veiculo.placa != placa) {
      throw ArgumentError('O atendimento não pertence ao veículo $placa.');
    }
    _historico.removeWhere((a) => a.id == atendimento.id);
    _historico.add(atendimento);
  }

  Veiculo copyWith({
    String? marca,
    String? modelo,
    int? ano,
    PessoaResponsavel? responsavel,
  }) {
    final copia = Veiculo(
      placa: placa,
      marca: marca ?? _marca,
      modelo: modelo ?? _modelo,
      ano: ano ?? _ano,
      responsavel: responsavel ?? _responsavel,
    );
    copia._historico.addAll(_historico);
    return copia;
  }

  Map<String, dynamic> toMap() => {
        'placa': placa,
        'id_pessoa': _responsavel.id,
        'marca': _marca,
        'modelo': _modelo,
        'ano': _ano,
        'responsavel': _responsavel.toMap(),
      };

  @override
  String toString() =>
      'Veiculo(placa: $placa, marca: $_marca, modelo: $_modelo, ano: $_ano, responsavel: ${_responsavel.nome})';

  static String _validarPlaca(String valor) {
    final normalizada = valor.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$').hasMatch(normalizada)) {
      throw ArgumentError('Placa inválida: $valor');
    }
    return normalizada;
  }

  static String _validarTexto(String valor, String campo) {
    final texto = valor.trim();
    if (texto.isEmpty) {
      throw ArgumentError('O campo $campo não pode ser vazio.');
    }
    return texto;
  }

  static int _validarAno(int valor) {
    final limite = DateTime.now().year + 1;
    if (valor < 1900 || valor > limite) {
      throw ArgumentError('Ano inválido: $valor');
    }
    return valor;
  }
}
