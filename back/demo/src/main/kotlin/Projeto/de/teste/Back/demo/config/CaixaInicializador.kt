package Projeto.de.teste.Back.demo.config

import Projeto.de.teste.Back.demo.domain.model.Caixa
import Projeto.de.teste.Back.demo.repository.CaixaRepository
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.stereotype.Component
import java.math.BigDecimal

/** Garante que o registro único do caixa (id = 1) exista; o sistema antigo assumia que ele já estava no banco. */
@Component
class CaixaInicializador(
    private val caixaRepository: CaixaRepository,
    @Value("\${app.caixa.saldo-inicial:0}") saldoInicial: BigDecimal,
) : ApplicationRunner {
    private val log = LoggerFactory.getLogger(javaClass)
    private val saldo: BigDecimal = saldoInicial

    override fun run(args: ApplicationArguments) {
        if (!caixaRepository.existsById(Caixa.ID_PRINCIPAL)) {
            caixaRepository.save(Caixa(saldo = saldo))
            log.info("Caixa criado com saldo inicial de {}", saldo)
        }
    }
}
