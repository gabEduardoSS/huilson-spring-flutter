package Projeto.de.teste.Back.demo.domain.model

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.OneToOne
import jakarta.persistence.Table
import java.math.BigDecimal

@Entity
@Table(name = "item_compra")
class ItemCompra(
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_compra") var compra: Compra,
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_produto") var produto: CaixaDeAgua,
    @OneToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_movimentacao") var movimentacao: Movimentacao,
    @Column(name = "preco_unitario", nullable = false, precision = 14, scale = 2) var precoUnitario: BigDecimal,
    @Column(nullable = false) var quantidade: Int,
    @Column(name = "preco_total_item", nullable = false, precision = 14, scale = 2) var precoTotal: BigDecimal,
) {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
}
