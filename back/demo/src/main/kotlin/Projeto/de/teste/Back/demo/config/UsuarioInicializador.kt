package Projeto.de.teste.Back.demo.config

import Projeto.de.teste.Back.demo.repository.UsuarioRepository
import Projeto.de.teste.Back.demo.service.AuthService
import Projeto.de.teste.Back.demo.web.dto.RegistroRequest
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.stereotype.Component

/**
 * Roda uma vez quando o sistema sobe e garante que existe o usuário administrador.
 * Como /api/auth/registro agora exige login, este é o "primeiro acesso" do sistema.
 *
 * Usuário e senha vêm do application.properties (app.usuario.user / app.usuario.password)
 * ou das variáveis de ambiente ADMIN_USER / ADMIN_PASSWORD.
 *
 * Obs.: se o admin JÁ existe no banco, a senha NÃO é alterada por aqui (só é criado quando não existe).
 */
@Component
class UsuarioInicializador(
    private val usuarioRepository: UsuarioRepository,
    private val authService: AuthService,
    @Value("\${app.usuario.user}") private val adminUsuario: String,
    @Value("\${app.usuario.password}") private val adminSenha: String, // antes a senha era igual ao usuário
) : ApplicationRunner {

    private val log = LoggerFactory.getLogger(javaClass)

    override fun run(args: ApplicationArguments) {
        val usuario = authService.normalizarUsuario(adminUsuario)
        if (!usuarioRepository.existsByUsuario(usuario)) {
            authService.registrar(RegistroRequest(usuario = usuario, senha = adminSenha))
            log.info("Admin criado")
        } else {
            log.info("Admin já existe")
        }
    }
}
