/// Resposta do ViaCEP: https://viacep.com.br/ws/{cep}/json/
class EnderecoCep {
  const EnderecoCep({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.ibge,
    this.ddd,
  });

  final String cep, logradouro, complemento, bairro, cidade, uf;
  final String? ibge, ddd;

  /// Formato que o back-end exige no campo `cidade`: "Cidade, UF".
  String get cidadeUf => '$cidade, $uf';

  factory EnderecoCep.fromJson(Map<String, dynamic> j) => EnderecoCep(
        cep: (j['cep'] ?? '') as String,
        logradouro: (j['logradouro'] ?? '') as String,
        complemento: (j['complemento'] ?? '') as String,
        bairro: (j['bairro'] ?? '') as String,
        cidade: (j['localidade'] ?? '') as String, // o ViaCEP chama a cidade de "localidade"
        uf: (j['uf'] ?? '') as String,
        ibge: j['ibge'] as String?,
        ddd: j['ddd'] as String?,
      );
}
