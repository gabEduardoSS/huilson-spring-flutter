package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.StatusFinanceiro
import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
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
import java.time.LocalDateTime

/** Movimento de estoque de um produto (compra = ENTRADA, venda = SAIDA). */
@Entity
@Table(name = "movimentacao")
class Movimentacao(
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_produto") var produto: CaixaDeAgua,
    @Column(nullable = false) var quantidade: Int,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 20) var tipo: TipoMovimentacao,
    @Column(columnDefinition = "text") var descricao: String?,
    @Column(name = "quantidade_anterior", nullable = false) var quantidadeAnterior: Int,
    @Column(name = "quantidade_posterior", nullable = false) var quantidadePosterior: Int,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 20) var status: StatusFinanceiro = StatusFinanceiro.CONCLUIDA,
    @Column(name = "data", nullable = false) var data: LocalDateTime = LocalDateTime.now(),
) {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
}
