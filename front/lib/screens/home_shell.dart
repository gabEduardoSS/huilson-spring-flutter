import 'package:flutter/material.dart';

import '../models/usuario.dart';
import 'caixa_page.dart';
import 'clientes_page.dart';
import 'compras_page.dart';
import 'funcionarios_page.dart';
import 'produtos_page.dart';
import 'vendas_page.dart';

class _Destino {
  const _Destino(this.rotulo, this.icone, this.iconeSelecionado, this.pagina);
  final String rotulo;
  final IconData icone, iconeSelecionado;
  final Widget Function() pagina;
}

final _destinos = <_Destino>[
  _Destino('Clientes', Icons.people_outline, Icons.people, () => const ClientesPage()),
  _Destino('Funcionários', Icons.badge_outlined, Icons.badge, () => const FuncionariosPage()),
  _Destino('Produtos', Icons.inventory_2_outlined, Icons.inventory_2, () => const ProdutosPage()),
  _Destino('Vendas', Icons.point_of_sale_outlined, Icons.point_of_sale, () => const VendasPage()),
  _Destino('Compras', Icons.shopping_cart_outlined, Icons.shopping_cart, () => const ComprasPage()),
  _Destino('Caixa', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet,
      () => const CaixaPage()),
];

/// Casca do app no estilo da referência: título "Gestão Comercial • Seção" e NavigationRail
/// à esquerda (em telas estreitas vira menu lateral/drawer).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.usuario, required this.aoSair});

  final Usuario usuario;
  final VoidCallback aoSair;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final largo = MediaQuery.sizeOf(context).width >= 720;
    final destino = _destinos[_indice];
    // A key força recarregar os dados ao trocar de aba.
    final conteudo = KeyedSubtree(key: ValueKey(_indice), child: destino.pagina());

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestão Comercial • ${destino.rotulo}'),
        actions: [
          if (largo)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(child: Text(widget.usuario.usuario)),
            ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: widget.aoSair,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: largo
          ? null
          : NavigationDrawer(
              selectedIndex: _indice,
              onDestinationSelected: (i) {
                setState(() => _indice = i);
                Navigator.of(context).pop();
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 16, 12),
                  child: Text(
                    widget.usuario.usuario,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final d in _destinos)
                  NavigationDrawerDestination(
                    icon: Icon(d.icone),
                    selectedIcon: Icon(d.iconeSelecionado),
                    label: Text(d.rotulo),
                  ),
              ],
            ),
      body: largo
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _indice,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (i) => setState(() => _indice = i),
                  destinations: [
                    for (final d in _destinos)
                      NavigationRailDestination(
                        icon: Icon(d.icone),
                        selectedIcon: Icon(d.iconeSelecionado),
                        label: Text(d.rotulo),
                      ),
                  ],
                ),
                Expanded(child: conteudo),
              ],
            )
          : conteudo,
    );
  }
}
