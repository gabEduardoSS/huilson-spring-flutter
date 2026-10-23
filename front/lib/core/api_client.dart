import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Erro já traduzido para o usuário. O back-end responde em RFC 7807 (ProblemDetail):
/// `{ status, title, detail, erros?: { campo: mensagem } }`.
class ApiException implements Exception {
  ApiException(this.mensagem, {this.status, this.erros = const {}});

  final String mensagem;
  final int? status;
  final Map<String, String> erros;

  /// Mensagem + um item por campo inválido.
  String get completa => erros.isEmpty
      ? mensagem
      : '$mensagem\n${erros.values.map((e) => '• $e').join('\n')}';

  @override
  String toString() => completa;
}

class ApiClient {
  ApiClient(this.baseUrl, {http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  Future<dynamic> get(String path, {Map<String, String?>? query}) =>
      _enviar('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body}) => _enviar('POST', path, body: body);

  Future<dynamic> patch(String path, {Object? body}) => _enviar('PATCH', path, body: body);

  Future<void> delete(String path) async {
    await _enviar('DELETE', path);
  }

  Uri _uri(String path, Map<String, String?>? query) {
    final q = <String, String>{};
    query?.forEach((k, v) {
      if (v != null && v.isNotEmpty) q[k] = v;
    });
    final uri = Uri.parse('$baseUrl$path');
    return q.isEmpty ? uri : uri.replace(queryParameters: q);
  }

  Future<dynamic> _enviar(
    String metodo,
    String path, {
    Map<String, String?>? query,
    Object? body,
  }) async {
    final req = http.Request(metodo, _uri(path, query));
    req.headers['Accept'] = 'application/json';
    if (body != null) {
      // Só envia Content-Type quando há corpo (evita preflight desnecessário no Flutter Web).
      req.headers['Content-Type'] = 'application/json; charset=utf-8';
      req.body = jsonEncode(body);
    }

    final http.Response resp;
    try {
      final streamed = await _client.send(req).timeout(_timeout);
      resp = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('O servidor demorou demais para responder ($baseUrl).');
    } on http.ClientException {
      throw ApiException(
        'Não foi possível conectar ao servidor ($baseUrl). '
        'Verifique se o back-end está em execução.',
      );
    }

    final texto = utf8.decode(resp.bodyBytes, allowMalformed: true);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (texto.trim().isEmpty) return null;
      return jsonDecode(texto);
    }
    throw _traduzirErro(resp.statusCode, texto);
  }

  ApiException _traduzirErro(int status, String corpo) {
    String? detalhe;
    var erros = <String, String>{};
    try {
      final j = jsonDecode(corpo);
      if (j is Map<String, dynamic>) {
        detalhe = (j['detail'] ?? j['message'] ?? j['title']) as String?;
        final e = j['erros'];
        if (e is Map) {
          erros = e.map((k, v) => MapEntry('$k', '$v'));
        }
      }
    } catch (_) {/* corpo não é JSON */}

    final padrao = switch (status) {
      400 => 'Requisição inválida.',
      401 => 'Usuário ou senha inválidos.',
      404 => 'Registro não encontrado.',
      409 => 'Conflito com o estado atual do registro.',
      422 => 'A operação fere uma regra de negócio.',
      >= 500 => 'Erro interno do servidor (HTTP $status).',
      _ => 'Erro inesperado (HTTP $status).',
    };
    return ApiException(detalhe ?? padrao, status: status, erros: erros);
  }
}
