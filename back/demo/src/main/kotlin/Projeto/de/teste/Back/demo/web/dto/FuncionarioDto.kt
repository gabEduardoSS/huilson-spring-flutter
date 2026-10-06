package Projeto.de.teste.Back.demo.web.dto

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.enums.TipoPessoa
import Projeto.de.teste.Back.demo.domain.enums.Turno
import Projeto.de.teste.Back.demo.domain.model.Funcionario
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.PastOrPresent
import jakarta.validation.constraints.Pattern
import jakarta.validation.constraints.Positive
import java.math.BigDecimal
import java.time.LocalDate
import java.time.LocalDateTime

data class FuncionarioRequest(
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
    @field:NotNull(message = "Data de nascimento é obrigatória")
    @field:PastOrPresent(message = "Data de nascimento inválida") val dtNasc: LocalDate?,
    @field:NotNull(message = "Salário é obrigatório")
    @field:Positive(message = "Salário deve ser maior que zero") val salario: BigDecimal?,
    @field:NotNull(message = "Turno é obrigatório") val turno: Turno?,
    @field:NotNull(message = "Cargo é obrigatório") val cargo: Cargo?,
)

/** Campos nulos mantêm o valor atual. O status NÃO é alterado aqui (use /desativar e /reativar). */
data class FuncionarioUpdateRequest(
    val nome: String?,
    @field:Pattern(regexp = Padroes.CPF, message = "CPF inválido") val cpf: String?,
    @field:Pattern(regexp = Padroes.EMAIL, message = "Estrutura de email inválida") val email: String?,
    @field:Pattern(regexp = Padroes.TELEFONE, message = "Telefone inválido (use DDD + número, apenas dígitos)") val telefone: String?,
    @field:Pattern(regexp = Padroes.CIDADE_UF, message = "Use o formato 'cidade, UF'") val cidade: String?,
    @field:Pattern(regexp = Padroes.ENDERECO, message = "Use o formato 'rua, número'") val endereco: String?,
    @field:PastOrPresent(message = "Data de nascimento inválida") val dtNasc: LocalDate?,
    @field:Positive(message = "Salário deve ser maior que zero") val salario: BigDecimal?,
    val turno: Turno?,
    val cargo: Cargo?,
)

data class FuncionarioResponse(
    val id: Long,
    val tipo: TipoPessoa,
    val nome: String,
    val cpf: String,
    val email: String,
    val telefone: String,
    val cidade: String,
    val endereco: String,
    val dtNasc: LocalDate?,
    val salario: BigDecimal,
    val turno: Turno,
    val cargo: Cargo,
    val status: StatusCadastro,
    val dtCriacao: LocalDateTime,
)

fun Funcionario.toResponse() = FuncionarioResponse(
    id = id!!, tipo = tipo, nome = nome, cpf = cpf, email = email, telefone = telefone,
    cidade = cidade, endereco = endereco, dtNasc = dtNasc, salario = salario, turno = turno,
    cargo = cargo, status = status, dtCriacao = dtCriacao,
)
