package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.enums.TipoPessoa
import Projeto.de.teste.Back.demo.domain.enums.Turno
import jakarta.persistence.Column
import jakarta.persistence.Convert
import jakarta.persistence.DiscriminatorValue
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Table
import java.math.BigDecimal
import java.time.LocalDate

@Entity
@Table(name = "funcionario")
@DiscriminatorValue("FUNCIONARIO")
class Funcionario(
    nome: String,
    cpf: String,
    email: String,
    telefone: String,
    cidade: String,
    endereco: String,
    dtNasc: LocalDate,
    @Column(nullable = false, precision = 14, scale = 2) var salario: BigDecimal = SALARIO_PADRAO,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 20) var turno: Turno = Turno.MATUTINO,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 30) var cargo: Cargo = Cargo.ATENDIMENTO,
    @Convert(converter = StatusCadastroConverter::class) @Column(nullable = false, length = 20)
    var status: StatusCadastro = StatusCadastro.ATIVO,
) : Pessoa(nome, cpf, email, telefone, cidade, endereco, dtNasc) {
    override val tipo: TipoPessoa get() = TipoPessoa.FUNCIONARIO

    companion object {
        val SALARIO_PADRAO: BigDecimal = BigDecimal("1712.00")
    }
}
