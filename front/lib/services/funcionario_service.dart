import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/enums.dart';
import '../models/funcionario.dart';

class FuncionarioService {
  FuncionarioService(this._api);
  final ApiClient _api;

  /// Os dois filtros são opcionais e combináveis.
  Future<List<Funcionario>> listar({StatusCadastro? status, Cargo? cargo}) async =>
      listaDe(
        await _api.get('/funcionarios', query: {'status': status?.name, 'cargo': cargo?.name}),
        Funcionario.fromJson,
      );

  Future<Funcionario> buscar(int id) async =>
      Funcionario.fromJson(await _api.get('/funcionarios/$id') as Map<String, dynamic>);

  Future<Funcionario> cadastrar(Map<String, dynamic> dados) async => Funcionario.fromJson(
        await _api.post('/funcionarios', body: dados) as Map<String, dynamic>,
      );

  Future<Funcionario> alterar(int id, Map<String, dynamic> dados) async => Funcionario.fromJson(
        await _api.patch('/funcionarios/$id', body: dados) as Map<String, dynamic>,
      );

  Future<Funcionario> desativar(int id) async => Funcionario.fromJson(
        await _api.post('/funcionarios/$id/desativar') as Map<String, dynamic>,
      );

  Future<Funcionario> reativar(int id) async => Funcionario.fromJson(
        await _api.post('/funcionarios/$id/reativar') as Map<String, dynamic>,
      );
}
