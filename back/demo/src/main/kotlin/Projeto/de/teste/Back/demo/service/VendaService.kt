package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import Projeto.de.teste.Back.demo.domain.model.ItemVenda
import Projeto.de.teste.Back.demo.domain.model.Venda
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.exception.RegraDeNegocioException
import Projeto.de.teste.Back.demo.repository.CaixaDeAguaRepository
import Projeto.de.teste.Back.demo.repository.ClienteRepository
import Projeto.de.teste.Back.demo.repository.FuncionarioRepository
import Projeto.de.teste.Back.demo.repository.VendaRepository
import Projeto.de.teste.Back.demo.web.dto.VendaRequest
import Projeto.de.teste.Back.demo.web.dto.VendaResponse
import Projeto.de.teste.Back.demo.web.dto.toResponse
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.math.BigDecimal

@Service
class VendaService(
    private val vendaRepository: VendaRepository,
    private val funcionarioRepository: FuncionarioRepository,
    private val clienteRepository: ClienteRepository,
    private val produtoRepository: CaixaDeAguaRepository,
    private val transacaoService: TransacaoService,
    private val movimentacaoService: MovimentacaoService,
) {
    /**
     * Tudo acontece em UMA transação: se o saldo, o estoque ou qualquer gravação falhar,
     * nada é salvo (equivale ao `rollback()` do JPAVenda original).
     */
    @Transactional
    fun realizarVenda(req: VendaRequest): VendaResponse {
        val itens = req.itens!!

        val vendedor = funcionarioRepository.findById(req.vendedorId!!)
            .orElseThrow { NaoEncontradoException("Funcionário com o ID ${req.vendedorId} não encontrado") }
        if (vendedor.cargo != Cargo.ATENDIMENTO) {
            throw RegraDeNegocioException("O funcionário ${vendedor.id} não tem autorização para realizar vendas")
        }

        val cliente = clienteRepository.findById(req.clienteId!!)
            .orElseThrow { NaoEncontradoException("Cliente com o ID ${req.clienteId} não encontrado") }

        val produtos = produtoRepository.carregarComTrava(itens)
        produtos.values.firstOrNull { it.status != StatusCadastro.ATIVO }?.let {
            throw RegraDeNegocioException("O produto ${it.id} está desativado e não pode ser vendido")
        }

        val valorTotal = calcularTotal(itens, produtos)
        val desconto = req.valorDesconto ?: BigDecimal.ZERO
        validarDesconto(desconto, valorTotal)

        // 1) dinheiro entra no caixa
        val transacao = transacaoService.registrar(valorTotal - desconto, cliente, TipoTransacao.ENTRADA)

        // 2) cabeçalho da venda
        val venda = vendaRepository.save(
            Venda(
                vendedor = vendedor,
                cliente = cliente,
                transacao = transacao,
                valorTotal = valorTotal,
                valorDesconto = desconto,
                descricao = req.descricao.limpo(),
            ),
        )

        // 3) cada item baixa o estoque (lança EstoqueInsuficienteException se faltar)
        itens.forEach { item ->
            val produto = produtos.getValue(item.produtoId!!)
            val quantidade = item.quantidade!!
            val movimentacao = movimentacaoService.registrar(produto, quantidade, TipoMovimentacao.SAIDA)
            venda.itens.add(
                ItemVenda(
                    venda = venda,
                    produto = produto,
                    movimentacao = movimentacao,
                    precoUnitario = produto.preco,
                    quantidade = quantidade,
                    precoTotal = produto.preco * BigDecimal(quantidade),
                ),
            )
        }

        return vendaRepository.saveAndFlush(venda).toResponse()
    }
}
