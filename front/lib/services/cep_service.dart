import '../core/api_client.dart';
import '../core/formatters.dart';
import '../models/endereco_cep.dart';

class CepService {
  CepService({ApiClient? api})
      : _api = api ?? ApiClient('https://viacep.com.br/ws', servidor: 'serviço ViaCEP');

  final ApiClient _api;

  /// Aceita "87501-020", "87501020" ou com espaços; só os dígitos importam.
  Future<EnderecoCep> consultar(String cep) async {
    final digitos = soDigitos(cep);
    if (digitos.length != 8) {
      throw ApiException('O CEP deve ter 8 dígitos.');
    }

    final json = await _api.get('/$digitos/json/');

    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inesperada do ViaCEP.');
    }
    // CEP com formato válido mas inexistente: o ViaCEP responde 200 com {"erro": true}
    // (em versões antigas, "erro": "true").
    if (json['erro'] == true || json['erro'] == 'true') {
      throw ApiException('CEP não encontrado.', status: 404);
    }
    return EnderecoCep.fromJson(json);
  }
}
