import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/cliente.dart';

class ClienteService {
  ClienteService(this._api);
  final ApiClient _api;

  Future<List<Cliente>> listar() async =>
      listaDe(await _api.get('/clientes'), Cliente.fromJson);

  Future<Cliente> buscar(int id) async =>
      Cliente.fromJson(await _api.get('/clientes/$id') as Map<String, dynamic>);

  Future<Cliente> cadastrar(Map<String, dynamic> dados) async =>
      Cliente.fromJson(await _api.post('/clientes', body: dados) as Map<String, dynamic>);

  /// PATCH: campos nulos/ausentes mantêm o valor atual.
  Future<Cliente> alterar(int id, Map<String, dynamic> dados) async =>
      Cliente.fromJson(await _api.patch('/clientes/$id', body: dados) as Map<String, dynamic>);
}
