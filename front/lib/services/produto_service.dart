import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/enums.dart';
import '../models/produto.dart';

class ProdutoService {
  ProdutoService(this._api);
  final ApiClient _api;

  Future<List<Produto>> listar({StatusCadastro? status}) async =>
      listaDe(await _api.get('/produtos', query: {'status': status?.name}), Produto.fromJson);

  Future<Produto> buscar(int id) async =>
      Produto.fromJson(await _api.get('/produtos/$id') as Map<String, dynamic>);

  /// Todo produto nasce ATIVO e com estoque zero (o estoque só muda por compras e vendas).
  Future<Produto> cadastrar(Map<String, dynamic> dados) async =>
      Produto.fromJson(await _api.post('/produtos', body: dados) as Map<String, dynamic>);

  Future<Produto> alterar(int id, Map<String, dynamic> dados) async =>
      Produto.fromJson(await _api.patch('/produtos/$id', body: dados) as Map<String, dynamic>);

  Future<Produto> desativar(int id) async =>
      Produto.fromJson(await _api.post('/produtos/$id/desativar') as Map<String, dynamic>);

  Future<Produto> reativar(int id) async =>
      Produto.fromJson(await _api.post('/produtos/$id/reativar') as Map<String, dynamic>);

  /// 409 se o produto já tiver histórico de estoque (nesse caso, desative).
  Future<void> excluir(int id) => _api.delete('/produtos/$id');
}
