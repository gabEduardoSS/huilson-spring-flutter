package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.model.Caixa
import jakarta.persistence.LockModeType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface CaixaRepository : JpaRepository<Caixa, Long> {
    /** Trava o saldo até o fim da transação: duas vendas/compras simultâneas não se atropelam. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select c from Caixa c where c.id = :id")
    fun buscarParaAtualizar(@Param("id") id: Long): Caixa?
}
