import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/validators.dart';
import '../models/usuario.dart';
import '../services/servicos.dart';
import '../widgets/feedback.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.aoEntrar});

  final ValueChanged<Usuario> aoEntrar;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  bool _registro = false;
  bool _ocultar = true;
  bool _enviando = false;

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final u = _registro
          ? await servicos.auth.registrar(_usuario.text.trim(), _senha.text.trim())
          : await servicos.auth.login(_usuario.text.trim(), _senha.text.trim());
      if (!mounted) return;
      widget.aoEntrar(u);
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      mostrarErro(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.water_drop_outlined, size: 56, color: tema.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Gestão Comercial',
                      textAlign: TextAlign.center, style: tema.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    _registro ? 'Primeiro acesso: crie seu usuário' : 'Entre para continuar',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usuario,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    autofillHints: const [AutofillHints.username],
                    validator: validaUsuario,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senha,
                    obscureText: _ocultar,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _ocultar = !_ocultar),
                      ),
                    ),
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _enviar(),
                    validator: _registro ? validaSenha : (v) => obrigatorio(v, 'Informe a senha'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _enviando ? null : _enviar,
                    child: _enviando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_registro ? 'Criar usuário' : 'Entrar'),
                  ),
                  TextButton(
                    onPressed: _enviando ? null : () => setState(() => _registro = !_registro),
                    child: Text(_registro ? 'Já tenho usuário' : 'Primeiro acesso? Criar usuário'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Servidor: $apiBaseUrl',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall,
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
