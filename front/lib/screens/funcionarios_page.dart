import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/enums.dart';
import '../models/funcionario.dart';
import '../services/servicos.dart';
import '../widgets/campos.dart';
import '../widgets/feedback.dart';
import '../widgets/lista_page.dart';
import '../widgets/visual.dart';
import 'funcionario_form_page.dart';

class FuncionariosPage extends StatefulWidget {
  const FuncionariosPage({super.key});

  @override
  State<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  StatusCadastro? _status;
  Cargo? _cargo;

  Future<void> _alternarStatus(Funcionario f, Future<void> Function() recarregar) async {
    final desativar = f.ativo;
    final ok = await confirmar(
      context,
      titulo: desativar ? 'Desativar funcionário?' : 'Reativar funcionário?',
      mensagem: '${f.nome} ${desativar ? 'ficará inativo.' : 'voltará a ficar ativo.'}',
      rotuloConfirmar: desativar ? 'Desativar' : 'Reativar',
      destrutivo: desativar,
    );
    if (!ok) return;
    try {
      if (desativar) {
        await servicos.funcionarios.desativar(f.id);
      } else {
        await servicos.funcionarios.reativar(f.id);
      }
      if (!mounted) return;
      mostrarSucesso(context, desativar ? 'Funcionário desativado.' : 'Funcionário reativado.');
      await recarregar();
    } catch (e) {
      if (mounted) mostrarErro(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListaPage<Funcionario>(
      key: ValueKey('$_status-$_cargo'),
      carregar: () => servicos.funcionarios.listar(status: _status, cargo: _cargo),
      textoVazio: 'Nenhum funcionário cadastrado.',
      rotuloFab: 'Novo funcionário',
      aoCriar: () => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const FuncionarioFormPage()),
      ),
      dicaBusca: 'Buscar por nome, CPF ou e-mail',
      filtroBusca: (f, q) =>
          f.nome.toLowerCase().contains(q) ||
          f.cpf.contains(q) ||
          f.email.toLowerCase().contains(q),
      topo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipsFiltro<StatusCadastro>(
            opcoes: const [
              (null, 'Todos'),
              (StatusCadastro.ATIVO, 'Ativos'),
              (StatusCadastro.DESATIVADO, 'Desativados'),
            ],
            valor: _status,
            aoMudar: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 4),
          ChipsFiltro<Cargo>(
            opcoes: [(null, 'Todos os cargos'), for (final c in Cargo.values) (c, c.label)],
            valor: _cargo,
            aoMudar: (v) => setState(() => _cargo = v),
          ),
        ],
      ),
      itemBuilder: (context, f, recarregar) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Text(inicial(f.nome))),
          title: Row(
            children: [
              Flexible(child: Text(f.nome, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Etiqueta(f.status.label, cor: corStatusCadastro(f.status)),
            ],
          ),
          subtitle: Text(
            '${f.cargo.label} · ${f.turno.label} · ${moeda(f.salario)}\n'
            '${fmtTelefone(f.telefone)} · ${f.email}',
          ),
          isThreeLine: true,
          onTap: () async {
            final salvou = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => FuncionarioFormPage(funcionario: f)),
            );
            if (salvou == true) recarregar();
          },
          trailing: PopupMenuButton<String>(
            onSelected: (acao) async {
              if (acao == 'editar') {
                final salvou = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => FuncionarioFormPage(funcionario: f)),
                );
                if (salvou == true) recarregar();
              } else {
                await _alternarStatus(f, recarregar);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(value: 'status', child: Text(f.ativo ? 'Desativar' : 'Reativar')),
            ],
          ),
        ),
      ),
    );
  }
}
