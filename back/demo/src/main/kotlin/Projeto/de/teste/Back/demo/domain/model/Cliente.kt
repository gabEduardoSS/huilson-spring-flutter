package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.TipoPessoa
import jakarta.persistence.Column
import jakarta.persistence.DiscriminatorValue
import jakarta.persistence.Entity
import jakarta.persistence.Table
import java.time.LocalDate

@Entity
@Table(name = "cliente")
@DiscriminatorValue("CLIENTE")
class Cliente(
    nome: String,
    cpf: String,
    email: String,
    telefone: String,
    cidade: String,
    endereco: String,
    dtNasc: LocalDate? = null,
    @Column(name = "dividas_abertas", nullable = false) var dividasAbertas: Boolean = false,
) : Pessoa(nome, cpf, email, telefone, cidade, endereco, dtNasc) {
    override val tipo: TipoPessoa get() = TipoPessoa.CLIENTE
}
