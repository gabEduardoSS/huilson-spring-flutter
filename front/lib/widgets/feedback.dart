import 'package:flutter/material.dart';

import '../core/api_client.dart';

/// Faixa vermelha na base da tela (igual à da imagem de referência).
void mostrarErro(BuildContext context, Object erro) {
  final texto = erro is ApiException ? erro.completa : erro.toString();
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Text(texto, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFFB71C1C),
      showCloseIcon: true,
      closeIconColor: Colors.white,
      duration: const Duration(seconds: 6),
    ),
  );
}

void mostrarSucesso(BuildContext context, String texto) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(texto)));
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String rotuloConfirmar = 'Confirmar',
  bool destrutivo = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(
          style: destrutivo
              ? FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error)
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(rotuloConfirmar),
        ),
      ],
    ),
  );
  return r == true;
}
