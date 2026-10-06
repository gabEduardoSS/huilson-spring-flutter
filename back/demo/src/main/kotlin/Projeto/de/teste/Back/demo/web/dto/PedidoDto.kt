package Projeto.de.teste.Back.demo.web.dto

import Projeto.de.teste.Back.demo.domain.enums.StatusFinanceiro
import Projeto.de.teste.Back.demo.domain.model.Compra
import Projeto.de.teste.Back.demo.domain.model.Venda
import jakarta.validation.Valid
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Positive
import jakarta.validation.constraints.PositiveOrZero
import java.math.BigDecimal
import java.time.LocalDateTime

data class ItemPedidoRequest(
    @field:NotNull(message = "ID do produto é obrigatório") val produtoId: Long?,
    @field:NotNull(message = "Quantidade é obrigatória")
    @field:Positive(message = "Quantidade deve ser maior que zero") val quantidade: Int?,
)

data class VendaRequest(
    @field:NotNull(message = "ID do funcionário é obrigatório") val vendedorId: Long?,
    @field:NotNull(message = "ID do cliente é obrigatório") val clienteId: Long?,
    val descricao: String?,
    @field:PositiveOrZero(message = "Desconto não pode ser negativo") val valorDesconto: BigDecimal?,
    @field:NotEmpty(message = "A venda precisa ter pelo menos um produto")
    @field:Valid val itens: List<ItemPedidoRequest>?,
)

data class CompraRequest(
    @field:NotNull(message = "ID do funcionário responsável é obrigatório") val requisitorId: Long?,
    val descricao: String?,
    @field:PositiveOrZero(message = "Desconto não pode ser negativo") val valorDesconto: BigDecimal?,
    @field:NotEmpty(message = "A compra precisa ter pelo menos um produto")
    @field:Valid val itens: List<ItemPedidoRequest>?,
)

data class ItemPedidoResponse(
    val id: Long,
    val produtoId: Long,
    val movimentacaoId: Long,
    val precoUnitario: BigDecimal,
    val quantidade: Int,
    val precoTotal: BigDecimal,
)

data class VendaResponse(
    val id: Long,
    val transacaoId: Long,
    val vendedorId: Long,
    val clienteId: Long,
    val descricao: String?,
    val valorTotal: BigDecimal,
    val valorDesconto: BigDecimal,
    val status: StatusFinanceiro,
    val data: LocalDateTime,
    val itens: List<ItemPedidoResponse>,
)

data class CompraResponse(
    val id: Long,
    val transacaoId: Long,
    val requisitorId: Long,
    val descricao: String?,
    val valorTotal: BigDecimal,
    val valorDesconto: BigDecimal,
    val status: StatusFinanceiro,
    val data: LocalDateTime,
    val itens: List<ItemPedidoResponse>,
)

fun Venda.toResponse() = VendaResponse(
    id = id!!, transacaoId = transacao.id!!, vendedorId = vendedor.id!!, clienteId = cliente.id!!,
    descricao = descricao, valorTotal = valorTotal, valorDesconto = valorDesconto, status = status, data = data,
    itens = itens.map {
        ItemPedidoResponse(it.id!!, it.produto.id!!, it.movimentacao.id!!, it.precoUnitario, it.quantidade, it.precoTotal)
    },
)

fun Compra.toResponse() = CompraResponse(
    id = id!!, transacaoId = transacao.id!!, requisitorId = requisitor.id!!,
    descricao = descricao, valorTotal = valorTotal, valorDesconto = valorDesconto, status = status, data = data,
    itens = itens.map {
        ItemPedidoResponse(it.id!!, it.produto.id!!, it.movimentacao.id!!, it.precoUnitario, it.quantidade, it.precoTotal)
    },
)
