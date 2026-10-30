import 'package:flutter/material.dart';

import '../core/formatters.dart';

/// Dropdown de enum (usa o `label` do enum e, opcionalmente, um ícone/bolinha).
class DropdownEnum<T extends Enum> extends StatelessWidget {
  const DropdownEnum({
    super.key,
    required this.rotulo,
    required this.valores,
    required this.valor,
    required this.aoMudar,
    required this.rotuloDe,
    this.iconeDe,
  });

  final String rotulo;
  final List<T> valores;
  final T? valor;
  final ValueChanged<T?> aoMudar;
  final String Function(T) rotuloDe;
  final Widget Function(T)? iconeDe;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: rotulo),
      items: [
        for (final v in valores)
          DropdownMenuItem<T>(
            value: v,
            child: Row(
              children: [
                if (iconeDe != null) ...[iconeDe!(v), const SizedBox(width: 8)],
                Flexible(child: Text(rotuloDe(v), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ],
      onChanged: aoMudar,
      validator: (v) => v == null ? 'Selecione uma opção' : null,
    );
  }
}

/// Filtro em "chips" (Todos / Ativos / Desativados ...). `null` = sem filtro.
class ChipsFiltro<T> extends StatelessWidget {
  const ChipsFiltro({super.key, required this.opcoes, required this.valor, required this.aoMudar});

  final List<(T?, String)> opcoes;
  final T? valor;
  final ValueChanged<T?> aoMudar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final o in opcoes)
          ChoiceChip(
            label: Text(o.$2),
            selected: o.$1 == valor,
            onSelected: (_) => aoMudar(o.$1),
          ),
      ],
    );
  }
}

/// Campo de data (dd/mm/aaaa) com seletor do Material.
class CampoData extends FormField<DateTime> {
  CampoData({
    super.key,
    required String rotulo,
    DateTime? inicial,
    bool obrigatorio = false,
    required ValueChanged<DateTime?> aoMudar,
  }) : super(
          initialValue: inicial,
          validator: (v) => obrigatorio && v == null ? 'Campo obrigatório' : null,
          builder: (state) {
            Future<void> escolher() async {
              final hoje = DateTime.now();
              final d = await showDatePicker(
                context: state.context,
                initialDate: state.value ?? DateTime(hoje.year - 30, hoje.month, hoje.day),
                firstDate: DateTime(1900),
                lastDate: hoje,
              );
              if (d != null) {
                state.didChange(d);
                aoMudar(d);
              }
            }

            return InkWell(
              onTap: escolher,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                isEmpty: state.value == null,
                decoration: InputDecoration(
                  labelText: rotulo,
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(state.value == null ? '' : dataBr(state.value)),
              ),
            );
          },
        );
}

/// Título de seção dentro de formulários.
class SecaoTitulo extends StatelessWidget {
  const SecaoTitulo(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
      );
}

/// Linha "rótulo ........ valor" usada em diálogos de detalhe.
class LinhaInfo extends StatelessWidget {
  const LinhaInfo(this.rotulo, this.valor, {super.key, this.destaque = false});
  final String rotulo, valor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final estilo = destaque
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(rotulo,
                style: estilo?.copyWith(color: destaque ? null : Theme.of(context).hintColor)),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(valor,
                textAlign: TextAlign.end,
                style: estilo?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Moldura padrão das telas de cadastro: AppBar + formulário centralizado + botão Salvar.
class FormularioPage extends StatelessWidget {
  const FormularioPage({
    super.key,
    required this.titulo,
    required this.formKey,
    required this.children,
    required this.aoSalvar,
    required this.salvando,
    this.rotuloSalvar = 'Salvar',
  });

  final String titulo;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback aoSalvar;
  final bool salvando;
  final String rotuloSalvar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final c in children) ...[c, const SizedBox(height: 16)],
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: salvando ? null : aoSalvar,
                  icon: salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(rotuloSalvar),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
