/// Helpers de leitura de JSON (Jackson/Spring) — Dart puro, sem Flutter.

double numD(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

int numI(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Aceita ISO-8601 ("2026-10-21T20:00:00") ou o array [ano, mês, dia, h, min, s, nanos]
/// que o Jackson devolve quando WRITE_DATES_AS_TIMESTAMPS está ligado.
DateTime? dataHoraJson(Object? v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  if (v is List && v.length >= 3) {
    final n = v.map(numI).toList();
    return DateTime(
      n[0], n[1], n[2],
      n.length > 3 ? n[3] : 0,
      n.length > 4 ? n[4] : 0,
      n.length > 5 ? n[5] : 0,
    );
  }
  return null;
}

/// "yyyy-MM-dd" (LocalDate).
String dataIso(DateTime d) {
  String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
  return '${p(d.year, 4)}-${p(d.month)}-${p(d.day)}';
}

/// Encontra o valor do enum pelo NOME (é assim que o back-end envia: "AZUL_FORTE").
T enumDe<T extends Enum>(List<T> valores, Object? nome, T padrao) {
  for (final v in valores) {
    if (v.name == nome) return v;
  }
  return padrao;
}

List<T> listaDe<T>(Object? json, T Function(Map<String, dynamic>) de) =>
    (json as List).map((e) => de(e as Map<String, dynamic>)).toList();
