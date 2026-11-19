package Projeto.de.teste.Back.demo.config

import Projeto.de.teste.Back.demo.domain.model.Caixa
import Projeto.de.teste.Back.demo.repository.CaixaRepository
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.stereotype.Component
import java.math.BigDecimal

@Component
class CaixaInicializador(
    private val caixaRepository: CaixaRepository,
    @Value("\${app.caixa.saldo-inicial:0}") saldoInicial: BigDecimal,
) : ApplicationRunner {
    private val log = LoggerFactory.getLogger(javaClass)
    private val saldo: BigDecimal = saldoInicial

    override fun run(args: ApplicationArguments) {
        println("AAAAAAAAAAAAAAAAAAAAAAAAA:${saldo}")
        caixaRepository.save(Caixa(id = Caixa.ID_PRINCIPAL, saldo = saldo))
        log.info("Caixa ${if(!caixaRepository.existsById(Caixa.ID_PRINCIPAL)) "criado" else "atualizado"} com saldo inicial de {}", saldo)
    }
}
