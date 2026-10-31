import 'tipo_trabalho.dart';

class ItemAtendimento {
  final int id;
  final TipoTrabalho tipoTrabalho;
  final double valorCobrado;

  ItemAtendimento({
    required this.id,
    required this.tipoTrabalho,
    double? valorCobrado,
  }) : valorCobrado = _validarValor(valorCobrado ?? tipoTrabalho.valorPadrao);

  factory ItemAtendimento.fromMap(Map<String, dynamic> map) {
    return ItemAtendimento(
      id: map['id_item'] as int,
      tipoTrabalho: TipoTrabalho.fromMap(
        Map<String, dynamic>.from(map['tipo_trabalho'] as Map),
      ),
      valorCobrado: (map['valor_cobrado'] as num).toDouble(),
    );
  }

  String descrever() =>
      '${tipoTrabalho.descricao}: R\$ ${valorCobrado.toStringAsFixed(2)}';

  ItemAtendimento copyWith({TipoTrabalho? tipoTrabalho, double? valorCobrado}) {
    return ItemAtendimento(
      id: id,
      tipoTrabalho: tipoTrabalho ?? this.tipoTrabalho,
      valorCobrado: valorCobrado ?? this.valorCobrado,
    );
  }

  Map<String, dynamic> toMap() => {
        'id_item': id,
        'id_trabalho': tipoTrabalho.id,
        'tipo_trabalho': tipoTrabalho.toMap(),
        'valor_cobrado': valorCobrado,
      };

  @override
  String toString() =>
      'ItemAtendimento(id: $id, trabalho: ${tipoTrabalho.descricao}, valorCobrado: R\$ ${valorCobrado.toStringAsFixed(2)})';

  static double _validarValor(double valor) {
    if (valor < 0) {
      throw ArgumentError('O valor cobrado não pode ser negativo.');
    }
    return valor;
  }
}
