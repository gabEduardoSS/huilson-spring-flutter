import 'package:flutter/material.dart';

import '../models/enums.dart';

Color corDe(Cor c) => switch (c) {
      Cor.AZUL_FORTE => const Color(0xFF0D47A1),
      Cor.AZUL_FRACO => const Color(0xFF64B5F6),
      Cor.BRANCO => const Color(0xFFFFFFFF),
      Cor.CINZA => const Color(0xFF9E9E9E),
    };

IconData iconeFormato(Formato f) => switch (f) {
      Formato.CILINDRICO => Icons.circle_outlined,
      Formato.CONICO => Icons.change_history,
      Formato.CUBICO => Icons.crop_square,
    };

Color corStatusCadastro(StatusCadastro s) =>
    s == StatusCadastro.ATIVO ? Colors.green.shade700 : Colors.orange.shade800;

Color corStatusFinanceiro(StatusFinanceiro s) => switch (s) {
      StatusFinanceiro.CONCLUIDA => Colors.green.shade700,
      StatusFinanceiro.CANCELADA => Colors.red.shade700,
      StatusFinanceiro.REEMBOLSADA => Colors.orange.shade800,
    };

/// Selo pequeno e arredondado (status, "Dívidas"...).
class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, this.cor});

  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final c = cor ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Bolinha com a cor da caixa d'água e o ícone do formato.
class AvatarProduto extends StatelessWidget {
  const AvatarProduto({super.key, required this.cor, required this.formato, this.raio = 20});

  final Cor cor;
  final Formato formato;
  final double raio;

  @override
  Widget build(BuildContext context) {
    final fundo = corDe(cor);
    final claro = fundo.computeLuminance() > 0.6;
    return CircleAvatar(
      radius: raio,
      backgroundColor: fundo,
      foregroundColor: claro ? Colors.black87 : Colors.white,
      child: Icon(iconeFormato(formato), size: raio),
    );
  }
}
