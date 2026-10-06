package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.model.Funcionario
import org.springframework.data.jpa.repository.JpaRepository

interface FuncionarioRepository : JpaRepository<Funcionario, Long> {
    fun findAllByOrderByIdAsc(): List<Funcionario>
    fun findByStatusOrderByIdAsc(status: StatusCadastro): List<Funcionario>
    fun findByCargoOrderByIdAsc(cargo: Cargo): List<Funcionario>
    fun findByStatusAndCargoOrderByIdAsc(status: StatusCadastro, cargo: Cargo): List<Funcionario>
}
