package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.model.CaixaDeAgua
import jakarta.persistence.LockModeType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface CaixaDeAguaRepository : JpaRepository<CaixaDeAgua, Long> {
    fun findAllByOrderByIdAsc(): List<CaixaDeAgua>
    fun findByStatusOrderByIdAsc(status: StatusCadastro): List<CaixaDeAgua>

    /** Trava a linha do produto até o fim da transação, evitando vender o mesmo estoque duas vezes. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from CaixaDeAgua p where p.id = :id")
    fun buscarParaAtualizar(@Param("id") id: Long): CaixaDeAgua?
}
