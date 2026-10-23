import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/consulta.dart';
import '../models/enums.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/lista_page.dart';
import '../widgets/visual.dart';

/// Saldo do caixa + extrato (transações) + movimentações de estoque.
class CaixaPage extends StatefulWidget {
  const CaixaPage({super.key});

  @override
  State<CaixaPage> createState() => _CaixaPageState();
}

class _CaixaPageState extends State<CaixaPage> {
  late Future<double> _saldo = servicos.financeiro.saldo();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: cs.primaryContainer,
                  child: ListTile(
                    leading: Icon(Icons.account_balance_wallet_outlined, color: cs.onPrimaryContainer),
                    title: Text('Saldo do caixa', style: TextStyle(color: cs.onPrimaryContainer)),
                    subtitle: FutureBuilder<double>(
                      future: _saldo,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: SizedBox(width: 120, child: LinearProgressIndicator()),
                          );
                        }
                        if (snap.hasError) {
                          return Text('${snap.error}', style: TextStyle(color: cs.error));
                        }
                        return Text(
                          moeda(snap.data ?? 0),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                        );
                      },
                    ),
                    trailing: IconButton(
                      tooltip: 'Atualizar saldo',
                      icon: Icon(Icons.refresh, color: cs.onPrimaryContainer),
                      onPressed: () => setState(() => _saldo = servicos.financeiro.saldo()),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Transações'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Movimentações de estoque'),
            ],
          ),
          const Expanded(
            child: TabBarView(children: [_TransacoesTab(), _MovimentacoesTab()]),
          ),
        ],
      ),
    );
  }
}

class _TransacoesTab extends StatefulWidget {
  const _TransacoesTab();

  @override
  State<_TransacoesTab> createState() => _TransacoesTabState();
}

class _TransacoesTabState extends State<_TransacoesTab> {
  TipoTransacao? _tipo;

  @override
  Widget build(BuildContext context) {
    return ListaPage<Transacao>(
      key: ValueKey(_tipo),
      carregar: () => servicos.financeiro.transacoes(tipo: _tipo, detalhado: true),
      textoVazio: 'Nenhuma transação encontrada.',
      topo: ChipsFiltro<TipoTransacao>(
        opcoes: const [
          (null, 'Todas'),
          (TipoTransacao.ENTRADA, 'Entradas'),
          (TipoTransacao.SAIDA, 'Saídas'),
        ],
        valor: _tipo,
        aoMudar: (v) => setState(() => _tipo = v),
      ),
      itemBuilder: (context, t, recarregar) {
        final entrada = t.tipo == TipoTransacao.ENTRADA;
        final cor = entrada ? Colors.green.shade700 : Colors.red.shade700;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: cor.withOpacity(0.12),
              foregroundColor: cor,
              child: Icon(entrada ? Icons.arrow_downward : Icons.arrow_upward),
            ),
            title: Text(
              '${t.tipo.label} · ${moeda(t.valor)}',
              style: TextStyle(color: cor, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${t.pessoa == null ? 'Pessoa #${t.pessoaId}' : '${t.pessoa!.tipo.label}: ${t.pessoa!.nome}'}'
              ' · ${dataHoraBr(t.data)}\n'
              'Saldo: ${moeda(t.saldoAnterior)} → ${moeda(t.saldoPosterior)}',
            ),
            isThreeLine: true,
            trailing: Etiqueta(t.status.label, cor: corStatusFinanceiro(t.status)),
          ),
        );
      },
    );
  }
}

class _MovimentacoesTab extends StatefulWidget {
  const _MovimentacoesTab();

  @override
  State<_MovimentacoesTab> createState() => _MovimentacoesTabState();
}

class _MovimentacoesTabState extends State<_MovimentacoesTab> {
  TipoMovimentacao? _tipo;

  @override
  Widget build(BuildContext context) {
    return ListaPage<Movimentacao>(
      key: ValueKey(_tipo),
      carregar: () => servicos.financeiro.movimentacoes(tipo: _tipo, detalhado: true),
      textoVazio: 'Nenhuma movimentação de estoque.',
      topo: ChipsFiltro<TipoMovimentacao>(
        opcoes: const [
          (null, 'Todas'),
          (TipoMovimentacao.ENTRADA, 'Entradas'),
          (TipoMovimentacao.SAIDA, 'Saídas'),
        ],
        valor: _tipo,
        aoMudar: (v) => setState(() => _tipo = v),
      ),
      itemBuilder: (context, m, recarregar) {
        final entrada = m.tipo == TipoMovimentacao.ENTRADA;
        final cor = entrada ? Colors.green.shade700 : Colors.red.shade700;
        final p = m.produto;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: p != null
                ? AvatarProduto(cor: p.cor, formato: p.formato)
                : CircleAvatar(child: Text('#${m.produtoId}')),
            title: Text(
              '${entrada ? '+' : '-'}${m.quantidade} · ${p?.nome ?? 'Produto #${m.produtoId}'}',
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${m.tipo.label} · ${dataHoraBr(m.data)}\n'
              'Estoque: ${m.quantidadeAnterior} → ${m.quantidadePosterior}',
            ),
            isThreeLine: true,
            trailing: Etiqueta(m.tipo.label, cor: cor),
          ),
        );
      },
    );
  }
}
