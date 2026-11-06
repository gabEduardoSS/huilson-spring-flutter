package Projeto.de.teste.Back.demo.config

import Projeto.de.teste.Back.demo.domain.model.Usuario
import Projeto.de.teste.Back.demo.repository.UsuarioRepository
import Projeto.de.teste.Back.demo.service.AuthService
import Projeto.de.teste.Back.demo.web.dto.LoginRequest
import Projeto.de.teste.Back.demo.web.dto.RegistroRequest
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Component

@Component
class UsuarioInicializador(
    private val usuarioRepository: UsuarioRepository,
    private val passwordEncoder: PasswordEncoder,
    private val authService: AuthService,
    @Value("\${app.usuario.user}") admin : String
): ApplicationRunner {
    private val log = LoggerFactory.getLogger(javaClass)
    private val adminString: String = admin
    override fun run(args: ApplicationArguments) {
        if(!usuarioRepository.existsByUsuario(adminString)){
            authService.registrar(RegistroRequest(adminString, adminString))
            log.info("criado admin")
        } else{
            log.info("já existe admin")
        }
    }
}