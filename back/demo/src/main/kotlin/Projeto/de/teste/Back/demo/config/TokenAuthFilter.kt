package Projeto.de.teste.Back.demo.config

import Projeto.de.teste.Back.demo.service.TokenService
import Projeto.de.teste.Back.demo.service.RevogacaoTokenService
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource
import org.springframework.web.filter.OncePerRequestFilter

/**
 * Roda UMA vez em TODA requisição, antes do Spring Security decidir se deixa passar.
 *
 * O que faz:
 *  1. Olha o header `Authorization: Bearer <token>` que o Flutter manda.
 *     - token válido   -> marca a requisição como "autenticada" (o usuário do token fica disponível ao Spring);
 *     - sem token ou token inválido -> não marca nada. Aí as regras do [SecurityConfig] decidem:
 *       rota pública passa; rota protegida responde 401.
 *  2. AUDITORIA EM LOG ("quem acessou?"):
 *     - coloca o usuário no MDC, que faz o nome aparecer em TODA linha de log daquela requisição
 *       (precisa do `logging.pattern.level` no application.properties);
 *     - ao final, escreve uma linha de acesso: método, rota e status da resposta.
 *
 * IMPORTANTE: esta classe NÃO tem @Component de propósito. Ela é criada dentro do [SecurityConfig].
 * Se fosse @Component, o Spring Boot a registraria uma segunda vez como filtro "solto" do servidor.
 */
class TokenAuthFilter(
    private val tokenService: TokenService,
    private val revogacao: RevogacaoTokenService,
) : OncePerRequestFilter() {

    private val log = LoggerFactory.getLogger(javaClass)

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain,
    ) {
        val cabecalho = request.getHeader("Authorization")

        if (cabecalho != null && cabecalho.startsWith("Bearer ")) {
            // Tira o "Bearer " e guarda só o token que veio na requisição.
            val token = cabecalho.removePrefix("Bearer ").trim()

            // 1) validar: assinatura certa e dentro do prazo do token?
            // 2) sessaoAtiva: não foi cancelado por logout nem ficou inativo? (também renova o relógio de inatividade)
            val usuario = tokenService.validar(token)?.takeIf { revogacao.sessaoAtiva(token) }

            if (usuario != null) {
                if (SecurityContextHolder.getContext().authentication == null) {
                    // Terceiro parâmetro = lista de permissões (roles). Vazia porque o sistema ainda não usa perfis.
                    val autenticacao = UsernamePasswordAuthenticationToken(usuario, null, emptyList())
                    autenticacao.details = WebAuthenticationDetailsSource().buildDetails(request)
                    SecurityContextHolder.getContext().authentication = autenticacao
                }
                // MDC = "mochila" de dados da requisição atual. O padrão de log lê a chave "usuario".
                MDC.put(CHAVE_MDC_USUARIO, usuario)
            } else {
                // Mandaram um token, mas ele é falso, adulterado ou venceu. NUNCA registre o token em si.
                log.warn("Token inválido, expirado, revogado ou inativo em {} {}", request.method, request.requestURI)
            }
        }

        try {
            // Sempre segue a cadeia; quem barra (401) é o authorizeHttpRequests do SecurityConfig.
            filterChain.doFilter(request, response)
        } finally {
            // O finally garante que isto roda mesmo se a requisição lançar erro.
            // OPTIONS é a "pré-requisição" automática do navegador (CORS): ignorada para não poluir o log.
            if (request.method != "OPTIONS") {
                // Aqui o MDC ainda tem o usuário, então a linha sai como: INFO [ADMIN] GET /api/clientes -> 200
                log.info("{} | {} {} -> {}", CHAVE_MDC_USUARIO ?: "anonimo", request.method, request.requestURI, response.status)
            }
            // Limpa a "mochila". As threads do servidor são reaproveitadas: sem isto, o usuário desta
            // requisição apareceria nos logs da PRÓXIMA requisição que cair na mesma thread.
            MDC.remove(CHAVE_MDC_USUARIO)
        }
    }

    private companion object {
        // Mesmo nome usado em logging.pattern.level (%X{usuario:-anonimo}) no application.properties.
        const val CHAVE_MDC_USUARIO = "usuario"
    }


}
