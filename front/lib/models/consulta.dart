import '../core/json_utils.dart';
import 'enums.dart';
import 'produto.dart';

class PessoaResumo {
  const PessoaResumo({
    required this.id,
    required this.tipo,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
  });

  final int id;
  final TipoPessoa tipo;
  final String nome, cpf, email, telefone;

  factory PessoaResumo.fromJson(Map<String, dynamic> j) => PessoaResumo(
        id: numI(j['id']),
        tipo: enumDe(TipoPessoa.values, j['tipo'], TipoPessoa.CLIENTE),
        nome: (j['nome'] ?? '') as String,
        cpf: (j['cpf'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        telefone: (j['telefone'] ?? '') as String,
      );
}

/// Linha do extrato do caixa. [pessoa] só vem com `?detalhado=true`.
class Transacao {
  const Transacao({
    required this.id,
    required this.pessoaId,
    required this.tipo,
    required this.valor,
    required this.saldoAnterior,
    required this.saldoPosterior,
    required this.status,
    this.data,
    this.pessoa,
  });

  final int id, pessoaId;
  final TipoTransacao tipo;
  final double valor, saldoAnterior, saldoPosterior;
  final StatusFinanceiro status;
  final DateTime? data;
  final PessoaResumo? pessoa;

  factory Transacao.fromJson(Map<String, dynamic> j) => Transacao(
        id: numI(j['id']),
        pessoaId: numI(j['pessoaId']),
        tipo: enumDe(TipoTransacao.values, j['tipo'], TipoTransacao.ENTRADA),
        valor: numD(j['valor']),
        saldoAnterior: numD(j['saldoAnterior']),
        saldoPosterior: numD(j['saldoPosterior']),
        status: enumDe(StatusFinanceiro.values, j['status'], StatusFinanceiro.CONCLUIDA),
        data: dataHoraJson(j['data']),
        pessoa: j['pessoa'] == null
            ? null
            : PessoaResumo.fromJson(j['pessoa'] as Map<String, dynamic>),
      );
}

/// Entrada/saída de estoque. [produto] só vem com `?detalhado=true`.
class Movimentacao {
  const Movimentacao({
    required this.id,
    required this.produtoId,
    required this.tipo,
    required this.quantidade,
    required this.quantidadeAnterior,
    required this.quantidadePosterior,
    required this.status,
    this.descricao,
    this.data,
    this.produto,
  });

  final int id, produtoId, quantidade, quantidadeAnterior, quantidadePosterior;
  final TipoMovimentacao tipo;
  final String? descricao;
  final StatusFinanceiro status;
  final DateTime? data;
  final Produto? produto;

  factory Movimentacao.fromJson(Map<String, dynamic> j) => Movimentacao(
        id: numI(j['id']),
        produtoId: numI(j['produtoId']),
        tipo: enumDe(TipoMovimentacao.values, j['tipo'], TipoMovimentacao.ENTRADA),
        quantidade: numI(j['quantidade']),
        descricao: j['descricao'] as String?,
        quantidadeAnterior: numI(j['quantidadeAnterior']),
        quantidadePosterior: numI(j['quantidadePosterior']),
        status: enumDe(StatusFinanceiro.values, j['status'], StatusFinanceiro.CONCLUIDA),
        data: dataHoraJson(j['data']),
        produto: j['produto'] == null
            ? null
            : Produto.fromJson(j['produto'] as Map<String, dynamic>),
      );
}
