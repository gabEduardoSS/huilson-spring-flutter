package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.Cor
import Projeto.de.teste.Back.demo.domain.enums.Formato
import Projeto.de.teste.Back.demo.domain.enums.Material
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import jakarta.persistence.Column
import jakarta.persistence.Convert
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.math.BigDecimal
import java.time.LocalDateTime

/**
 * Produto vendido pela empresa.
 * [dimensao] segue a ordem do projeto bb: [altura, largura, profundidade] (coluna float8[]).
 */
@Entity
@Table(name = "caixa_de_agua")
class CaixaDeAgua(
    @Column(nullable = false) var marca: String,
    @Column(nullable = false) var modelo: String,
    @JdbcTypeCode(SqlTypes.ARRAY) @Column(nullable = false, columnDefinition = "float8[]")
    var dimensao: MutableList<Double>,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 30) var cor: Cor,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 30) var material: Material,
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 30) var formato: Formato,
    @Column(nullable = false) var fornecedor: String,
    @Column(nullable = false, precision = 14, scale = 2) var preco: BigDecimal,
) {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null

    @Convert(converter = StatusCadastroConverter::class)
    @Column(nullable = false, length = 20)
    var status: StatusCadastro = StatusCadastro.ATIVO

    /** Estoque atual. Só deve ser alterado via [Projeto.de.teste.Back.demo.service.MovimentacaoService]. */
    @Column(nullable = false)
    var quantidade: Int = 0

    @Column(name = "dt_criacao", nullable = false, updatable = false)
    var dtCriacao: LocalDateTime = LocalDateTime.now()

    val altura: Double get() = dimensao[0]
    val largura: Double get() = dimensao[1]
    val profundidade: Double get() = dimensao[2]
}
