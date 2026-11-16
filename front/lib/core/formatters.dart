/// Formatadores de exibição (pt-BR) — Dart puro, sem dependência de intl.

String soDigitos(String s) => s.replaceAll(RegExp(r'\D'), '');

String moeda(num v) {
  final neg = v < 0;
  final partes = v.abs().toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${neg ? '-' : ''}R\$ $inteiro,${partes[1]}';
}

/// 1.2 -> "1,2" | 1.0 -> "1" | 0.85 -> "0,85"
String numeroBr(double v) {
  var s = v.toStringAsFixed(2);
  s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return s.replaceAll('.', ',');
}

String _p(int n) => n.toString().padLeft(2, '0');

String dataBr(DateTime? d) => d == null ? '-' : '${_p(d.day)}/${_p(d.month)}/${d.year}';

String dataHoraBr(DateTime? d) =>
    d == null ? '-' : '${dataBr(d)} ${_p(d.hour)}:${_p(d.minute)}';

String fmtCpf(String s) {
  final d = soDigitos(s);
  if (d.length != 11) return s;
  return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
}

String fmtTelefone(String s) {
  final d = soDigitos(s);
  if (d.length == 11) return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
  if (d.length == 10) return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
  return s;
}

String inicial(String nome) {
  final t = nome.trim();
  return t.isEmpty ? '?' : t[0].toUpperCase();
}

/// "Umuarama, PR" -> ("Umuarama", "PR"). Usa a ÚLTIMA vírgula.
(String, String) separarUltimaVirgula(String s) {
  final i = s.lastIndexOf(',');
  if (i < 0) return (s.trim(), '');
  return (s.substring(0, i).trim(), s.substring(i + 1).trim());
}

/// Preenche o DDD vindo do CEP no campo de telefone SEM sobrescrever o que o usuário digitou:
/// só aplica se o campo estiver vazio ou contiver apenas um DDD (até 2 dígitos).
/// Se já houver um número, devolve o texto atual intacto.
String telefoneComDdd(String atual, String? ddd) {
  final novo = soDigitos(ddd ?? '');
  if (novo.length != 2) return atual;
  return soDigitos(atual).length <= 2 ? novo : atual;
}
