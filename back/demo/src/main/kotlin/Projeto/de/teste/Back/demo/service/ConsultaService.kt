package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import Projeto.de.teste.Back.demo.repository.MovimentacaoRepository
import Projeto.de.teste.Back.demo.repository.TransacaoRepository
import Projeto.de.teste.Back.demo.web.dto.MovimentacaoResponse
import Projeto.de.teste.Back.demo.web.dto.TransacaoResponse
import Projeto.de.teste.Back.demo.web.dto.toResponse
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

/** Consultas de histórico (antigo `ConsultasHandler`): "simples" ou "detalhado", com filtro opcional por tipo. */
@Service
class ConsultaService(
    private val movimentacaoRepository: MovimentacaoRepository,
    private val transacaoRepository: TransacaoRepository,
) {
    @Transactional(readOnly = true)
    fun movimentacoes(tipo: TipoMovimentacao?, detalhado: Boolean): List<MovimentacaoResponse> {
        val lista = if (tipo == null) movimentacaoRepository.findAllByOrderByIdAsc()
        else movimentacaoRepository.findByTipoOrderByIdAsc(tipo)
        return lista.map { it.toResponse(detalhado) }
    }

    @Transactional(readOnly = true)
    fun transacoes(tipo: TipoTransacao?, detalhado: Boolean): List<TransacaoResponse> {
        val lista = if (tipo == null) transacaoRepository.findAllByOrderByIdAsc()
        else transacaoRepository.findByTipoOrderByIdAsc(tipo)
        return lista.map { it.toResponse(detalhado) }
    }
}
