package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.StatusFinanceiro
import jakarta.persistence.CascadeType
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
import jakarta.persistence.OneToMany
import jakarta.persistence.OneToOne
import jakarta.persistence.Table
import java.math.BigDecimal
import java.time.LocalDateTime

@Entity
@Table(name = "venda")
class Venda(
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_funcionario") var vendedor: Funcionario,
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_cliente") var cliente: Cliente,
    @OneToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "id_transacao") var transacao: Transacao,
    @Column(name = "valor_total", nullable = false, precision = 14, scale = 2) var valorTotal: BigDecimal,
    @Column(name = "valor_desconto", nullable = false, columnDefinition = "numeric(14,2) default 0") var valorDesconto: BigDecimal = BigDecimal.ZERO,
    @Column(columnDefinition = "text") var descricao: String? = null,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 20) var status: StatusFinanceiro = StatusFinanceiro.CONCLUIDA,
    @Column(name = "data", nullable = false) var data: LocalDateTime = LocalDateTime.now(),
) {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null

    @OneToMany(mappedBy = "venda", cascade = [CascadeType.ALL], orphanRemoval = true)
    var itens: MutableList<ItemVenda> = mutableListOf()
}
