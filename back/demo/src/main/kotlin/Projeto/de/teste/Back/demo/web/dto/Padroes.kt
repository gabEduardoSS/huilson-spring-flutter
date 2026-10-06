package Projeto.de.teste.Back.demo.web.dto

/**
 * Regras de formato que antes viviam em `validarCampoString` / `validarCampoNumerico` (LocalUtils.kt).
 * Agora são aplicadas com Bean Validation nos DTOs de entrada.
 */
object Padroes {
    /** 000.000.000-00 ou só dígitos (pontuação opcional). O service remove a pontuação antes de gravar. */
    const val CPF = "^[0-9]{3}\\.?[0-9]{3}\\.?[0-9]{3}-?[0-9]{2}$"

    const val EMAIL = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z.]+$"

    /** "Cidade, UF" */
    const val CIDADE_UF = "^[A-Za-zÀ-ÿ\\s]+,\\s*[A-Za-z]{2}$"

    /** "Rua, número" */
    const val ENDERECO = "^.+,\\s*[A-Za-z0-9]+$"

    /** DDD + número, apenas dígitos (10 ou 11). */
    const val TELEFONE = "^[0-9]{10,11}$"
}
