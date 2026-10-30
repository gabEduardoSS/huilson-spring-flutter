import '../core/json_utils.dart';
import 'enums.dart';

class Funcionario {
  const Funcionario({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.cidade,
    required this.endereco,
    required this.salario,
    required this.turno,
    required this.cargo,
    required this.status,
    this.dtNasc,
    this.dtCriacao,
  });

  final int id;
  final String nome, cpf, email, telefone, cidade, endereco;
  final DateTime? dtNasc;
  final double salario;
  final Turno turno;
  final Cargo cargo;
  final StatusCadastro status;
  final DateTime? dtCriacao;

  bool get ativo => status == StatusCadastro.ATIVO;

  factory Funcionario.fromJson(Map<String, dynamic> j) => Funcionario(
        id: numI(j['id']),
        nome: (j['nome'] ?? '') as String,
        cpf: (j['cpf'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        telefone: (j['telefone'] ?? '') as String,
        cidade: (j['cidade'] ?? '') as String,
        endereco: (j['endereco'] ?? '') as String,
        dtNasc: dataHoraJson(j['dtNasc']),
        salario: numD(j['salario']),
        turno: enumDe(Turno.values, j['turno'], Turno.MATUTINO),
        cargo: enumDe(Cargo.values, j['cargo'], Cargo.ATENDIMENTO),
        status: enumDe(StatusCadastro.values, j['status'], StatusCadastro.ATIVO),
        dtCriacao: dataHoraJson(j['dtCriacao']),
      );
}
