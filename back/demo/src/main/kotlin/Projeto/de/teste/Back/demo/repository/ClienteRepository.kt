package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.model.Cliente
import org.springframework.data.jpa.repository.JpaRepository

interface ClienteRepository : JpaRepository<Cliente, Long> {
    fun findAllByOrderByIdAsc(): List<Cliente>
}
