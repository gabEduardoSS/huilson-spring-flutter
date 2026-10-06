package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
import Projeto.de.teste.Back.demo.domain.model.Movimentacao
import org.springframework.data.jpa.repository.EntityGraph
import org.springframework.data.jpa.repository.JpaRepository

interface MovimentacaoRepository : JpaRepository<Movimentacao, Long> {
    @EntityGraph(attributePaths = ["produto"])
    fun findAllByOrderByIdAsc(): List<Movimentacao>

    @EntityGraph(attributePaths = ["produto"])
    fun findByTipoOrderByIdAsc(tipo: TipoMovimentacao): List<Movimentacao>

    fun existsByProdutoId(produtoId: Long): Boolean
}
