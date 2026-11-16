package Projeto.de.teste.Back.demo.web.dto

import jakarta.validation.constraints.NotNull

data class RegistroRequest(
    @field:NotNull(message = "Usuário é obrigatório") val usuario: String?,
    @field:NotNull(message = "Senha é obrigatória") val senha: String?,
)

data class LoginRequest(
    @field:NotNull(message = "Usuário é obrigatório") val usuario: String?,
    @field:NotNull(message = "Senha é obrigatória") val senha: String?,
)

data class UsuarioResponse(val id: Long, val usuario: String)

/**
 * Resposta do `POST /api/auth/login`. Mantém `id` e `usuario` no nível de cima (como era antes,
 * o `Usuario.fromJson` do Flutter continua funcionando) e acrescenta o token.
 *  - token    : o Flutter manda em `Authorization: Bearer <token>` nas próximas chamadas.
 *  - expiraEm : quando o token vence, em epoch SEGUNDOS (depois disso, é preciso logar de novo).
 */
data class LoginResponse(val id: Long, val usuario: String, val token: String, val expiraEm: Long)
