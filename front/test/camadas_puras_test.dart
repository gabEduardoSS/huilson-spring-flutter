import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:gestao_comercial/core/api_client.dart';
import 'package:gestao_comercial/core/formatters.dart';
import 'package:gestao_comercial/core/json_utils.dart';
import 'package:gestao_comercial/core/validators.dart';
import 'package:gestao_comercial/models/cliente.dart';
import 'package:gestao_comercial/models/consulta.dart';
import 'package:gestao_comercial/models/enums.dart';
import 'package:gestao_comercial/models/funcionario.dart';
import 'package:gestao_comercial/models/pedido.dart';
import 'package:gestao_comercial/models/produto.dart';
import 'package:gestao_comercial/services/produto_service.dart';
import 'package:gestao_comercial/services/pedido_service.dart';

/// Resposta em UTF-8, como o Spring envia (o `Response(String)` do http usaria latin1).
http.Response resposta(int status, Object corpo) => http.Response.bytes(
      corpo is String ? utf8.encode(corpo) : utf8.encode(jsonEncode(corpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('formatters', () {
    test('moeda', () {
      expect(moeda(1234.5), equals('R\$ 1.234,50'));
      expect(moeda(0), equals('R\$ 0,00'));
      expect(moeda(-10.239), equals('-R\$ 10,24'));
      expect(moeda(1234567.891), equals('R\$ 1.234.567,89'));
    });
    test('numeroBr', () {
      expect(numeroBr(1.2), equals('1,2'));
      expect(numeroBr(1.0), equals('1'));
      expect(numeroBr(0.85), equals('0,85'));
    });
    test('cpf, telefone, datas', () {
      expect(fmtCpf('12345678901'), equals('123.456.789-01'));
      expect(fmtTelefone('44999998888'), equals('(44) 99999-8888'));
      expect(fmtTelefone('4432221111'), equals('(44) 3222-1111'));
      expect(dataBr(DateTime(2026, 3, 5)), equals('05/03/2026'));
      expect(dataHoraBr(DateTime(2026, 3, 5, 9, 7)), equals('05/03/2026 09:07'));
      expect(dataIso(DateTime(1999, 1, 2)), equals('1999-01-02'));
    });
    test('separarUltimaVirgula', () {
      expect(separarUltimaVirgula('Umuarama, PR'), equals(('Umuarama', 'PR')));
      expect(separarUltimaVirgula('Rua A, B, 120'), equals(('Rua A, B', '120')));
      expect(separarUltimaVirgula('sem virgula'), equals(('sem virgula', '')));
    });
  });

  group('validators (mesmas regras do Padroes.kt)', () {
    test('cpf/telefone/email', () {
      expect(validaCpf('123.456.789-01'), isNull);
      expect(validaCpf('123'), isNotNull);
      expect(validaTelefone('44999998888'), isNull);
      expect(validaTelefone('999'), isNotNull);
      expect(validaEmail('a@b.com'), isNull);
      expect(validaEmail('a@b'), isNotNull);
    });
    test('cidade/numero', () {
      expect(validaCidade('São Paulo'), isNull);
      expect(validaCidade('Sao-Paulo'), isNotNull);
      expect(validaNumeroEndereco('120'), isNull);
      expect(validaNumeroEndereco('S/N'), isNotNull);
    });
    test('decimal', () {
      expect(parseDecimal('1.234,56'), equals(1234.56));
      expect(parseDecimal('10,5'), equals(10.5));
      expect(parseDecimal('10.5'), equals(10.5));
      expect(parseDecimal(''), isNull);
      expect(validaPositivo('0'), isNotNull);
      expect(validaPositivo('2,5'), isNull);
    });
    test('usuario/senha', () {
      expect(validaUsuario('abc'), isNotNull);
      expect(validaUsuario('ab cde'), isNotNull);
      expect(validaUsuario('admin'), isNull);
      expect(validaSenha('1234'), isNotNull);
      expect(validaSenha('12345'), isNull);
      expect(validaSenha('é' * 40), isNotNull); // 80 bytes > 72
    });
  });

  group('modelos x JSON do back-end', () {
    test('datas: ISO e array do Jackson', () {
      expect(dataHoraJson('2026-10-21T20:30:00'), equals(DateTime(2026, 10, 21, 20, 30)));
      expect(dataHoraJson([2026, 10, 21, 20, 30, 5, 123]), equals(DateTime(2026, 10, 21, 20, 30, 5)));
      expect(dataHoraJson('1990-05-17'), equals(DateTime(1990, 5, 17)));
      expect(dataHoraJson(null), isNull);
    });

    test('Cliente', () {
      final c = Cliente.fromJson({
        'id': 3, 'tipo': 'CLIENTE', 'nome': 'Maria', 'cpf': '12345678901',
        'email': 'm@x.com', 'telefone': '44999998888', 'cidade': 'Umuarama, PR',
        'endereco': 'Rua A, 10', 'dtNasc': '1990-05-17', 'dividasAbertas': true,
        'dtCriacao': '2026-10-21T20:30:00.123456',
      });
      expect(c.id, equals(3));
      expect(c.dtNasc, equals(DateTime(1990, 5, 17)));
      expect(c.dividasAbertas, isTrue);
      expect(Cliente.fromJson({'id': 1, 'dtNasc': null}).dtNasc, isNull);
    });

    test('Funcionario', () {
      final f = Funcionario.fromJson({
        'id': 2, 'tipo': 'FUNCIONARIO', 'nome': 'Joao', 'cpf': '1', 'email': 'e',
        'telefone': 't', 'cidade': 'c', 'endereco': 'e', 'dtNasc': '1985-01-01',
        'salario': 3500.5, 'turno': 'NOTURNO', 'cargo': 'FINANCEIRO',
        'status': 'DESATIVADO', 'dtCriacao': '2026-10-21T20:30:00',
      });
      expect(f.cargo, equals(Cargo.FINANCEIRO));
      expect(f.turno, equals(Turno.NOTURNO));
      expect(f.ativo, isFalse);
      expect(f.salario, equals(3500.5));
    });

    test('Produto (dimensões separadas, BigDecimal como número)', () {
      final p = Produto.fromJson({
        'id': 7, 'marca': 'Fortlev', 'modelo': 'F1000', 'altura': 1.2, 'largura': 1,
        'profundidade': 0.8, 'cor': 'AZUL_FORTE', 'material': 'FIBRA_DE_VIDRO',
        'formato': 'CILINDRICO', 'fornecedor': 'Acme', 'preco': 899.9,
        'status': 'ATIVO', 'quantidade': 4, 'dtCriacao': '2026-10-21T20:30:00',
      });
      expect(p.nome, equals('Fortlev F1000'));
      expect(p.largura, equals(1.0));
      expect(p.material, equals(MaterialCaixa.FIBRA_DE_VIDRO));
      expect(p.cor, equals(Cor.AZUL_FORTE));
      expect(p.ativo, isTrue);
    });

    test('Venda (listagem sem itens) e Compra (com itens)', () {
      final v = Venda.fromJson({
        'id': 1, 'transacaoId': 2, 'vendedorId': 3, 'clienteId': 4, 'descricao': null,
        'valorTotal': 100, 'valorDesconto': 10, 'status': 'CONCLUIDA',
        'data': '2026-10-21T20:30:00', 'itens': null,
      });
      expect(v.itens, isNull);
      expect(v.valorLiquido, equals(90.0));

      final c = Compra.fromJson({
        'id': 1, 'transacaoId': 2, 'requisitorId': 3, 'descricao': 'x',
        'valorTotal': 50, 'valorDesconto': 0, 'status': 'CONCLUIDA',
        'data': '2026-10-21T20:30:00',
        'itens': [
          {'id': 1, 'produtoId': 7, 'movimentacaoId': 9, 'precoUnitario': 25, 'quantidade': 2, 'precoTotal': 50},
        ],
      });
      expect(c.itens.length, equals(1));
      expect(c.itens.first.precoTotal, equals(50.0));
    });

    test('Transacao/Movimentacao detalhadas e resumidas', () {
      final t = Transacao.fromJson({
        'id': 1, 'pessoaId': 2, 'tipo': 'SAIDA', 'valor': 10, 'saldoAnterior': 100,
        'saldoPosterior': 90, 'status': 'CONCLUIDA', 'data': '2026-10-21T20:30:00',
        'pessoa': {'id': 2, 'tipo': 'FUNCIONARIO', 'nome': 'Ana', 'cpf': '1', 'email': 'e', 'telefone': 't',
          'cidade': 'c', 'endereco': 'e', 'dtNasc': null},
      });
      expect(t.tipo, equals(TipoTransacao.SAIDA));
      expect(t.pessoa!.nome, equals('Ana'));
      final m = Movimentacao.fromJson({
        'id': 1, 'produtoId': 7, 'tipo': 'ENTRADA', 'quantidade': 3, 'descricao': null,
        'quantidadeAnterior': 1, 'quantidadePosterior': 4, 'status': 'CONCLUIDA',
        'data': '2026-10-21T20:30:00', 'produto': null,
      });
      expect(m.produto, isNull);
      expect(m.quantidadePosterior, equals(4));
    });
  });

  group('ApiClient / serviços', () {
    ApiClient api(MockClient mock) => ApiClient('http://x/api', client: mock);

    test('GET com filtro envia ?status=ATIVO e ignora nulos', () async {
      late Uri chamada;
      final svc = ProdutoService(api(MockClient((req) async {
        chamada = req.url;
        return resposta(200, '[]');
      })));
      await svc.listar(status: StatusCadastro.ATIVO);
      expect(chamada.toString(), equals('http://x/api/produtos?status=ATIVO'));
      await svc.listar();
      expect(chamada.toString(), equals('http://x/api/produtos'));
    });

    test('POST serializa JSON e lê a resposta (UTF-8)', () async {
      late http.Request req;
      final svc = PedidoService(api(MockClient((r) async {
        req = r;
        return resposta(201, {
          'id': 1, 'transacaoId': 2, 'vendedorId': 3, 'clienteId': 4, 'descricao': 'Instalação',
          'valorTotal': 100, 'valorDesconto': 0, 'status': 'CONCLUIDA',
          'data': '2026-10-21T20:30:00', 'itens': [],
        });
      })));
      final v = await svc.criarVenda({'vendedorId': 3, 'clienteId': 4, 'itens': []});
      expect(req.url.path, equals('/api/vendas/criar'));
      expect(req.method, equals('POST'));
      expect(jsonDecode(req.body)['vendedorId'], equals(3));
      expect(v.descricao, equals('Instalação'));
    });

    test('ProblemDetail 422 vira mensagem amigável', () async {
      final svc = PedidoService(api(MockClient((_) async => resposta(422, {
            'status': 422, 'title': 'Regra de negócio violada',
            'detail': 'Saldo insuficiente no caixa: disponível 10, necessário 50',
          }))));
      try {
        await svc.criarCompra({});
        fail('deveria lançar');
      } on ApiException catch (e) {
        expect(e.status, equals(422));
        expect(e.mensagem, equals('Saldo insuficiente no caixa: disponível 10, necessário 50'));
      }
    });

    test('Bean Validation 400 traz o mapa de erros por campo', () async {
      final svc = ProdutoService(api(MockClient((_) async => resposta(400, {
            'status': 400, 'title': 'Dados inválidos', 'detail': 'Há campos inválidos na requisição.',
            'erros': {'altura': 'Altura deve ser maior que zero', 'marca': 'Marca é obrigatória'},
          }))));
      try {
        await svc.cadastrar({});
        fail('deveria lançar');
      } on ApiException catch (e) {
        expect(e.erros.length, equals(2));
        expect(e.completa.contains('• Altura deve ser maior que zero'), isTrue);
      }
    });

    test('DELETE 204 sem corpo e 409 de histórico', () async {
      var status = 204;
      final svc = ProdutoService(api(MockClient((_) async => status == 204
          ? resposta(204, '')
          : resposta(409, {'detail': 'possui movimentações'}))));
      await svc.excluir(1);
      status = 409;
      try {
        await svc.excluir(1);
        fail('deveria lançar');
      } on ApiException catch (e) {
        expect(e.status, equals(409));
        expect(e.mensagem, equals('possui movimentações'));
      }
    });

    test('servidor fora do ar vira mensagem clara', () async {
      final svc = ProdutoService(api(MockClient((_) async => throw http.ClientException('Failed to fetch'))));
      try {
        await svc.listar();
        fail('deveria lançar');
      } on ApiException catch (e) {
        expect(e.mensagem.contains('Não foi possível conectar'), isTrue);
      }
    });
  });
}
