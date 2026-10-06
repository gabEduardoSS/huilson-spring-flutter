package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import Projeto.de.teste.Back.demo.domain.model.Transacao
import org.springframework.data.jpa.repository.EntityGraph
import org.springframework.data.jpa.repository.JpaRepository

interface TransacaoRepository : JpaRepository<Transacao, Long> {
    @EntityGraph(attributePaths = ["pessoa"])
    fun findAllByOrderByIdAsc(): List<Transacao>

    @EntityGraph(attributePaths = ["pessoa"])
    fun findByTipoOrderByIdAsc(tipo: TipoTransacao): List<Transacao>
}
