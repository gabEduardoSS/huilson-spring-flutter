package Projeto.de.teste.Back.demo.web.dto

import Projeto.de.teste.Back.demo.domain.enums.TipoPessoa
import Projeto.de.teste.Back.demo.domain.model.Cliente
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.PastOrPresent
import jakarta.validation.constraints.Pattern
import java.time.LocalDate
import java.time.LocalDateTime

data class ClienteRequest(
    @field:NotBlank(message = "Nome é obrigatório") val nome: String?,
    @field:NotNull(message = "CPF é obrigatório")
    @field:Pattern(regexp = Padroes.CPF, message = "CPF inválido") val cpf: String?,
    @field:NotNull(message = "Email é obrigatório")
    @field:Pattern(regexp = Padroes.EMAIL, message = "Estrutura de email inválida") val email: String?,
    @field:NotNull(message = "Telefone é obrigatório")
    @field:Pattern(regexp = Padroes.TELEFONE, message = "Telefone inválido (use DDD + número, apenas dígitos)") val telefone: String?,
    @field:NotNull(message = "Cidade é obrigatória")
    @field:Pattern(regexp = Padroes.CIDADE_UF, message = "Use o formato 'cidade, UF'") val cidade: String?,
    @field:NotNull(message = "Endereço é obrigatório")
    @field:Pattern(regexp = Padroes.ENDERECO, message = "Use o formato 'rua, número'") val endereco: String?,
    @field:PastOrPresent(message = "Data de nascimento inválida") val dtNasc: LocalDate?,
)

/** Todos os campos são opcionais: o que vier nulo mantém o valor atual (equivale ao "deixe em branco" do terminal). */
data class ClienteUpdateRequest(
    val nome: String?,
    @field:Pattern(regexp = Padroes.CPF, message = "CPF inválido") val cpf: String?,
    @field:Pattern(regexp = Padroes.EMAIL, message = "Estrutura de email inválida") val email: String?,
    @field:Pattern(regexp = Padroes.TELEFONE, message = "Telefone inválido (use DDD + número, apenas dígitos)") val telefone: String?,
    @field:Pattern(regexp = Padroes.CIDADE_UF, message = "Use o formato 'cidade, UF'") val cidade: String?,
    @field:Pattern(regexp = Padroes.ENDERECO, message = "Use o formato 'rua, número'") val endereco: String?,
    @field:PastOrPresent(message = "Data de nascimento inválida") val dtNasc: LocalDate?,
    val dividasAbertas: Boolean?,
)

data class ClienteResponse(
    val id: Long,
    val tipo: TipoPessoa,
    val nome: String,
    val cpf: String,
    val email: String,
    val telefone: String,
    val cidade: String,
    val endereco: String,
    val dtNasc: LocalDate?,
    val dividasAbertas: Boolean,
    val dtCriacao: LocalDateTime,
)

fun Cliente.toResponse() = ClienteResponse(
    id = id!!, tipo = tipo, nome = nome, cpf = cpf, email = email, telefone = telefone,
    cidade = cidade, endereco = endereco, dtNasc = dtNasc, dividasAbertas = dividasAbertas, dtCriacao = dtCriacao,
)
