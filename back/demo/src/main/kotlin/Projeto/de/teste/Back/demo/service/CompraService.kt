package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import Projeto.de.teste.Back.demo.domain.model.Compra
import Projeto.de.teste.Back.demo.domain.model.ItemCompra
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.exception.RegraDeNegocioException
import Projeto.de.teste.Back.demo.repository.CaixaDeAguaRepository
import Projeto.de.teste.Back.demo.repository.CompraRepository
import Projeto.de.teste.Back.demo.repository.FuncionarioRepository
import Projeto.de.teste.Back.demo.web.dto.CompraRequest
import Projeto.de.teste.Back.demo.web.dto.CompraResponse
import Projeto.de.teste.Back.demo.web.dto.toResponse
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.math.BigDecimal

@Service
class CompraService(
    private val compraRepository: CompraRepository,
    private val funcionarioRepository: FuncionarioRepository,
    private val produtoRepository: CaixaDeAguaRepository,
    private val transacaoService: TransacaoService,
    private val movimentacaoService: MovimentacaoService,
) {
    /** Uma única transação: se faltar saldo no caixa (ou qualquer outra falha), nada é gravado. */
    @Transactional
    fun realizarCompra(req: CompraRequest): CompraResponse {
        val itens = req.itens!!

        val requisitor = funcionarioRepository.findById(req.requisitorId!!)
            .orElseThrow { NaoEncontradoException("Funcionário com o ID ${req.requisitorId} não encontrado") }
        if (requisitor.cargo != Cargo.FINANCEIRO) {
            throw RegraDeNegocioException("O funcionário ${requisitor.id} não tem autorização para realizar compras")
        }

        // Diferente da venda, a compra aceita produtos desativados (como no projeto original).
        val produtos = produtoRepository.carregarComTrava(itens)

        val valorTotal = calcularTotal(itens, produtos)
        val desconto = req.valorDesconto ?: BigDecimal.ZERO
        validarDesconto(desconto, valorTotal)

        // 1) dinheiro sai do caixa (lança SaldoInsuficienteException se não houver saldo)
        val transacao = transacaoService.registrar(valorTotal - desconto, requisitor, TipoTransacao.SAIDA)

        // 2) cabeçalho da compra
        val compra = compraRepository.save(
            Compra(
                requisitor = requisitor,
                transacao = transacao,
                valorTotal = valorTotal,
                valorDesconto = desconto,
                descricao = req.descricao.limpo(),
            ),
        )

        // 3) cada item dá entrada no estoque
        itens.forEach { item ->
            val produto = produtos.getValue(item.produtoId!!)
            val quantidade = item.quantidade!!
            val movimentacao = movimentacaoService.registrar(produto, quantidade, TipoMovimentacao.ENTRADA)
            compra.itens.add(
                ItemCompra(
                    compra = compra,
                    produto = produto,
                    movimentacao = movimentacao,
                    precoUnitario = produto.preco,
                    quantidade = quantidade,
                    precoTotal = produto.preco * BigDecimal(quantidade),
                ),
            )
        }

        return compraRepository.saveAndFlush(compra).toResponse()
    }
}
