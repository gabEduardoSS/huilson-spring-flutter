import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatters.dart';
import '../core/json_utils.dart';
import '../core/validators.dart';
import 'campos.dart';

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
    for (final c in [nome, cpf, email, telefone, cidade, rua, numero]) {
      c.dispose();
    }
  }
}

class PessoaCampos extends StatefulWidget {
  const PessoaCampos({super.key, required this.controller, this.dtNascObrigatoria = false});

  final PessoaCamposController controller;
  final bool dtNascObrigatoria;

  @override
  State<PessoaCampos> createState() => _PessoaCamposState();
}

class _PessoaCamposState extends State<PessoaCampos> {
  PessoaCamposController get c => widget.controller;

  static const _gap = SizedBox(height: 16);
  static const _gapH = SizedBox(width: 12);

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
                  LengthLimitingTextInputFormatter(11),
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
