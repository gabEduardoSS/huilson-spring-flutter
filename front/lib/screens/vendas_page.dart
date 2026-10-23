import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/cliente.dart';
import '../models/funcionario.dart';
import '../models/pedido.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/lista_page.dart';
import '../widgets/visual.dart';
import 'pedido_form_page.dart';

class _VendaView {
  const _VendaView(this.venda, this.cliente, this.vendedor);
  final Venda venda;
  final String cliente, vendedor;
}

class VendasPage extends StatelessWidget {
  const VendasPage({super.key});

  /// `GET /api/vendas` só traz IDs; buscamos clientes e funcionários para mostrar os nomes.
  Future<List<_VendaView>> _carregar() async {
    final r = await Future.wait<Object>([
      servicos.pedidos.listarVendas(),
      servicos.clientes.listar(),
      servicos.funcionarios.listar(),
    ]);
    final clientes = {for (final c in r[1] as List<Cliente>) c.id: c.nome};
    final funcs = {for (final f in r[2] as List<Funcionario>) f.id: f.nome};
    final lista = [
      for (final v in r[0] as List<Venda>)
        _VendaView(v, clientes[v.clienteId] ?? 'Cliente #${v.clienteId}',
            funcs[v.vendedorId] ?? 'Funcionário #${v.vendedorId}'),
    ];
    lista.sort((a, b) => b.venda.id.compareTo(a.venda.id));
    return lista;
  }

  void _detalhe(BuildContext context, _VendaView v) {
    final x = v.venda;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Venda #${x.id}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinhaInfo('Cliente', v.cliente),
              LinhaInfo('Vendedor', v.vendedor),
              LinhaInfo('Data', dataHoraBr(x.data)),
              LinhaInfo('Status', x.status.label),
              if (x.descricao != null && x.descricao!.isNotEmpty) LinhaInfo('Descrição', x.descricao!),
              const Divider(),
              LinhaInfo('Valor total', moeda(x.valorTotal)),
              LinhaInfo('Desconto', moeda(x.valorDesconto)),
              LinhaInfo('Valor pago', moeda(x.valorLiquido), destaque: true),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListaPage<_VendaView>(
      carregar: _carregar,
      textoVazio: 'Nenhuma venda registrada.',
      rotuloFab: 'Nova venda',
      aoCriar: () => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PedidoFormPage(tipo: TipoPedido.venda)),
      ),
      dicaBusca: 'Buscar por cliente ou vendedor',
      filtroBusca: (v, q) =>
          v.cliente.toLowerCase().contains(q) || v.vendedor.toLowerCase().contains(q),
      itemBuilder: (context, v, recarregar) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.point_of_sale)),
          title: Text('Venda #${v.venda.id} · ${v.cliente}', overflow: TextOverflow.ellipsis),
          subtitle: Text('Vendedor: ${v.vendedor}\n${dataHoraBr(v.venda.data)}'),
          isThreeLine: true,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(moeda(v.venda.valorLiquido),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Etiqueta(v.venda.status.label, cor: corStatusFinanceiro(v.venda.status)),
            ],
          ),
          onTap: () => _detalhe(context, v),
        ),
      ),
    );
  }
}
