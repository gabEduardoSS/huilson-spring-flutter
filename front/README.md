# Gestão Comercial – front-end Flutter

Front-end (Web, Android, Windows...) do back-end Spring Boot `demo` (caixas d'água).
Estilo: Material 3 padrão, `NavigationRail` à esquerda, título **"Gestão Comercial • Seção"**,
FAB estendido ("Novo cliente"), estado vazio com ícone de caixa de entrada e faixa vermelha de erro.

## Como rodar
```bash
# 1) dentro desta pasta, gere as pastas de plataforma (web/, android/, ...) sem sobrescrever o lib/
flutter create . --platforms=web,android,windows --project-name gestao_comercial
flutter pub get

# 2) suba o back-end (porta 8080) e rode o app
flutter run -d chrome
```
URL da API (padrão `http://localhost:8080/api`; `10.0.2.2` no emulador Android):
```bash
flutter run -d chrome --dart-define=API_URL=http://192.168.0.10:8080/api
```
> "ClientException: Failed to fetch" = o app não alcançou o servidor (back-end parado ou URL errada).
> O CORS do back-end já libera `/api/**`.

## Telas x endpoints
| Tela | Endpoints |
|---|---|
| Login / primeiro acesso | `POST /auth/login`, `POST /auth/registro` |
| Clientes | `GET/POST /clientes`, `PATCH /clientes/{id}` |
| Funcionários | `GET /funcionarios?status&cargo`, `POST`, `PATCH`, `POST /{id}/desativar`, `/reativar` |
| Produtos | `GET /produtos?status`, `POST`, `PATCH`, `POST /{id}/desativar`, `/reativar`, `DELETE /{id}` |
| Vendas | `GET /vendas`, `POST /vendas/criar` |
| Compras | `POST /compras` (+ histórico via `GET /consultas/transacoes?tipo=SAIDA`) |
| Caixa | `GET /caixa/saldo`, `GET /consultas/transacoes`, `GET /consultas/movimentacoes` |

## Estrutura
```
lib/
  core/      config, ApiClient (ProblemDetail -> ApiException), formatadores, validadores (= Padroes.kt)
  models/    enums (nomes idênticos aos do Kotlin) e modelos
  services/  um serviço por controller + `servicos` (instância única)
  widgets/   ListaPage genérica, campos, formulário padrão, feedback
  screens/   login, shell de navegação e uma página (+ formulário) por módulo
test/        testes de modelos, validadores e ApiClient (respostas no formato do back-end)
```
