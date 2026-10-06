package Projeto.de.teste.Back.demo.repository

import Projeto.de.teste.Back.demo.domain.model.Usuario
import org.springframework.data.jpa.repository.JpaRepository

interface UsuarioRepository : JpaRepository<Usuario, Long> {
    fun findByUsuario(usuario: String): Usuario?
    fun existsByUsuario(usuario: String): Boolean
}
