import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/enums.dart';
import '../models/produto.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/feedback.dart';
import '../widgets/lista_page.dart';
import '../widgets/visual.dart';
import 'produto_form_page.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  StatusCadastro? _status;

  Future<void> _alternarStatus(Produto p, Future<void> Function() recarregar) async {
    final desativar = p.ativo;
    final ok = await confirmar(
      context,
      titulo: desativar ? 'Desativar produto?' : 'Reativar produto?',
      mensagem: desativar
          ? '${p.nome} não poderá mais ser vendido (compras continuam permitidas).'
          : '${p.nome} voltará a ser vendido.',
      rotuloConfirmar: desativar ? 'Desativar' : 'Reativar',
      destrutivo: desativar,
    );
    if (!ok) return;
    try {
      if (desativar) {
        await servicos.produtos.desativar(p.id);
      } else {
        await servicos.produtos.reativar(p.id);
      }
      if (!mounted) return;
      mostrarSucesso(context, desativar ? 'Produto desativado.' : 'Produto reativado.');
      await recarregar();
    } catch (e) {
      if (mounted) mostrarErro(context, e);
    }
  }

  Future<void> _excluir(Produto p, Future<void> Function() recarregar) async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir produto?',
      mensagem: 'A exclusão de ${p.nome} é definitiva. '
          'Produtos com histórico de estoque não podem ser excluídos (desative-os).',
      rotuloConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!ok) return;
    try {
      await servicos.produtos.excluir(p.id);
      if (!mounted) return;
      mostrarSucesso(context, 'Produto excluído.');
      await recarregar();
    } catch (e) {
      if (mounted) mostrarErro(context, e);
    }
  }

  Future<void> _editar(Produto p, Future<void> Function() recarregar) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProdutoFormPage(produto: p)),
    );
    if (salvou == true) recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return ListaPage<Produto>(
      key: ValueKey(_status),
      carregar: () => servicos.produtos.listar(status: _status),
      textoVazio: 'Nenhum produto cadastrado.',
      rotuloFab: 'Novo produto',
      aoCriar: () => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const ProdutoFormPage()),
      ),
      dicaBusca: 'Buscar por marca, modelo ou fornecedor',
      filtroBusca: (p, q) =>
          p.marca.toLowerCase().contains(q) ||
          p.modelo.toLowerCase().contains(q) ||
          p.fornecedor.toLowerCase().contains(q),
      topo: ChipsFiltro<StatusCadastro>(
        opcoes: const [
          (null, 'Todos'),
          (StatusCadastro.ATIVO, 'Ativos'),
          (StatusCadastro.DESATIVADO, 'Desativados'),
        ],
        valor: _status,
        aoMudar: (v) => setState(() => _status = v),
      ),
      itemBuilder: (context, p, recarregar) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: AvatarProduto(cor: p.cor, formato: p.formato),
          title: Row(
            children: [
              Flexible(child: Text(p.nome, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Etiqueta(p.status.label, cor: corStatusCadastro(p.status)),
            ],
          ),
          subtitle: Text(
            '${p.material.label} · ${p.formato.label} · ${p.cor.label}\n'
            '${numeroBr(p.altura)} × ${numeroBr(p.largura)} × ${numeroBr(p.profundidade)} m · '
            '${moeda(p.preco)} · Estoque: ${p.quantidade}',
          ),
          isThreeLine: true,
          onTap: () => _editar(p, recarregar),
          trailing: PopupMenuButton<String>(
            onSelected: (acao) async {
              switch (acao) {
                case 'editar':
                  await _editar(p, recarregar);
                case 'status':
                  await _alternarStatus(p, recarregar);
                case 'excluir':
                  await _excluir(p, recarregar);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(value: 'status', child: Text(p.ativo ? 'Desativar' : 'Reativar')),
              const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
            ],
          ),
        ),
      ),
    );
  }
}
