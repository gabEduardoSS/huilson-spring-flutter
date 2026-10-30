import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/pedido.dart';

class PedidoService {
  PedidoService(this._api);
  final ApiClient _api;

  Future<List<Venda>> listarVendas() async =>
      listaDe(await _api.get('/vendas'), Venda.fromJson);

  /// `{vendedorId, clienteId, descricao?, valorDesconto?, itens: [{produtoId, quantidade}]}`
  Future<Venda> criarVenda(Map<String, dynamic> dados) async =>
      Venda.fromJson(await _api.post('/vendas/criar', body: dados) as Map<String, dynamic>);

  /// `{requisitorId, descricao?, valorDesconto?, itens: [{produtoId, quantidade}]}`
  Future<Compra> criarCompra(Map<String, dynamic> dados) async =>
      Compra.fromJson(await _api.post('/compras', body: dados) as Map<String, dynamic>);
}
