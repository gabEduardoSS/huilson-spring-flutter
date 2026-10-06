package Projeto.de.teste.Back.demo.exception

/** 404 – o recurso pedido não existe. */
class NaoEncontradoException(mensagem: String) : RuntimeException(mensagem)

/** 400 – dado enviado pelo front viola uma regra de formato/validação. */
class RequisicaoInvalidaException(mensagem: String) : RuntimeException(mensagem)

/** 409 – a operação conflita com o estado atual (ex.: usuário já existe, item já desativado). */
class ConflitoException(mensagem: String) : RuntimeException(mensagem)

/** 401 – usuário/senha não conferem. */
class CredenciaisInvalidasException(mensagem: String = "Usuário ou senha inválidos.") : RuntimeException(mensagem)

/** 422 – a requisição é válida, mas fere uma regra de negócio. */
open class RegraDeNegocioException(mensagem: String) : RuntimeException(mensagem)

class SaldoInsuficienteException(mensagem: String) : RegraDeNegocioException(mensagem)

class EstoqueInsuficienteException(mensagem: String) : RegraDeNegocioException(mensagem)
