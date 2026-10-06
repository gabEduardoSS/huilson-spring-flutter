package Projeto.de.teste.Back.demo.domain.enums

import java.math.BigDecimal

/** [valor] é o sinal da operação sobre o saldo do caixa (+1 entra dinheiro, -1 sai dinheiro). */
enum class TipoTransacao(val valor: BigDecimal) {
    ENTRADA(BigDecimal.ONE),
    SAIDA(BigDecimal.ONE.negate())
}
