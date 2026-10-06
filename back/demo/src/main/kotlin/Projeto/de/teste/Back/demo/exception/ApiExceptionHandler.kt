package Projeto.de.teste.Back.demo.exception

import org.slf4j.LoggerFactory
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.http.HttpStatus
import org.springframework.http.ProblemDetail
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException

/**
 * Traduz exceções em respostas JSON no formato RFC 7807 (ProblemDetail), que o Flutter
 * pode ler sempre do mesmo jeito: { status, title, detail, erros? }.
 *
 * Não existe handler genérico para `Exception` de propósito: ele engoliria erros do próprio Spring
 * (rota inexistente = 404, método errado = 405) e os transformaria em 500.
 */
@RestControllerAdvice
class ApiExceptionHandler {
    private val log = LoggerFactory.getLogger(javaClass)

    @ExceptionHandler(NaoEncontradoException::class)
    fun naoEncontrado(e: NaoEncontradoException) = problema(HttpStatus.NOT_FOUND, "Não encontrado", e.message)

    @ExceptionHandler(RequisicaoInvalidaException::class)
    fun requisicaoInvalida(e: RequisicaoInvalidaException) =
        problema(HttpStatus.BAD_REQUEST, "Requisição inválida", e.message)

    @ExceptionHandler(ConflitoException::class)
    fun conflito(e: ConflitoException) = problema(HttpStatus.CONFLICT, "Conflito", e.message)

    @ExceptionHandler(CredenciaisInvalidasException::class)
    fun credenciais(e: CredenciaisInvalidasException) = problema(HttpStatus.UNAUTHORIZED, "Não autorizado", e.message)

    @ExceptionHandler(RegraDeNegocioException::class)
    fun regraDeNegocio(e: RegraDeNegocioException) =
        problema(HttpStatus.UNPROCESSABLE_ENTITY, "Regra de negócio violada", e.message)

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun validacao(e: MethodArgumentNotValidException): ProblemDetail {
        val erros = LinkedHashMap<String, String>()
        e.bindingResult.fieldErrors.forEach { erros.putIfAbsent(it.field, it.defaultMessage ?: "Valor inválido") }
        val p = problema(HttpStatus.BAD_REQUEST, "Dados inválidos", "Há campos inválidos na requisição.")
        p.setProperty("erros", erros)
        return p
    }

    @ExceptionHandler(HttpMessageNotReadableException::class)
    fun corpoIlegivel(e: HttpMessageNotReadableException) = problema(
        HttpStatus.BAD_REQUEST,
        "Corpo inválido",
        "Não foi possível ler o corpo da requisição (JSON malformado, tipo errado ou valor de enum inexistente).",
    )

    @ExceptionHandler(MethodArgumentTypeMismatchException::class)
    fun parametroInvalido(e: MethodArgumentTypeMismatchException) =
        problema(HttpStatus.BAD_REQUEST, "Parâmetro inválido", "Valor inválido para o parâmetro '${e.name}'.")

    @ExceptionHandler(DataIntegrityViolationException::class)
    fun integridade(e: DataIntegrityViolationException): ProblemDetail {
        log.warn("Violação de integridade", e)
        return problema(HttpStatus.CONFLICT, "Conflito de dados", "A operação viola uma restrição do banco de dados.")
    }

    private fun problema(status: HttpStatus, titulo: String, detalhe: String?): ProblemDetail =
        ProblemDetail.forStatusAndDetail(status, detalhe ?: titulo).also { it.title = titulo }
}
