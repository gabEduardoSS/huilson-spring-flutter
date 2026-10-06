package Projeto.de.teste.Back.demo.service

/** Remove pontos e traço do CPF (o regex de entrada já garantiu o formato). */
internal fun String.somenteDigitos(): String = filter { it.isDigit() }

/** Texto digitado vira nulo quando fica em branco; do contrário é aparado. */
internal fun String?.limpo(): String? = this?.trim()?.takeIf { it.isNotEmpty() }
