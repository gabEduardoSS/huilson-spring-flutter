package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.model.Usuario
import Projeto.de.teste.Back.demo.exception.ConflitoException
import Projeto.de.teste.Back.demo.exception.CredenciaisInvalidasException
import Projeto.de.teste.Back.demo.exception.RequisicaoInvalidaException
import Projeto.de.teste.Back.demo.repository.UsuarioRepository
import Projeto.de.teste.Back.demo.web.dto.LoginRequest
import Projeto.de.teste.Back.demo.web.dto.RegistroRequest
import Projeto.de.teste.Back.demo.web.dto.UsuarioResponse
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

/** Cadastro e validação de login (funcionalidade vinda do projeto aa, sem leitura de terminal). */
@Service
class AuthService(
    private val usuarioRepository: UsuarioRepository,
    private val passwordEncoder: PasswordEncoder,
) {
    @Transactional
    fun registrar(req: RegistroRequest): UsuarioResponse {
        val usuario = normalizarUsuario(req.usuario!!)
        val senha = req.senha!!.trim() // a senha não passa por uppercase

        validarDadosCadastro(usuario, senha)?.let { throw RequisicaoInvalidaException(it) }

        if (usuarioRepository.existsByUsuario(usuario)) {
            throw ConflitoException("Este usuário já existe. Escolha outro.")
        }

        val salvo = usuarioRepository.save(Usuario(usuario = usuario, senhaHash = passwordEncoder.encode(senha)!!))
        return UsuarioResponse(salvo.id!!, salvo.usuario)
    }

    @Transactional(readOnly = true)
    fun autenticar(req: LoginRequest): UsuarioResponse {
        val usuario = normalizarUsuario(req.usuario!!)
        val senha = req.senha!!.trim()

        val credencial = usuarioRepository.findByUsuario(usuario)
        // Mesma resposta para "usuário inexistente" e "senha incorreta", para não revelar quais usuários existem.
        if (credencial == null || !passwordEncoder.matches(senha, credencial.senhaHash)) {
            throw CredenciaisInvalidasException()
        }
        return UsuarioResponse(credencial.id!!, credencial.usuario)
    }

    private fun normalizarUsuario(valor: String): String = valor.trim().uppercase()

    /** Mesmas regras do `validarDadosCadastro` do projeto aa; devolve a mensagem de erro ou null se estiver tudo certo. */
    internal fun validarDadosCadastro(usuario: String, senha: String): String? = when {
        usuario.isBlank() -> "Usuário não pode ser vazio."
        senha.isBlank() -> "Senha não pode ser vazia."
        usuario.length < 5 -> "Usuário deve ter pelo menos 5 caracteres."
        senha.length < 5 -> "Senha deve ter pelo menos 5 caracteres."
        usuario.any { it.isWhitespace() } -> "Usuário não pode conter espaços."
        // BCrypt só considera os primeiros 72 bytes da senha.
        senha.toByteArray(Charsets.UTF_8).size > 72 -> "Senha deve ter no máximo 72 bytes."
        else -> null
    }
}
