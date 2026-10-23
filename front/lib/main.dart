import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/usuario.dart';
import 'screens/home_shell.dart';
import 'screens/login_page.dart';

void main() => runApp(const GestaoComercialApp());

class GestaoComercialApp extends StatefulWidget {
  const GestaoComercialApp({super.key});

  @override
  State<GestaoComercialApp> createState() => _GestaoComercialAppState();
}

class _GestaoComercialAppState extends State<GestaoComercialApp> {
  Usuario? _usuario;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão Comercial',
      debugShowCheckedModeBanner: false,
      // Tema Material 3 padrão (semente roxa), igual ao da imagem de referência.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: _usuario == null
          ? LoginPage(aoEntrar: (u) => setState(() => _usuario = u))
          : HomeShell(usuario: _usuario!, aoSair: () => setState(() => _usuario = null)),
    );
  }
}
