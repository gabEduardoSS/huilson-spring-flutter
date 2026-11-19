import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatters.dart';
import '../core/json_utils.dart';
import '../core/validators.dart';
import '../services/servicos.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'campos.dart';
import 'feedback.dart';

const ufs = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
  'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
];

/// Estado dos campos comuns a Cliente e Funcionário.
/// O back-end exige "cidade, UF" e "rua, número" num único texto; aqui são campos separados.
class PessoaCamposController {
  PessoaCamposController({
    String? nome,
    String? cpf,
    String? email,
    String? telefone,
    String? cidade,
    String? endereco,
    this.dtNasc,
  })  : nome = TextEditingController(text: nome),
        cpf = TextEditingController(text: cpf),
        email = TextEditingController(text: email),
        telefone = TextEditingController(text: telefone),
        cidade = TextEditingController(text: cidade == null ? '' : separarUltimaVirgula(cidade).$1),
        rua = TextEditingController(text: endereco == null ? '' : separarUltimaVirgula(endereco).$1),
        numero = TextEditingController(text: endereco == null ? '' : separarUltimaVirgula(endereco).$2),
        uf = cidade == null ? null : separarUltimaVirgula(cidade).$2.toUpperCase() {
    if (!ufs.contains(uf)) uf = null;
  }

  final TextEditingController nome, cpf, email, telefone, cidade, rua, numero;
  final TextEditingController cep = TextEditingController();
  final FocusNode numeroFoco = FocusNode();

  String? uf;
  DateTime? dtNasc;

  Map<String, dynamic> toJson() => {
        'nome': nome.text.trim(),
        'cpf': soDigitos(cpf.text),
        'email': email.text.trim(),
        'telefone': soDigitos(telefone.text),
        'cidade': '${cidade.text.trim()}, $uf',
        'endereco': '${rua.text.trim()}, ${numero.text.trim()}',
        if (dtNasc != null) 'dtNasc': dataIso(dtNasc!),
      };

  void dispose() {
    for (final c in [nome, cpf, email, telefone, cidade, rua, numero, cep]) {
      c.dispose();
    }
    numeroFoco.dispose();
  }
}

class PessoaCampos extends StatefulWidget {
  const PessoaCampos({super.key, required this.controller, this.dtNascObrigatoria = false, this.comCep = true});

  final PessoaCamposController controller;
  final bool dtNascObrigatoria;
  final bool comCep;

  @override
  State<PessoaCampos> createState() => _PessoaCamposState();
}

class _PessoaCamposState extends State<PessoaCampos> {
  PessoaCamposController get c => widget.controller;

  bool _buscando = false;

  static const _gap = SizedBox(height: 16);
  static const _gapH = SizedBox(width: 12);

  String? _validaCep(String? v) {
    final d = soDigitos(v ?? '');
    if (d.isEmpty) return null; // o CEP é opcional: serve só de atalho para preencher o endereço
    return d.length == 8 ? null : 'CEP deve ter 8 dígitos';
  }

  Future<void> _buscarCep() async {
    FocusScope.of(context).unfocus();

    if (soDigitos(c.cep.text).length != 8) {
      mostrarErro(context, 'Informe um CEP com 8 dígitos para validar.');
      return;
    }

    setState(() => _buscando = true);
    try {
      final e = await servicos.cep.consultar(c.cep.text);
      if (!mounted) return;

      final uf = e.uf.toUpperCase();
      setState(() {
        c.uf = ufs.contains(uf) ? uf : null;
        c.cidade.text = e.cidade;
        // CEPs "únicos" de cidades pequenas vêm sem logradouro: nesse caso mantém o que já estava.
        if (e.logradouro.isNotEmpty) c.rua.text = e.logradouro;

        // DDD no telefone, sem sobrescrever um número que o usuário já tenha digitado.
        final antes = c.telefone.text;
        final depois = telefoneComDdd(antes, e.ddd);
        if (depois != antes) {
          c.telefone.text = depois;
          c.telefone.selection = TextSelection.collapsed(offset: depois.length);
        }
      });

      // O ViaCEP também devolve o bairro, mas o back-end não tem onde gravá-lo: só informamos.
      final local = [if (e.bairro.isNotEmpty) e.bairro, '${e.cidade}/${e.uf}'].join(' · ');
      mostrarSucesso(context, 'CEP encontrado: $local. Agora informe o número.');
      c.numeroFoco.requestFocus();
    } catch (err) {
      if (mounted) mostrarErro(context, err);
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Widget _campoCep() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: c.cep,
            decoration: const InputDecoration(
              labelText: 'CEP (opcional)',
              hintText: 'Somente números',
              helperText: 'Preenche cidade, UF, rua e DDD. Não é gravado.',
              helperMaxLines: 2,
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            validator: _validaCep,
            onFieldSubmitted: (_) => _buscarCep(),
          ),
        ),
        _gapH,
        SizedBox(
          height: 56, // mesma altura do campo
          child: FilledButton.tonalIcon(
            onPressed: _buscando ? null : _buscarCep,
            icon: _buscando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: const Text('Validar CEP'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: c.nome,
          decoration: const InputDecoration(labelText: 'Nome completo'),
          textCapitalization: TextCapitalization.words,
          validator: (v) => obrigatorio(v, 'Nome é obrigatório'),
        ),
        _gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: c.cpf,
                decoration: const InputDecoration(labelText: 'CPF', hintText: 'Somente números'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
                validator: validaCpf,
              ),
            ),
            _gapH,
            Expanded(
              child: TextFormField(
                controller: c.telefone,
                decoration: const InputDecoration(labelText: 'Telefone', hintText: 'DDD + número'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: validaTelefone,
              ),
            ),
          ],
        ),
        _gap,
        TextFormField(
          controller: c.email,
          decoration: const InputDecoration(labelText: 'E-mail'),
          keyboardType: TextInputType.emailAddress,
          validator: validaEmail,
        ),
        _gap,
        if (widget.comCep) ...[_campoCep(), _gap],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: c.cidade,
                decoration: const InputDecoration(labelText: 'Cidade'),
                textCapitalization: TextCapitalization.words,
                validator: validaCidade,
              ),
            ),
            _gapH,
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: c.uf,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'UF'),
                items: [for (final u in ufs) DropdownMenuItem(value: u, child: Text(u))],
                onChanged: (v) => setState(() => c.uf = v),
                validator: (v) => v == null ? 'UF' : null,
              ),
            ),
          ],
        ),
        _gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: c.rua,
                decoration: const InputDecoration(labelText: 'Rua / logradouro'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => obrigatorio(v, 'Informe a rua'),
              ),
            ),
            _gapH,
            Expanded(
              child: TextFormField(
                controller: c.numero,
                decoration: const InputDecoration(labelText: 'Número'),
                validator: validaNumeroEndereco,
              ),
            ),
          ],
        ),
        _gap,
        CampoData(
          rotulo: widget.dtNascObrigatoria ? 'Data de nascimento' : 'Data de nascimento (opcional)',
          inicial: c.dtNasc,
          obrigatorio: widget.dtNascObrigatoria,
          aoMudar: (d) => c.dtNasc = d,
        ),
      ],
    );
  }
}