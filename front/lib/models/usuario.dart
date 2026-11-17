class Usuario {
  const Usuario({required this.id, required this.usuario, required this.token, required this.expiraEm});
  final int id;
  final String usuario;
  final String token;
  final int expiraEm;

  factory Usuario.fromJson(Map<String, dynamic> j) =>
      Usuario(id: (j['id'] as num).toInt(), usuario: j['usuario'] as String, token: j['token'] as String, expiraEm: j['expiraEm'] as int);
}
