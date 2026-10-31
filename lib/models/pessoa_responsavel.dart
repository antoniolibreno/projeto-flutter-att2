import 'veiculo.dart';

class PessoaResponsavel {
  final int id;
  String _nome;
  String _documento;
  String _telefone;
  String? _email;
  final List<Veiculo> _veiculos = [];

  PessoaResponsavel({
    required this.id,
    required String nome,
    required String documento,
    required String telefone,
    String? email,
  })  : _nome = _validarNome(nome),
        _documento = _validarDocumento(documento),
        _telefone = _validarTelefone(telefone),
        _email = _validarEmail(email);

  factory PessoaResponsavel.fromMap(Map<String, dynamic> map) {
    return PessoaResponsavel(
      id: map['id_pessoa'] as int,
      nome: map['nome'] as String,
      documento: map['documento'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String?,
    );
  }

  String get nome => _nome;
  set nome(String valor) => _nome = _validarNome(valor);

  String get documento => _documento;
  set documento(String valor) => _documento = _validarDocumento(valor);

  String get telefone => _telefone;
  set telefone(String valor) => _telefone = _validarTelefone(valor);

  String? get email => _email;
  set email(String? valor) => _email = _validarEmail(valor);

  List<Veiculo> listarVeiculos() => List.unmodifiable(_veiculos);

  void vincularVeiculo(Veiculo veiculo) {
    _veiculos.removeWhere((v) => v.placa == veiculo.placa);
    _veiculos.add(veiculo);
  }

  void desvincularVeiculo(Veiculo veiculo) {
    _veiculos.removeWhere((v) => v.placa == veiculo.placa);
  }

  PessoaResponsavel copyWith({
    String? nome,
    String? documento,
    String? telefone,
    String? email,
  }) {
    return PessoaResponsavel(
      id: id,
      nome: nome ?? _nome,
      documento: documento ?? _documento,
      telefone: telefone ?? _telefone,
      email: email ?? _email,
    );
  }

  Map<String, dynamic> toMap() => {
        'id_pessoa': id,
        'nome': _nome,
        'documento': _documento,
        'telefone': _telefone,
        'email': _email,
      };

  @override
  String toString() =>
      'PessoaResponsavel(id: $id, nome: $_nome, documento: $_documento, telefone: $_telefone, email: ${_email ?? 'não informado'}, veiculos: ${_veiculos.length})';

  static String _validarNome(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) {
      throw ArgumentError('O nome não pode ser vazio.');
    }
    return texto;
  }

  static String _validarDocumento(String valor) {
    final digitos = valor.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 11 && digitos.length != 14) {
      throw ArgumentError('O documento deve ser um CPF (11 dígitos) ou CNPJ (14 dígitos).');
    }
    return digitos;
  }

  static String _validarTelefone(String valor) {
    final digitos = valor.replaceAll(RegExp(r'\D'), '');
    if (digitos.length < 10 || digitos.length > 11) {
      throw ArgumentError('O telefone deve conter DDD e 8 ou 9 dígitos.');
    }
    return digitos;
  }

  static String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }
    final texto = valor.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto)) {
      throw ArgumentError('E-mail inválido: $texto');
    }
    return texto;
  }
}
