import 'package:flutter/material.dart';

import 'feedback.dart';

/// Estado vazio igual ao da imagem de referência: ícone de caixa de entrada + texto.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({super.key, required this.texto, this.icone = Icons.inbox_outlined});

  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64),
            const SizedBox(height: 12),
            Text(texto),
          ],
        ),
      );
}

class EstadoErro extends StatelessWidget {
  const EstadoErro({super.key, required this.mensagem, required this.aoTentar});

  final String mensagem;
  final VoidCallback aoTentar;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 56, color: Theme.of(context).hintColor),
              const SizedBox(height: 12),
              Text(mensagem, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: aoTentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
              ),
            ],
          ),
        ),
      );
}

/// Página de listagem padrão: carrega, mostra carregando / erro / vazio / lista,
/// puxar-para-atualizar, busca local opcional e FAB estendido (ex.: "Novo cliente").
///
/// Para mudar filtros que vão ao servidor, o pai troca a `key` do widget (recarrega do zero).
class ListaPage<T> extends StatefulWidget {
  const ListaPage({
    super.key,
    required this.carregar,
    required this.itemBuilder,
    required this.textoVazio,
    this.rotuloFab,
    this.aoCriar,
    this.filtroBusca,
    this.dicaBusca = 'Buscar',
    this.topo,
    this.icone = Icons.inbox_outlined,
  });

  final Future<List<T>> Function() carregar;
  final Widget Function(BuildContext context, T item, Future<void> Function() recarregar)
      itemBuilder;
  final String textoVazio;
  final String? rotuloFab;

  /// Abre a tela de cadastro; devolva `true` se algo foi salvo para recarregar a lista.
  final Future<bool?> Function()? aoCriar;
  final bool Function(T item, String buscaMinuscula)? filtroBusca;
  final String dicaBusca;
  final Widget? topo;
  final IconData icone;

  @override
  State<ListaPage<T>> createState() => _ListaPageState<T>();
}

class _ListaPageState<T> extends State<ListaPage<T>> {
  List<T> _itens = <T>[];
  bool _carregando = true;
  Object? _erro;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    if (!mounted) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final r = await widget.carregar();
      if (!mounted) return;
      setState(() {
        _itens = r;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e;
        _carregando = false;
      });
      mostrarErro(context, e);
    }
  }

  Future<void> _criar() async {
    final salvou = await widget.aoCriar?.call();
    if (salvou == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final filtro = widget.filtroBusca;
    final itens = (filtro == null || _busca.isEmpty)
        ? _itens
        : _itens.where((i) => filtro(i, _busca.toLowerCase())).toList();

    return Stack(
      children: [
        Column(
          children: [
            if (widget.topo != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(alignment: Alignment.centerLeft, child: widget.topo),
              ),
            if (filtro != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: widget.dicaBusca,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _busca = v.trim()),
                ),
              ),
            Expanded(child: _corpo(itens)),
          ],
        ),
        if (widget.rotuloFab != null)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: _criar,
              icon: const Icon(Icons.add),
              label: Text(widget.rotuloFab!),
            ),
          ),
      ],
    );
  }

  Widget _corpo(List<T> itens) {
    if (_carregando && _itens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null && _itens.isEmpty) {
      return EstadoErro(mensagem: '$_erro', aoTentar: _carregar);
    }
    if (itens.isEmpty) {
      return EstadoVazio(
        texto: _busca.isEmpty ? widget.textoVazio : 'Nenhum resultado para a busca.',
        icone: widget.icone,
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: itens.length,
        itemBuilder: (context, i) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: widget.itemBuilder(context, itens[i], _carregar),
          ),
        ),
      ),
    );
  }
}
