package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.StatusFinanceiro
import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import java.math.BigDecimal
import java.time.LocalDateTime

/** Movimento de dinheiro no caixa (venda = ENTRADA, compra = SAIDA). */
@Entity
@Table(name = "transacao")
class Transacao(
    @Column(nullable = false, precision = 14, scale = 2) var valor: BigDecimal,
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_pessoa") var pessoa: Pessoa,
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_caixa") var caixa: Caixa,
    @Enumerated(EnumType.STRING) @Column(name = "tipo", nullable = false, length = 20) var tipo: TipoTransacao,
    @Column(name = "saldo_anterior", nullable = false, precision = 14, scale = 2) var saldoAnterior: BigDecimal,
    @Column(name = "saldo_posterior", nullable = false, precision = 14, scale = 2) var saldoPosterior: BigDecimal,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 20) var status: StatusFinanceiro = StatusFinanceiro.CONCLUIDA,
    @Column(name = "data", nullable = false) var data: LocalDateTime = LocalDateTime.now(),
) {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
}
