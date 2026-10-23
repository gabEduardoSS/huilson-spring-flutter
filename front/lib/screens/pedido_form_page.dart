import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatters.dart';
import '../core/validators.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/funcionario.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/feedback.dart';
import '../widgets/lista_page.dart';

enum TipoPedido { venda, compra }

class _ItemEdit {
  int? produtoId;
  final TextEditingController qtd = TextEditingController(text: '1');
}

/// Tela única para "Nova venda" (vendedor com cargo ATENDIMENTO + cliente, só produtos ATIVOS)
/// e "Nova compra" (responsável com cargo FINANCEIRO, aceita produtos desativados).
class PedidoFormPage extends StatefulWidget {
  const PedidoFormPage({super.key, required this.tipo});

  final TipoPedido tipo;

  @override
  State<PedidoFormPage> createState() => _PedidoFormPageState();
}

class _PedidoFormPageState extends State<PedidoFormPage> {
  final _key = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _desconto = TextEditingController();
  final List<_ItemEdit> _itens = [_ItemEdit()];

  bool _carregando = true;
  bool _enviando = false;
  Object? _erro;
  List<Funcionario> _funcionarios = const [];
  List<Cliente> _clientes = const [];
  List<Produto> _produtos = const [];
  int? _pessoaId;
  int? _clienteId;

  bool get _venda => widget.tipo == TipoPedido.venda;
  Cargo get _cargoExigido => _venda ? Cargo.ATENDIMENTO : Cargo.FINANCEIRO;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _descricao.dispose();
    _desconto.dispose();
    for (final i in _itens) {
      i.qtd.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final r = await Future.wait<Object>([
        servicos.funcionarios.listar(status: StatusCadastro.ATIVO, cargo: _cargoExigido),
        if (_venda) servicos.clientes.listar() else Future<List<Cliente>>.value(const []),
        servicos.produtos.listar(status: _venda ? StatusCadastro.ATIVO : null),
      ]);
      if (!mounted) return;
      setState(() {
        _funcionarios = r[0] as List<Funcionario>;
        _clientes = r[1] as List<Cliente>;
        _produtos = r[2] as List<Produto>;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e;
        _carregando = false;
      });
    }
  }

  Produto? _produto(int? id) => id == null ? null : _produtos.where((p) => p.id == id).firstOrNull;

  double get _subtotal {
    var t = 0.0;
    for (final i in _itens) {
      final p = _produto(i.produtoId);
      final q = int.tryParse(i.qtd.text.trim()) ?? 0;
      if (p != null) t += p.preco * q;
    }
    return t;
  }

  double get _descontoValor => parseDecimal(_desconto.text) ?? 0;

  Future<void> _enviar() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _enviando = true);

    final itens = [
      for (final i in _itens) {'produtoId': i.produtoId, 'quantidade': int.parse(i.qtd.text.trim())},
    ];
    final dados = <String, dynamic>{
      (_venda ? 'vendedorId' : 'requisitorId'): _pessoaId,
      if (_venda) 'clienteId': _clienteId,
      if (_descricao.text.trim().isNotEmpty) 'descricao': _descricao.text.trim(),
      if (_descontoValor > 0) 'valorDesconto': _descontoValor,
      'itens': itens,
    };

    try {
      if (_venda) {
        final v = await servicos.pedidos.criarVenda(dados);
        if (!mounted) return;
        await _mostrarResumo('Venda #${v.id} registrada', v.valorTotal, v.valorDesconto, v.itens ?? const []);
      } else {
        final c = await servicos.pedidos.criarCompra(dados);
        if (!mounted) return;
        await _mostrarResumo('Compra #${c.id} registrada', c.valorTotal, c.valorDesconto, c.itens);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      mostrarErro(context, e);
    }
  }

  Future<void> _mostrarResumo(String titulo, double total, double desconto, List<ItemPedido> itens) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final i in itens)
                LinhaInfo(
                  '${i.quantidade} × ${_produto(i.produtoId)?.nome ?? 'Produto #${i.produtoId}'}',
                  moeda(i.precoTotal),
                ),
              if (itens.isNotEmpty) const Divider(),
              LinhaInfo('Subtotal', moeda(total)),
              LinhaInfo('Desconto', moeda(desconto)),
              LinhaInfo('Total', moeda(total - desconto), destaque: true),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Widget _linhaItem(int i) {
    final item = _itens[i];
    return Padding(
      key: ObjectKey(item),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: item.produtoId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Produto'),
              items: [
                for (final p in _produtos)
                  DropdownMenuItem<int>(
                    value: p.id,
                    child: Text(
                      '${p.nome} · ${moeda(p.preco)} · estoque ${p.quantidade}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => item.produtoId = v),
              validator: (v) => v == null ? 'Selecione o produto' : null,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: TextFormField(
              controller: item.qtd,
              decoration: const InputDecoration(labelText: 'Qtd.'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final q = int.tryParse((v ?? '').trim());
                if (q == null || q <= 0) return 'Inválida';
                final p = _produto(item.produtoId);
                if (_venda && p != null && q > p.quantidade) return 'Estoque: ${p.quantidade}';
                return null;
              },
            ),
          ),
          IconButton(
            tooltip: 'Remover item',
            onPressed: _itens.length == 1 ? null : () => setState(() => _itens.removeAt(i)),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _venda ? 'Nova venda' : 'Nova compra';

    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_erro != null) {
      return Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: EstadoErro(mensagem: '$_erro', aoTentar: _carregarDados),
      );
    }

    final total = math.max(0.0, _subtotal - _descontoValor);
    final cs = Theme.of(context).colorScheme;

    return FormularioPage(
      titulo: titulo,
      formKey: _key,
      salvando: _enviando,
      aoSalvar: _enviar,
      rotuloSalvar: _venda ? 'Registrar venda' : 'Registrar compra',
      children: [
        if (_funcionarios.isEmpty)
          Card(
            color: cs.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Nenhum funcionário ATIVO com cargo ${_cargoExigido.label} encontrado. '
                'Cadastre um na aba Funcionários para poder ${_venda ? 'vender' : 'comprar'}.',
                style: TextStyle(color: cs.onErrorContainer),
              ),
            ),
          ),
        DropdownButtonFormField<int>(
          value: _pessoaId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _venda ? 'Vendedor (cargo Atendimento)' : 'Responsável (cargo Financeiro)',
          ),
          items: [
            for (final f in _funcionarios)
              DropdownMenuItem<int>(value: f.id, child: Text(f.nome, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _pessoaId = v),
          validator: (v) => v == null ? 'Selecione' : null,
        ),
        if (_venda)
          DropdownButtonFormField<int>(
            value: _clienteId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Cliente'),
            items: [
              for (final c in _clientes)
                DropdownMenuItem<int>(value: c.id, child: Text(c.nome, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => _clienteId = v),
            validator: (v) => v == null ? 'Selecione o cliente' : null,
          ),
        const SecaoTitulo('Itens'),
        if (_produtos.isEmpty)
          Text(
            _venda
                ? 'Nenhum produto ativo cadastrado.'
                : 'Nenhum produto cadastrado. Cadastre produtos antes de comprar.',
          ),
        Column(children: [for (var i = 0; i < _itens.length; i++) _linhaItem(i)]),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _produtos.isEmpty ? null : () => setState(() => _itens.add(_ItemEdit())),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar item'),
          ),
        ),
        TextFormField(
          controller: _desconto,
          decoration: const InputDecoration(labelText: 'Desconto (opcional)', prefixText: 'R\$ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          onChanged: (_) => setState(() {}),
          validator: (v) => _descontoValor > _subtotal ? 'O desconto não pode passar do subtotal' : null,
        ),
        TextFormField(
          controller: _descricao,
          decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
          maxLines: 2,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinhaInfo('Subtotal', moeda(_subtotal)),
                LinhaInfo('Desconto', '- ${moeda(_descontoValor)}'),
                const Divider(),
                LinhaInfo(_venda ? 'Total da venda' : 'Total da compra', moeda(total), destaque: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
