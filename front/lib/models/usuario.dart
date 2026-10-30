class Usuario {
  const Usuario({required this.id, required this.usuario});
  final int id;
  final String usuario;

  factory Usuario.fromJson(Map<String, dynamic> j) =>
      Usuario(id: (j['id'] as num).toInt(), usuario: j['usuario'] as String);
}
