import '../core/json_utils.dart';
import 'enums.dart';

/// Produto = caixa d'água.
class Produto {
  const Produto({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.altura,
    required this.largura,
    required this.profundidade,
    required this.cor,
    required this.material,
    required this.formato,
    required this.fornecedor,
    required this.preco,
    required this.status,
    required this.quantidade,
    this.dtCriacao,
  });

  final int id;
  final String marca, modelo, fornecedor;
  final double altura, largura, profundidade;
  final Cor cor;
  final MaterialCaixa material;
  final Formato formato;
  final double preco;
  final StatusCadastro status;
  final int quantidade;
  final DateTime? dtCriacao;

  bool get ativo => status == StatusCadastro.ATIVO;
  String get nome => '$marca $modelo';

  factory Produto.fromJson(Map<String, dynamic> j) => Produto(
        id: numI(j['id']),
        marca: (j['marca'] ?? '') as String,
        modelo: (j['modelo'] ?? '') as String,
        altura: numD(j['altura']),
        largura: numD(j['largura']),
        profundidade: numD(j['profundidade']),
        cor: enumDe(Cor.values, j['cor'], Cor.BRANCO),
        material: enumDe(MaterialCaixa.values, j['material'], MaterialCaixa.POLIETILENO),
        formato: enumDe(Formato.values, j['formato'], Formato.CILINDRICO),
        fornecedor: (j['fornecedor'] ?? '') as String,
        preco: numD(j['preco']),
        status: enumDe(StatusCadastro.values, j['status'], StatusCadastro.ATIVO),
        quantidade: numI(j['quantidade']),
        dtCriacao: dataHoraJson(j['dtCriacao']),
      );
}
