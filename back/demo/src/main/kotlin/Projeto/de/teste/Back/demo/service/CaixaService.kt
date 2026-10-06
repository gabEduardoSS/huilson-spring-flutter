package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.model.Caixa
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.repository.CaixaRepository
import Projeto.de.teste.Back.demo.web.dto.SaldoResponse
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class CaixaService(private val caixaRepository: CaixaRepository) {
    @Transactional(readOnly = true)
    fun consultarSaldo(): SaldoResponse {
        val caixa = caixaRepository.findById(Caixa.ID_PRINCIPAL)
            .orElseThrow { NaoEncontradoException("Nenhum registro de caixa encontrado") }
        return SaldoResponse(caixa.saldo)
    }
}
