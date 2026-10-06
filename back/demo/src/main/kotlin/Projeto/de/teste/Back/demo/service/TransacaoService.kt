package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.enums.StatusFinanceiro
import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import Projeto.de.teste.Back.demo.domain.model.Caixa
import Projeto.de.teste.Back.demo.domain.model.Pessoa
import Projeto.de.teste.Back.demo.domain.model.Transacao
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.exception.SaldoInsuficienteException
import Projeto.de.teste.Back.demo.repository.CaixaRepository
import Projeto.de.teste.Back.demo.repository.TransacaoRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import java.math.BigDecimal
import java.time.LocalDateTime

/**
 * Movimenta o saldo do caixa. No projeto JDBC esta lógica (conferir saldo, calcular saldo anterior/posterior,
 * marcar como CONCLUIDA) acontecia no banco; agora é código, dentro da transação da venda/compra.
 */
@Service
class TransacaoService(
    private val caixaRepository: CaixaRepository,
    private val transacaoRepository: TransacaoRepository,
) {
    /** Exige uma transação já aberta (venda/compra): se algo falhar depois, o saldo volta ao que era. */
    @Transactional(propagation = Propagation.MANDATORY)
    fun registrar(valor: BigDecimal, pessoa: Pessoa, tipo: TipoTransacao): Transacao {
        val caixa = caixaRepository.buscarParaAtualizar(Caixa.ID_PRINCIPAL)
            ?: throw NaoEncontradoException("Nenhum registro de caixa encontrado")

        val saldoAnterior = caixa.saldo
        val saldoPosterior = saldoAnterior + tipo.valor * valor

        if (saldoPosterior < BigDecimal.ZERO) {
            throw SaldoInsuficienteException("Saldo insuficiente no caixa: disponível $saldoAnterior, necessário $valor")
        }
        caixa.saldo = saldoPosterior

        return transacaoRepository.save(
            Transacao(
                valor = valor,
                pessoa = pessoa,
                caixa = caixa,
                tipo = tipo,
                saldoAnterior = saldoAnterior,
                saldoPosterior = saldoPosterior,
                status = StatusFinanceiro.CONCLUIDA,
                data = LocalDateTime.now(),
            ),
        )
    }
}
