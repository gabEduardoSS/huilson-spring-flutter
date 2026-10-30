import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatters.dart';
import '../core/validators.dart';
import '../models/enums.dart';
import '../models/produto.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/feedback.dart';
import '../widgets/visual.dart';

class ProdutoFormPage extends StatefulWidget {
  const ProdutoFormPage({super.key, this.produto});

  final Produto? produto;

  @override
  State<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ProdutoFormPageState extends State<ProdutoFormPage> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _marca, _modelo, _altura, _largura, _profundidade, _fornecedor, _preco;
  Cor? _cor;
  MaterialCaixa? _material;
  Formato? _formato;
  bool _salvando = false;

  bool get _edicao => widget.produto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    _marca = TextEditingController(text: p?.marca);
    _modelo = TextEditingController(text: p?.modelo);
    _altura = TextEditingController(text: p == null ? '' : numeroBr(p.altura));
    _largura = TextEditingController(text: p == null ? '' : numeroBr(p.largura));
    _profundidade = TextEditingController(text: p == null ? '' : numeroBr(p.profundidade));
    _fornecedor = TextEditingController(text: p?.fornecedor);
    _preco = TextEditingController(text: p == null ? '' : numeroBr(p.preco));
    _cor = p?.cor;
    _material = p?.material;
    _formato = p?.formato;
  }

  @override
  void dispose() {
    for (final c in [_marca, _modelo, _altura, _largura, _profundidade, _fornecedor, _preco]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _salvando = true);
    final dados = <String, dynamic>{
      'marca': _marca.text.trim(),
      'modelo': _modelo.text.trim(),
      'altura': parseDecimal(_altura.text),
      'largura': parseDecimal(_largura.text),
      'profundidade': parseDecimal(_profundidade.text),
      'cor': _cor!.name,
      'material': _material!.name,
      'formato': _formato!.name,
      'fornecedor': _fornecedor.text.trim(),
      'preco': parseDecimal(_preco.text),
    };
    try {
      if (_edicao) {
        await servicos.produtos.alterar(widget.produto!.id, dados);
      } else {
        await servicos.produtos.cadastrar(dados);
      }
      if (!mounted) return;
      mostrarSucesso(context, _edicao ? 'Produto atualizado.' : 'Produto cadastrado.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarErro(context, e);
    }
  }

  Widget _medida(TextEditingController c, String rotulo) => Expanded(
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(labelText: rotulo, suffixText: 'm'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          validator: (v) => validaPositivo(v, rotulo),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FormularioPage(
      titulo: _edicao ? 'Editar produto' : 'Novo produto',
      formKey: _key,
      salvando: _salvando,
      aoSalvar: _salvar,
      rotuloSalvar: _edicao ? 'Salvar alterações' : 'Cadastrar produto',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _marca,
                decoration: const InputDecoration(labelText: 'Marca'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => obrigatorio(v, 'Marca é obrigatória'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _modelo,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (v) => obrigatorio(v, 'Modelo é obrigatório'),
              ),
            ),
          ],
        ),
        const SecaoTitulo('Dimensões'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _medida(_altura, 'Altura'),
            const SizedBox(width: 12),
            _medida(_largura, 'Largura'),
            const SizedBox(width: 12),
            _medida(_profundidade, 'Profund.'),
          ],
        ),
        const SecaoTitulo('Características'),
        DropdownEnum<Cor>(
          rotulo: 'Cor',
          valores: Cor.values,
          valor: _cor,
          rotuloDe: (c) => c.label,
          iconeDe: (c) => Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: corDe(c),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26),
            ),
          ),
          aoMudar: (v) => setState(() => _cor = v),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownEnum<MaterialCaixa>(
                rotulo: 'Material',
                valores: MaterialCaixa.values,
                valor: _material,
                rotuloDe: (m) => m.label,
                aoMudar: (v) => setState(() => _material = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownEnum<Formato>(
                rotulo: 'Formato',
                valores: Formato.values,
                valor: _formato,
                rotuloDe: (f) => f.label,
                iconeDe: (f) => Icon(iconeFormato(f), size: 18),
                aoMudar: (v) => setState(() => _formato = v),
              ),
            ),
          ],
        ),
        const SecaoTitulo('Comercial'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _fornecedor,
                decoration: const InputDecoration(labelText: 'Fornecedor'),
                validator: (v) => obrigatorio(v, 'Fornecedor é obrigatório'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _preco,
                decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                validator: (v) => validaPositivo(v, 'Preço'),
              ),
            ),
          ],
        ),
        Text(
          'O estoque não é editado aqui: ele aumenta com as compras e diminui com as vendas.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
