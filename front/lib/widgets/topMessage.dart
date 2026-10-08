import 'dart:async';
import 'package:flutter/material.dart';

/// Alerta de erro que aparece no topo da tela e some sozinho.
///
/// Uso:
///   TopErrorAlert.show(context, 'Email ou senha inválidos');
///   TopErrorAlert.show(context, 'Sem conexão', duration: Duration(seconds: 5));
class TopMessage {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    Color color = const Color.fromARGB(255, 229, 57, 53),
    Duration duration = const Duration(seconds: 3),
  }) {
    // Se já existir um alerta na tela, remove antes de mostrar o novo.
    _remove();

    final key = GlobalKey<_TopMessageWidgetState>();

    _entry = OverlayEntry(
      builder: (_) => _TopMessageWidget(
        key: key,
        message: message,
        color: color,
        onDismissed: _remove,
      ),
    );

    Overlay.of(context).insert(_entry!);

    // Depois do tempo definido, pede para o widget animar a saída.
    _timer = Timer(duration, () => key.currentState?.hide());
  }

  static void _remove() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _TopMessageWidget extends StatefulWidget {
  final String message;
  final Color color;
  final VoidCallback onDismissed;

  const _TopMessageWidget({
    super.key,
    required this.message,
    required this.color,
    required this.onDismissed,
  });

  @override
  State<_TopMessageWidget> createState() => _TopMessageWidgetState();
}

class _TopMessageWidgetState extends State<_TopMessageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1), // começa acima da tela
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
  }

  Future<void> hide() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // respeita a barra de status / notch
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: hide, // permite fechar manualmente
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}