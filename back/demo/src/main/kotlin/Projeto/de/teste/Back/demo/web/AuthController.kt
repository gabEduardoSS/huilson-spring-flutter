package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.service.AuthService
import Projeto.de.teste.Back.demo.web.dto.LoginRequest
import Projeto.de.teste.Back.demo.web.dto.RegistroRequest
import Projeto.de.teste.Back.demo.web.dto.UsuarioResponse
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/auth")
class AuthController(private val authService: AuthService) {

    @PostMapping("/registro")
    @ResponseStatus(HttpStatus.CREATED)
    fun registrar(@Valid @RequestBody req: RegistroRequest): UsuarioResponse = authService.registrar(req)

    @PostMapping("/login")
    fun login(@Valid @RequestBody req: LoginRequest): UsuarioResponse = authService.autenticar(req)
}
