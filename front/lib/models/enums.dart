// ignore_for_file: constant_identifier_names
//
// Os NOMES das constantes são exatamente os do back-end Kotlin: é o que o Jackson envia/recebe
// (`enum.name` == "AZUL_FORTE"). Dart puro: as cores/ícones ficam em widgets/visual.dart.

enum Cor {
  AZUL_FORTE('Azul forte'),
  AZUL_FRACO('Azul fraco'),
  BRANCO('Branco'),
  CINZA('Cinza');

  const Cor(this.label);
  final String label;
}

/// No back-end chama-se `Material`; aqui tem sufixo para não colidir com o widget `Material` do Flutter.
enum MaterialCaixa {
  POLIETILENO('Polietileno'),
  FIBRA_DE_VIDRO('Fibra de vidro'),
  INOX('Inox');

  const MaterialCaixa(this.label);
  final String label;
}

enum Formato {
  CILINDRICO('Cilíndrico'),
  CONICO('Cônico'),
  CUBICO('Cúbico');

  const Formato(this.label);
  final String label;
}

enum Cargo {
  INSTALACAO('Instalação'),
  FINANCEIRO('Financeiro'),
  ADMINISTRATIVO('Administrativo'),
  LOGISTICA('Logística'),
  ATENDIMENTO('Atendimento');

  const Cargo(this.label);
  final String label;
}

enum Turno {
  MATUTINO('Matutino'),
  VESPERTINO('Vespertino'),
  NOTURNO('Noturno');

  const Turno(this.label);
  final String label;
}

enum StatusCadastro {
  ATIVO('Ativo'),
  DESATIVADO('Desativado');

  const StatusCadastro(this.label);
  final String label;
}

enum StatusFinanceiro {
  CONCLUIDA('Concluída'),
  CANCELADA('Cancelada'),
  REEMBOLSADA('Reembolsada');

  const StatusFinanceiro(this.label);
  final String label;
}

enum TipoTransacao {
  ENTRADA('Entrada'),
  SAIDA('Saída');

  const TipoTransacao(this.label);
  final String label;
}

enum TipoMovimentacao {
  ENTRADA('Entrada'),
  SAIDA('Saída');

  const TipoMovimentacao(this.label);
  final String label;
}

enum TipoPessoa {
  CLIENTE('Cliente'),
  FUNCIONARIO('Funcionário');

  const TipoPessoa(this.label);
  final String label;
}
