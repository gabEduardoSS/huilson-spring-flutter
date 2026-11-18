package Projeto.de.teste.Back.demo.config

import Projeto.de.teste.Back.demo.service.RevogacaoTokenService
import Projeto.de.teste.Back.demo.service.TokenService
import jakarta.servlet.http.HttpServletResponse
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter

/**
 * Configuração do Spring Security: troca o comportamento padrão (tela de login HTML + senha gerada
 * no console) por uma API que usa o login do Flutter.
 *
 * FLUXO COMPLETO:
 *  1. Flutter faz  POST /api/auth/login  { usuario, senha }   (rota pública, ver abaixo)
 *  2. [AuthController] confere a senha (AuthService) e devolve um token (TokenService).
 *  3. Flutter guarda o token e manda  Authorization: Bearer <token>  em TODAS as outras chamadas.
 *  4. [TokenAuthFilter] lê o token; se for válido, a requisição passa. Se não, responde 401 em JSON
 *     e o Flutter volta para a tela de login.
 *
 * Por que a tela padrão do Spring some: ela só existe se `formLogin()` estiver ativo. Aqui ele está
 * desligado explicitamente.
 */
@Configuration
@EnableWebSecurity
class SecurityConfig {

    @Bean
    fun securityFilterChain(
        http: HttpSecurity,
        tokenService: TokenService,
        revogacao: RevogacaoTokenService,
    ): SecurityFilterChain {
        http
            // CSRF protege sessões com cookie. Aqui não há cookie/sessão (usamos token no header), então desliga.
            .csrf { it.disable() }

            // CORS: usa a configuração do Beans.kt (addCorsMappings, origens em app.cors.allowed-origins).
            // Só importa se o Flutter rodar na Web; em mobile/desktop o CORS não é usado.
            .cors { }

            // STATELESS = o servidor não guarda sessão. Cada requisição se prova sozinha pelo token.
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }

            // Desliga a tela de login e o popup de login "Basic" padrão do Spring.
            .formLogin { it.disable() }
            .httpBasic { it.disable() }
            .logout { it.disable() } // sair = o Flutter apagar o token (não há sessão no servidor)

            .authorizeHttpRequests {
                // Pré-requisição que o navegador faz antes de POST/PATCH com JSON (Flutter Web).
                it.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                // ÚNICAS rotas públicas: o login e o "está vivo?".
                // /api/auth/registro NÃO está aqui: só quem já está logado pode criar usuários.
                it.requestMatchers("/api/auth/login", "/api/alive").permitAll()

                // Todo o resto (/api/clientes, /api/vendas, /api/caixa, ...) exige token válido.
                it.anyRequest().authenticated()
            }

            // Sem token válido em rota protegida: responde 401 em JSON (o padrão seria 403 sem corpo).
            .exceptionHandling { it.authenticationEntryPoint(naoAutenticado) }

            // Nosso filtro roda ANTES do filtro de login padrão e preenche a autenticação a partir do token.
            .addFilterBefore(TokenAuthFilter(tokenService, revogacao), UsernamePasswordAuthenticationFilter::class.java)

        return http.build()
    }

    /**
     * Resposta 401 no mesmo formato dos outros erros da API (ApiExceptionHandler): { status, title, detail }.
     * O Flutter lê o campo "detail" para mostrar a mensagem.
     */
    private val naoAutenticado = AuthenticationEntryPoint { _, response, _ ->
        response.status = HttpServletResponse.SC_UNAUTHORIZED
        response.contentType = "application/json;charset=UTF-8"
        response.writer.write(
            """{"status":401,"title":"Não autorizado","detail":"Sessão ausente ou expirada. Faça login novamente."}""",
        )
    }

    /**
     * Existe só para o Spring Boot NÃO criar o usuário "user" com senha aleatória impressa no console
     * ("Using generated security password..."). Ele só cria esse usuário quando não há nenhum
     * UserDetailsService. Este nunca é usado de verdade: o login é feito pelo AuthService.
     */
    @Bean
    fun userDetailsService(): UserDetailsService =
        UserDetailsService { _ -> throw UsernameNotFoundException("O login é feito em /api/auth/login") }
}
