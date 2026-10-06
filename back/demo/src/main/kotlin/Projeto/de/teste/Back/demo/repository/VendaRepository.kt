package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.model.Venda
import org.springframework.data.jpa.repository.JpaRepository

interface VendaRepository : JpaRepository<Venda, Long>
