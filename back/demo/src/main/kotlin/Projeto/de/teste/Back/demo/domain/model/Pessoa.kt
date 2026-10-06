package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.TipoPessoa
import jakarta.persistence.Column
import jakarta.persistence.DiscriminatorColumn
import jakarta.persistence.DiscriminatorType
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Inheritance
import jakarta.persistence.InheritanceType
import jakarta.persistence.Table
import jakarta.persistence.Transient
import java.time.LocalDate
import java.time.LocalDateTime

/**
 * Tabela `pessoa` (dados comuns) + `cliente` / `funcionario` (dados específicos),
 * ligadas pela mesma chave `id` — o mesmo desenho que o projeto JDBC já usava.
 * A coluna `tipo` de `pessoa` funciona como discriminador.
 */
@Entity
@Table(name = "pessoa")
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "tipo", discriminatorType = DiscriminatorType.STRING, length = 20)
abstract class Pessoa(
    @Column(nullable = false) var nome: String,
    @Column(nullable = false, length = 14) var cpf: String,
    @Column(nullable = false) var email: String,
    @Column(nullable = false, length = 20) var telefone: String,
    @Column(nullable = false) var cidade: String,
    @Column(nullable = false) var endereco: String,
    @Column(name = "dt_nasc") var dtNasc: LocalDate?,
) {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null

    @Column(name = "dt_criacao", nullable = false, updatable = false)
    var dtCriacao: LocalDateTime = LocalDateTime.now()

    @get:Transient
    abstract val tipo: TipoPessoa
}
