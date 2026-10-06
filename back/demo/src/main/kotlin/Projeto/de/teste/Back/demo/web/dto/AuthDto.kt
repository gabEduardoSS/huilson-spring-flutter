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
