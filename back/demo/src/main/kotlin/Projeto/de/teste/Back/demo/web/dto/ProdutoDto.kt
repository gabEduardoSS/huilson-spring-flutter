package Projeto.de.teste.Back.demo.web.dto

import Projeto.de.teste.Back.demo.domain.enums.Cor
import Projeto.de.teste.Back.demo.domain.enums.Formato
import Projeto.de.teste.Back.demo.domain.enums.Material
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.model.CaixaDeAgua
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Positive
import java.math.BigDecimal
import java.time.LocalDateTime

/** Dimensões em campos separados (no banco continuam como array [altura, largura, profundidade]). */
data class ProdutoRequest(
    @field:NotBlank(message = "Marca é obrigatória") val marca: String?,
    @field:NotBlank(message = "Modelo é obrigatório") val modelo: String?,
    @field:NotNull(message = "Altura é obrigatória")
    @field:Positive(message = "Altura deve ser maior que zero") val altura: Double?,
    @field:NotNull(message = "Largura é obrigatória")
    @field:Positive(message = "Largura deve ser maior que zero") val largura: Double?,
    @field:NotNull(message = "Profundidade é obrigatória")
    @field:Positive(message = "Profundidade deve ser maior que zero") val profundidade: Double?,
    @field:NotNull(message = "Cor é obrigatória") val cor: Cor?,
    @field:NotNull(message = "Material é obrigatório") val material: Material?,
    @field:NotNull(message = "Formato é obrigatório") val formato: Formato?,
    @field:NotBlank(message = "Fornecedor é obrigatório") val fornecedor: String?,
    @field:NotNull(message = "Preço é obrigatório")
    @field:Positive(message = "Preço deve ser maior que zero") val preco: BigDecimal?,
)

/** Campos nulos mantêm o valor atual. Status e estoque não são alterados por aqui. */
data class ProdutoUpdateRequest(
    val marca: String?,
    val modelo: String?,
    @field:Positive(message = "Altura deve ser maior que zero") val altura: Double?,
    @field:Positive(message = "Largura deve ser maior que zero") val largura: Double?,
    @field:Positive(message = "Profundidade deve ser maior que zero") val profundidade: Double?,
    val cor: Cor?,
    val material: Material?,
    val formato: Formato?,
    val fornecedor: String?,
    @field:Positive(message = "Preço deve ser maior que zero") val preco: BigDecimal?,
)

data class ProdutoResponse(
    val id: Long,
    val marca: String,
    val modelo: String,
    val altura: Double,
    val largura: Double,
    val profundidade: Double,
    val cor: Cor,
    val material: Material,
    val formato: Formato,
    val fornecedor: String,
    val preco: BigDecimal,
    val status: StatusCadastro,
    val quantidade: Int,
    val dtCriacao: LocalDateTime,
)

fun CaixaDeAgua.toResponse() = ProdutoResponse(
    id = id!!, marca = marca, modelo = modelo, altura = altura, largura = largura, profundidade = profundidade,
    cor = cor, material = material, formato = formato, fornecedor = fornecedor, preco = preco,
    status = status, quantidade = quantidade, dtCriacao = dtCriacao,
)
