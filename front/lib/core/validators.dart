import 'formatters.dart';

/// Mesmas regras (Padroes.kt) que o back-end aplica com Bean Validation,
/// para o usuário ver o erro antes de enviar.

String? obrigatorio(String? v, [String msg = 'Campo obrigatório']) =>
    (v == null || v.trim().isEmpty) ? msg : null;

String? validaCpf(String? v) =>
    soDigitos(v ?? '').length == 11 ? null : 'CPF deve ter 11 dígitos';

final _email = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z.]+$');
String? validaEmail(String? v) =>
    _email.hasMatch((v ?? '').trim()) ? null : 'Email inválido';

String? validaTelefone(String? v) {
  final n = soDigitos(v ?? '').length;
  return (n == 10 || n == 11) ? null : 'Use DDD + número (10 ou 11 dígitos)';
}

final _cidade = RegExp(r'^[A-Za-zÀ-ÿ\s]+$');
String? validaCidade(String? v) =>
    _cidade.hasMatch((v ?? '').trim()) ? null : 'Use apenas letras';

final _numeroEndereco = RegExp(r'^[A-Za-z0-9]+$');
String? validaNumeroEndereco(String? v) =>
    _numeroEndereco.hasMatch((v ?? '').trim()) ? null : 'Letras/dígitos (ex.: 120)';

/// Aceita "1.234,56", "1234,56" ou "1234.56".
double? parseDecimal(String? s) {
  var t = (s ?? '').trim();
  if (t.isEmpty) return null;
  if (t.contains(',')) t = t.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(t);
}

String? validaPositivo(String? v, [String campo = 'Valor']) {
  final n = parseDecimal(v);
  return (n == null || n <= 0) ? '$campo deve ser maior que zero' : null;
}

String? validaInteiroPositivo(String? v) {
  final n = int.tryParse((v ?? '').trim());
  return (n == null || n <= 0) ? 'Inválido' : null;
}

String? validaUsuario(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Informe o usuário';
  if (t.length < 5) return 'Mínimo de 5 caracteres';
  if (t.contains(RegExp(r'\s'))) return 'Não pode conter espaços';
  return null;
}

String? validaSenha(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Informe a senha';
  if (t.length < 5) return 'Mínimo de 5 caracteres';
  if (utf8Length(t) > 72) return 'Máximo de 72 bytes';
  return null;
}

int utf8Length(String s) {
  var n = 0;
  for (final r in s.runes) {
    n += r < 0x80 ? 1 : r < 0x800 ? 2 : r < 0x10000 ? 3 : 4;
  }
  return n;
}
