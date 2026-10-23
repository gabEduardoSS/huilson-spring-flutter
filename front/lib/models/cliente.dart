import '../core/json_utils.dart';
import 'enums.dart';

class Cliente {
  const Cliente({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.cidade,
    required this.endereco,
    required this.dividasAbertas,
    this.dtNasc,
    this.dtCriacao,
    this.tipo = TipoPessoa.CLIENTE,
  });

  final int id;
  final TipoPessoa tipo;
  final String nome, cpf, email, telefone;
  /// "Cidade, UF"
  final String cidade;
  /// "Rua, número"
  final String endereco;
  final DateTime? dtNasc;
  final bool dividasAbertas;
  final DateTime? dtCriacao;

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
        id: numI(j['id']),
        tipo: enumDe(TipoPessoa.values, j['tipo'], TipoPessoa.CLIENTE),
        nome: (j['nome'] ?? '') as String,
        cpf: (j['cpf'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        telefone: (j['telefone'] ?? '') as String,
        cidade: (j['cidade'] ?? '') as String,
        endereco: (j['endereco'] ?? '') as String,
        dtNasc: dataHoraJson(j['dtNasc']),
        dividasAbertas: (j['dividasAbertas'] ?? false) as bool,
        dtCriacao: dataHoraJson(j['dtCriacao']),
      );
}
