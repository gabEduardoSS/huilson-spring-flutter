package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.enums.StatusFinanceiro
import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
import Projeto.de.teste.Back.demo.domain.model.CaixaDeAgua
import Projeto.de.teste.Back.demo.domain.model.Movimentacao
import Projeto.de.teste.Back.demo.exception.EstoqueInsuficienteException
import Projeto.de.teste.Back.demo.repository.MovimentacaoRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

/** Movimenta o estoque de um produto (antes feito por trigger no banco). */
@Service
class MovimentacaoService(private val movimentacaoRepository: MovimentacaoRepository) {

    /** [produto] deve ter sido carregado com trava (`buscarParaAtualizar`) dentro da transação em andamento. */
    @Transactional(propagation = Propagation.MANDATORY)
    fun registrar(produto: CaixaDeAgua, quantidade: Int, tipo: TipoMovimentacao, descricao: String? = null): Movimentacao {
        val anterior = produto.quantidade
        val posterior = if (tipo == TipoMovimentacao.ENTRADA) anterior + quantidade else anterior - quantidade

        if (posterior < 0) {
            throw EstoqueInsuficienteException(
                "Estoque insuficiente para o produto ${produto.id}: disponível $anterior, solicitado $quantidade",
            )
        }
        produto.quantidade = posterior

        return movimentacaoRepository.save(
            Movimentacao(
                produto = produto,
                quantidade = quantidade,
                tipo = tipo,
                descricao = descricao,
                quantidadeAnterior = anterior,
                quantidadePosterior = posterior,
                status = StatusFinanceiro.CONCLUIDA,
                data = LocalDateTime.now(),
            ),
        )
    }
}
