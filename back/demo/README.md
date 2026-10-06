# Back-end Caixas d'Água — Spring Boot + Kotlin

API REST que substitui o sistema de terminal (projetos `aa` + `bb`) para ser consumida pelo front em Flutter.
Base: projeto `demo` (Spring Boot 4.1.1, Kotlin 2.3.21, Java 21, Maven, JPA/Hibernate, PostgreSQL).

## Como rodar

1. Tenha um PostgreSQL com o banco `projetocaixadeagua` (usuário/senha padrão `postgres`/`postgres`, os mesmos do `JPAConexao` antigo).
   Para outro ambiente, use as variáveis `DB_URL`, `DB_USER`, `DB_PASSWORD`.
2. `./mvnw spring-boot:run` (a API sobe em `http://localhost:8080`).
3. `./mvnw package -DskipTests` gera o jar. O `DemoApplicationTests` (`contextLoads`) precisa do banco no ar.

Na primeira execução o Hibernate cria as tabelas que faltarem (`ddl-auto=update`) e a aplicação cria o registro do caixa (id = 1)
com o saldo de `app.caixa.saldo-inicial` (padrão 0). Veja `src/main/resources/application.properties`.

## ⚠️ Banco de dados que já existia (leia antes de apontar para ele)

O projeto JDBC delegava parte das regras a **triggers do banco**: calcular `saldo_anterior/posterior`, conferir saldo,
dar baixa/entrada no estoque e marcar o status como `CONCLUIDA`. Esses scripts não estavam nos arquivos enviados.
Agora essas regras estão em código (`TransacaoService` e `MovimentacaoService`). **Se as triggers continuarem ativas, saldo e
estoque serão movimentados duas vezes.** Para conferir:

```sql
SELECT event_object_table AS tabela, trigger_name, action_timing, event_manipulation
FROM information_schema.triggers WHERE trigger_schema = 'public' ORDER BY 1, 2;
-- depois, para cada trigger de transacao/movimentacao:  DROP TRIGGER <nome> ON <tabela>;
```

Ou use um banco novo/vazio — nesse caso o Hibernate cria tudo. Colunas novas: `valor_desconto` em `venda`/`compra` e a tabela `usuario`.

## Mapa: sistema antigo → API

| Antes (terminal) | Agora | Endpoint |
|---|---|---|
| `Login.criaLogin()` (aa) | `AuthService.registrar` | `POST /api/auth/registro` |
| `Login.validaLogin()` (aa) | `AuthService.autenticar` | `POST /api/auth/login` |
| Cadastrar/Listar/Editar/Excluir caixa (aa) | `ProdutoService` | `POST/GET/PATCH/DELETE /api/produtos` |
| ClienteHandler | `ClienteService` | `GET/POST /api/clientes`, `GET/PATCH /api/clientes/{id}` |
| FuncionarioHandler | `FuncionarioService` | `GET/POST /api/funcionarios` (`?status=&cargo=`), `PATCH /{id}`, `POST /{id}/desativar`, `POST /{id}/reativar` |
| ProdutoHandler | `ProdutoService` | `GET /api/produtos` (`?status=`), `PATCH /{id}`, `POST /{id}/desativar`, `POST /{id}/reativar` |
| VendaHandler | `VendaService` | `POST /api/vendas` |
| CompraHandler | `CompraService` | `POST /api/compras` |
| CaixaHandler | `CaixaService` | `GET /api/caixa/saldo` |
| ConsultasHandler | `ConsultaService` | `GET /api/consultas/movimentacoes` e `/transacoes` (`?tipo=ENTRADA\|SAIDA&detalhado=true`) |
| Listas numeradas de cor/material/cargo/turno | — | `GET /api/opcoes` |

Enumerados (cor, material, formato, cargo, turno, tipo) agora são enviados **pelo nome** (`"AZUL_FORTE"`), não pelo número do menu.
Datas em ISO (`"1990-03-25"`). Valores em dinheiro vão como número; o `formatacaoDinheiro` ("R$ 1.234,56") fica a cargo do Flutter.

### Exemplos

```http
POST /api/vendas
{ "vendedorId": 2, "clienteId": 1, "descricao": "balcão", "valorDesconto": 50,
  "itens": [ { "produtoId": 1, "quantidade": 3 } ] }
```
```http
PATCH /api/clientes/1        # só os campos enviados são alterados
{ "telefone": "44999998888" }
```

### Erros

Sempre JSON (RFC 7807): `{ "status": 422, "title": "...", "detail": "Estoque insuficiente ...", "erros": { "campo": "mensagem" } }`
(`erros` só aparece em validação). Códigos: `400` dados inválidos · `401` login inválido · `404` não encontrado ·
`409` conflito (usuário já existe, já desativado, produto com histórico não pode ser excluído) · `422` regra de negócio (saldo/estoque insuficiente, cargo sem permissão).

## Estrutura

```
domain/enums   enumeradores            repository/  Spring Data JPA (substitui as classes JPA* com JDBC)
domain/model   entidades JPA           service/     regras de negócio (substitui service + parte dos handlers)
web/           controllers REST        web/dto/     DTOs de entrada/saída + validações (substitui LocalUtils)
exception/     erros → HTTP            config/      BCrypt, CORS, criação do caixa
```

## Regras preservadas e decisões tomadas

- **Venda/compra continuam atômicas**: uma transação só; falta de saldo ou de estoque desfaz tudo (era o `rollback()` do JDBC).
  Produtos e caixa são travados (`PESSIMISTIC_WRITE`) para duas operações simultâneas não venderem o mesmo estoque nem gastarem o mesmo saldo.
- Só funcionário `ATENDIMENTO` vende e só `FINANCEIRO` compra; venda só aceita produto `ativo`; compra aceita qualquer produto (como antes).
- Validações de formato do `LocalUtils` mantidas: CPF 11 dígitos, e-mail, `"cidade, UF"`, `"rua, número"`, nascimento não futuro.
- Login (projeto aa): usuário em MAIÚSCULAS, ≥ 5 caracteres, sem espaços, único; senha ≥ 5 caracteres e **não** vai para maiúsculas.

**Pontos em que me afastei do original (confirme se concorda):**

1. **Senha com hash BCrypt** em vez de texto puro. Login inválido devolve sempre a mesma mensagem (não diz se foi usuário ou senha), para não revelar quais usuários existem.
2. **Telefone aceita 10 ou 11 dígitos.** O original validava telefone com o regex de CPF, o que rejeitava fixos.
3. **Editar cliente não zera mais `dividas_abertas`** (o código antigo gravava `false` a cada edição); o campo só muda se enviado.
4. **Desconto**: `valorDesconto` existia no modelo mas nunca era gravado nem pedido. Agora é opcional, validado (≥ 0 e ≤ total) e persistido.
5. **Excluir produto** (aa) só funciona se o produto nunca teve movimentação; senão responde 409 e sugere desativar.
6. Dimensões viraram `altura`, `largura`, `profundidade` na API (no banco continua o array `[altura, largura, profundidade]` do bb; o aa usava outra ordem).
7. Status "ativo/desativado" virou enum (`ATIVO`/`DESATIVADO`); no banco continua gravado como `ativo`/`desativado`.
8. Removidos por serem exclusivos de terminal: `Menu`, `OpcoesMenu`, todos os `*Handler`, `valores()` (impressões), `formatacaoDinheiro`, `teste.kt`.

## Pendências / próximos passos

- **Autenticação das rotas**: o login só confere credenciais; **as demais rotas estão abertas**. Falta emitir um token (JWT) e proteger `/api/**` com Spring Security.
- Não há listagem/consulta de vendas e compras já feitas (o original também não tinha); fácil de acrescentar.
- O projeto `aa` referenciava uma classe `repositorio.JDBC` que não veio nos arquivos; a tabela `usuario` foi desenhada do zero. Se já houver usuários cadastrados no banco do aa, será preciso migrá-los (as senhas antigas precisam passar por BCrypt).
- Para produção: trocar `ddl-auto=update` por migrações versionadas (Flyway/Liquibase) e restringir `app.cors.allowed-origins`.
