package Projeto.de.teste.Back.demo.domain.enums

/**
 * Substitui as strings soltas "ativo" / "desativado" do projeto antigo.
 * [valorBanco] mantém exatamente o texto que já era gravado no banco.
 */
enum class StatusCadastro(val valorBanco: String) {
    ATIVO("ativo"),
    DESATIVADO("desativado");

    companion object {
        fun deBanco(valor: String): StatusCadastro =
            entries.firstOrNull { it.valorBanco.equals(valor, ignoreCase = true) }
                ?: throw IllegalArgumentException("Status desconhecido no banco: $valor")
    }
}
