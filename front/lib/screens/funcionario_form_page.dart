import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatters.dart';
import '../core/validators.dart';
import '../models/enums.dart';
import '../models/funcionario.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/feedback.dart';
import '../widgets/pessoa_campos.dart';

class FuncionarioFormPage extends StatefulWidget {
  const FuncionarioFormPage({super.key, this.funcionario});

  final Funcionario? funcionario;

  @override
  State<FuncionarioFormPage> createState() => _FuncionarioFormPageState();
}

class _FuncionarioFormPageState extends State<FuncionarioFormPage> {
  final _key = GlobalKey<FormState>();
  late final PessoaCamposController _pessoa;
  late final TextEditingController _salario;
  Turno? _turno;
  Cargo? _cargo;
  bool _salvando = false;

  bool get _edicao => widget.funcionario != null;

  @override
  void initState() {
    super.initState();
    final f = widget.funcionario;
    _pessoa = PessoaCamposController(
      nome: f?.nome,
      cpf: f?.cpf,
      email: f?.email,
      telefone: f?.telefone,
      cidade: f?.cidade,
      endereco: f?.endereco,
      dtNasc: f?.dtNasc,
    );
    _salario = TextEditingController(text: f == null ? '' : numeroBr(f.salario));
    _turno = f?.turno;
    _cargo = f?.cargo;
  }

  @override
  void dispose() {
    _pessoa.dispose();
    _salario.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final dados = _pessoa.toJson()
        ..['salario'] = parseDecimal(_salario.text)
        ..['turno'] = _turno!.name
        ..['cargo'] = _cargo!.name;
      if (_edicao) {
        await servicos.funcionarios.alterar(widget.funcionario!.id, dados);
      } else {
        await servicos.funcionarios.cadastrar(dados);
      }
      if (!mounted) return;
      mostrarSucesso(context, _edicao ? 'Funcionário atualizado.' : 'Funcionário cadastrado.');
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
      titulo: _edicao ? 'Editar funcionário' : 'Novo funcionário',
      formKey: _key,
      salvando: _salvando,
      aoSalvar: _salvar,
      rotuloSalvar: _edicao ? 'Salvar alterações' : 'Cadastrar funcionário',
      children: [
        PessoaCampos(controller: _pessoa, dtNascObrigatoria: true),
        const SecaoTitulo('Contrato'),
        TextFormField(
          controller: _salario,
          decoration: const InputDecoration(labelText: 'Salário', prefixText: 'R\$ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          validator: (v) => validaPositivo(v, 'Salário'),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownEnum<Cargo>(
                rotulo: 'Cargo',
                valores: Cargo.values,
                valor: _cargo,
                rotuloDe: (c) => c.label,
                aoMudar: (v) => setState(() => _cargo = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownEnum<Turno>(
                rotulo: 'Turno',
                valores: Turno.values,
                valor: _turno,
                rotuloDe: (t) => t.label,
                aoMudar: (v) => setState(() => _turno = v),
              ),
            ),
          ],
        ),
        if (_edicao)
          Text(
            'Para ativar ou desativar o funcionário, use o menu ⋮ na lista.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
