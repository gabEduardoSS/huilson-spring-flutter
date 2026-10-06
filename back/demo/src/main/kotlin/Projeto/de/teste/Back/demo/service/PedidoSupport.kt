package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.model.CaixaDeAgua
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.exception.RegraDeNegocioException
import Projeto.de.teste.Back.demo.repository.CaixaDeAguaRepository
import Projeto.de.teste.Back.demo.web.dto.ItemPedidoRequest
import java.math.BigDecimal

/**
 * Trava os produtos do pedido (sempre em ordem crescente de ID, para duas vendas simultâneas
 * não ficarem esperando uma pela outra) e devolve um mapa id -> produto.
 */
internal fun CaixaDeAguaRepository.carregarComTrava(itens: List<ItemPedidoRequest>): Map<Long, CaixaDeAgua> =
    itens.map { it.produtoId!! }.distinct().sorted().associateWith { id ->
        buscarParaAtualizar(id) ?: throw NaoEncontradoException("Produto com ID $id não encontrado")
    }

internal fun calcularTotal(itens: List<ItemPedidoRequest>, produtos: Map<Long, CaixaDeAgua>): BigDecimal =
    itens.fold(BigDecimal.ZERO) { acc, item ->
        acc + produtos.getValue(item.produtoId!!).preco * BigDecimal(item.quantidade!!)
    }

internal fun validarDesconto(desconto: BigDecimal, total: BigDecimal) {
    if (desconto > total) {
        throw RegraDeNegocioException("O desconto ($desconto) não pode ser maior que o valor total ($total)")
    }
}
