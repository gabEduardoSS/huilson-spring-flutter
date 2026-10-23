import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/consulta.dart';
import '../models/enums.dart';

class FinanceiroService {
  FinanceiroService(this._api);
  final ApiClient _api;

  Future<double> saldo() async {
    final j = await _api.get('/caixa/saldo') as Map<String, dynamic>;
    return numD(j['saldo']);
  }

  Future<List<Transacao>> transacoes({TipoTransacao? tipo, bool detalhado = true}) async =>
      listaDe(
        await _api.get(
          '/consultas/transacoes',
          query: {'tipo': tipo?.name, 'detalhado': '$detalhado'},
        ),
        Transacao.fromJson,
      );

  Future<List<Movimentacao>> movimentacoes({TipoMovimentacao? tipo, bool detalhado = true}) async =>
      listaDe(
        await _api.get(
          '/consultas/movimentacoes',
          query: {'tipo': tipo?.name, 'detalhado': '$detalhado'},
        ),
        Movimentacao.fromJson,
      );
}
