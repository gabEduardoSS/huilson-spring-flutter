import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/cliente.dart';
import '../services/servicos.dart';
import '../widgets/lista_page.dart';
import '../widgets/visual.dart';
import 'cliente_form_page.dart';

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListaPage<Cliente>(
      carregar: servicos.clientes.listar,
      textoVazio: 'Nenhum cliente cadastrado.',
      rotuloFab: 'Novo cliente',
      aoCriar: () => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const ClienteFormPage()),
      ),
      dicaBusca: 'Buscar por nome, CPF ou e-mail',
      filtroBusca: (c, q) =>
          c.nome.toLowerCase().contains(q) ||
          c.cpf.contains(q) ||
          c.email.toLowerCase().contains(q),
      itemBuilder: (context, c, recarregar) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Text(inicial(c.nome))),
          title: Row(
            children: [
              Flexible(child: Text(c.nome, overflow: TextOverflow.ellipsis)),
              if (c.dividasAbertas) ...[
                const SizedBox(width: 8),
                Etiqueta('Dívidas em aberto', cor: Colors.red.shade700),
              ],
            ],
          ),
          subtitle: Text(
            '${fmtCpf(c.cpf)} · ${fmtTelefone(c.telefone)}\n${c.email} · ${c.cidade}',
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.edit_outlined),
          onTap: () async {
            final salvou = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: c)),
            );
            if (salvou == true) recarregar();
          },
        ),
      ),
    );
  }
}
