import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/feedback.dart';
import '../widgets/pessoa_campos.dart';

class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _key = GlobalKey<FormState>();
  late final PessoaCamposController _pessoa;
  late bool _dividas;
  bool _salvando = false;

  bool get _edicao => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _pessoa = PessoaCamposController(
      nome: c?.nome,
      cpf: c?.cpf,
      email: c?.email,
      telefone: c?.telefone,
      cidade: c?.cidade,
      endereco: c?.endereco,
      dtNasc: c?.dtNasc,
    );
    _dividas = c?.dividasAbertas ?? false;
  }

  @override
  void dispose() {
    _pessoa.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final dados = _pessoa.toJson();
      if (_edicao) {
        dados['dividasAbertas'] = _dividas;
        await servicos.clientes.alterar(widget.cliente!.id, dados);
      } else {
        await servicos.clientes.cadastrar(dados);
      }
      if (!mounted) return;
      mostrarSucesso(context, _edicao ? 'Cliente atualizado.' : 'Cliente cadastrado.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarErro(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormularioPage(
      titulo: _edicao ? 'Editar cliente' : 'Novo cliente',
      formKey: _key,
      salvando: _salvando,
      aoSalvar: _salvar,
      rotuloSalvar: _edicao ? 'Salvar alterações' : 'Cadastrar cliente',
      children: [
        PessoaCampos(controller: _pessoa),
        if (_edicao)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dívidas em aberto'),
            value: _dividas,
            onChanged: (v) => setState(() => _dividas = v),
          ),
      ],
    );
  }
}
