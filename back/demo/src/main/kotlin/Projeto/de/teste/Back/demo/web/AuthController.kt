package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.exception.CredenciaisInvalidasException
import Projeto.de.teste.Back.demo.service.RevogacaoTokenService
import org.springframework.web.bind.annotation.RequestHeader
import Projeto.de.teste.Back.demo.service.AuthService
import Projeto.de.teste.Back.demo.service.TokenService
import Projeto.de.teste.Back.demo.web.dto.LoginRequest
import Projeto.de.teste.Back.demo.web.dto.LoginResponse
import Projeto.de.teste.Back.demo.web.dto.RegistroRequest
import Projeto.de.teste.Back.demo.web.dto.UsuarioResponse
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.Valid
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val authService: AuthService,
    private val tokenService: TokenService, // gera o token devolvido no login
    private val revogacao: RevogacaoTokenService,
) {
    private val log = LoggerFactory.getLogger(javaClass)

    /**
     * Cria um usuário. NÃO é mais público: exige token (ver SecurityConfig), então só quem já
     * está logado consegue cadastrar. O admin inicial é criado no start pelo UsuarioInicializador.
     */
    @PostMapping("/registro")
    @ResponseStatus(HttpStatus.CREATED)
    fun registrar(@Valid @RequestBody req: RegistroRequest): UsuarioResponse = authService.registrar(req)

    /**
     * Rota pública. Confere usuário/senha; se estiverem certos devolve o token.
     * Se estiverem errados o AuthService lança CredenciaisInvalidasException -> 401 (ApiExceptionHandler).
     *
     * AUDITORIA: toda tentativa de login vai para o log, com o IP de quem tentou
     *  - "Login OK"     : quem entrou e de onde;
     *  - "Login FALHOU" : serve para notar tentativas de adivinhar senha (muitas falhas seguidas do mesmo IP).
     */
    @PostMapping("/login")
    fun login(@Valid @RequestBody req: LoginRequest, http: HttpServletRequest): LoginResponse {
        // remoteAddr = IP de quem abriu a conexão. Atrás de proxy/load balancer ele mostra o IP do PROXY;
        // nesse caso configure `server.forward-headers-strategy=framework` no application.properties.
        // (Não leio o header X-Forwarded-For na mão: qualquer cliente pode inventar esse valor.)
        val ip = http.remoteAddr

        try {
            val usuario = authService.autenticar(req)
            val token = tokenService.gerar(usuario.usuario)
            log.info("Login OK: usuario='{}' ip={}", usuario.usuario, ip)
            return LoginResponse(
                id = usuario.id,
                usuario = usuario.usuario,
                token = token.token,
                expiraEm = token.expiraEm,
            )
        } catch (e: CredenciaisInvalidasException) {
            log.warn("Login FALHOU: usuario='{}' ip={}", paraLog(req.usuario), ip)
            throw e // relança: o ApiExceptionHandler continua respondendo 401 normalmente
        }
    }

    /**
     * Higieniza texto digitado pelo cliente antes de escrever no log:
     *  - troca quebras de linha/tab por "_" (senão alguém forja linhas falsas no log, o "log injection");
     *  - corta em 50 caracteres.
     * Atenção: quem erra e digita a SENHA no campo usuário acabaria com ela no log. Por isso o corte,
     * e por isso o log de falhas deve ficar restrito a quem administra o servidor.
     */
    private fun paraLog(texto: String?): String =
        (texto ?: "").replace(Regex("[\\r\\n\\t]"), "_").take(50)

    /** Logout: cancela o token enviado. Depois disso ele recebe 401. Responde 204 (sem corpo). */
    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun logout(@RequestHeader("Authorization") cabecalho: String) {
        revogacao.sessaoAtiva(cabecalho.removePrefix("Bearer ").trim())
    }
}
