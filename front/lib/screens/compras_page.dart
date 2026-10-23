import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/consulta.dart';
import '../models/enums.dart';
import '../services/servicos.dart';
import '../widgets/lista_page.dart';
import '../widgets/visual.dart';
import 'pedido_form_page.dart';

/// O back-end só expõe `POST /api/compras` (não há listagem de compras). Como toda compra gera uma
/// transação de SAÍDA no caixa, o histórico abaixo vem de `/api/consultas/transacoes?tipo=SAIDA`.
class ComprasPage extends StatelessWidget {
  const ComprasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListaPage<Transacao>(
      carregar: () => servicos.financeiro.transacoes(tipo: TipoTransacao.SAIDA, detalhado: true),
      textoVazio: 'Nenhuma compra registrada.',
      rotuloFab: 'Nova compra',
      aoCriar: () => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PedidoFormPage(tipo: TipoPedido.compra)),
      ),
      topo: Text(
        'Histórico das saídas do caixa (compras realizadas)',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      itemBuilder: (context, t, recarregar) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.shopping_cart_outlined)),
          title: Text('Compra · ${moeda(t.valor)}'),
          subtitle: Text(
            'Responsável: ${t.pessoa?.nome ?? '#${t.pessoaId}'} · ${dataHoraBr(t.data)}\n'
            'Caixa: ${moeda(t.saldoAnterior)} → ${moeda(t.saldoPosterior)}',
          ),
          isThreeLine: true,
          trailing: Etiqueta(t.status.label, cor: corStatusFinanceiro(t.status)),
        ),
      ),
    );
  }
}
