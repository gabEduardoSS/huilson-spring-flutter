package Projeto.de.teste.Back.demo.domain.model

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.math.BigDecimal

/** Caixa financeiro da empresa. Existe um único registro (id = 1), como no projeto original. */
@Entity
@Table(name = "caixa")
class Caixa(
    @Id var id: Long = ID_PRINCIPAL,
    @Column(nullable = false, precision = 14, scale = 2) var saldo: BigDecimal = BigDecimal.ZERO,
) {
    companion object {
        const val ID_PRINCIPAL = 1L
    }
}
