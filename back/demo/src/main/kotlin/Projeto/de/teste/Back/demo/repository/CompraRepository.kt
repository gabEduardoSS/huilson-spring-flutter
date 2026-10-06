package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.model.Compra
import org.springframework.data.jpa.repository.JpaRepository

interface CompraRepository : JpaRepository<Compra, Long>
