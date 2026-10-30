import '../core/json_utils.dart';
import 'enums.dart';

class ItemPedido {
  const ItemPedido({
    required this.id,
    required this.produtoId,
    required this.movimentacaoId,
    required this.precoUnitario,
    required this.quantidade,
    required this.precoTotal,
  });

  final int id, produtoId, movimentacaoId, quantidade;
  final double precoUnitario, precoTotal;

  factory ItemPedido.fromJson(Map<String, dynamic> j) => ItemPedido(
        id: numI(j['id']),
        produtoId: numI(j['produtoId']),
        movimentacaoId: numI(j['movimentacaoId']),
        precoUnitario: numD(j['precoUnitario']),
        quantidade: numI(j['quantidade']),
        precoTotal: numD(j['precoTotal']),
      );
}

class Venda {
  const Venda({
    required this.id,
    required this.transacaoId,
    required this.vendedorId,
    required this.clienteId,
    required this.valorTotal,
    required this.valorDesconto,
    required this.status,
    this.descricao,
    this.data,
    this.itens,
  });

  final int id, transacaoId, vendedorId, clienteId;
  final String? descricao;
  final double valorTotal, valorDesconto;
  final StatusFinanceiro status;
  final DateTime? data;

  /// Só vem preenchido na resposta da criação; `GET /api/vendas` devolve `itens: null`.
  final List<ItemPedido>? itens;

  double get valorLiquido => valorTotal - valorDesconto;

  factory Venda.fromJson(Map<String, dynamic> j) => Venda(
        id: numI(j['id']),
        transacaoId: numI(j['transacaoId']),
        vendedorId: numI(j['vendedorId']),
        clienteId: numI(j['clienteId']),
        descricao: j['descricao'] as String?,
        valorTotal: numD(j['valorTotal']),
        valorDesconto: numD(j['valorDesconto']),
        status: enumDe(StatusFinanceiro.values, j['status'], StatusFinanceiro.CONCLUIDA),
        data: dataHoraJson(j['data']),
        itens: j['itens'] == null ? null : listaDe(j['itens'], ItemPedido.fromJson),
      );
}

class Compra {
  const Compra({
    required this.id,
    required this.transacaoId,
    required this.requisitorId,
    required this.valorTotal,
    required this.valorDesconto,
    required this.status,
    required this.itens,
    this.descricao,
    this.data,
  });

  final int id, transacaoId, requisitorId;
  final String? descricao;
  final double valorTotal, valorDesconto;
  final StatusFinanceiro status;
  final DateTime? data;
  final List<ItemPedido> itens;

  double get valorLiquido => valorTotal - valorDesconto;

  factory Compra.fromJson(Map<String, dynamic> j) => Compra(
        id: numI(j['id']),
        transacaoId: numI(j['transacaoId']),
        requisitorId: numI(j['requisitorId']),
        descricao: j['descricao'] as String?,
        valorTotal: numD(j['valorTotal']),
        valorDesconto: numD(j['valorDesconto']),
        status: enumDe(StatusFinanceiro.values, j['status'], StatusFinanceiro.CONCLUIDA),
        data: dataHoraJson(j['data']),
        itens: listaDe(j['itens'] ?? const [], ItemPedido.fromJson),
      );
}
