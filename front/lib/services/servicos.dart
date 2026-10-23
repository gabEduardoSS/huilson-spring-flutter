import '../core/api_client.dart';
import '../core/config.dart';
import 'auth_service.dart';
import 'cliente_service.dart';
import 'financeiro_service.dart';
import 'funcionario_service.dart';
import 'pedido_service.dart';
import 'produto_service.dart';

/// Ponto único de acesso à API (um [ApiClient] compartilhado).
class Servicos {
  Servicos() : _api = ApiClient(apiBaseUrl);

  final ApiClient _api;

  late final auth = AuthService(_api);
  late final clientes = ClienteService(_api);
  late final funcionarios = FuncionarioService(_api);
  late final produtos = ProdutoService(_api);
  late final pedidos = PedidoService(_api);
  late final financeiro = FinanceiroService(_api);
}

final servicos = Servicos();
