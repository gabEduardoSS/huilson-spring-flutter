package Projeto.de.teste.Back.demo.domain.model

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.LocalDateTime

/** Credencial de acesso ao sistema (vem do projeto aa). A senha é guardada apenas como hash BCrypt. */
@Entity
@Table(name = "usuario")
class Usuario(
    @Column(nullable = false, unique = true, length = 100) var usuario: String,
    @Column(name = "senha_hash", nullable = false) var senhaHash: String,
) {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null

    @Column(name = "dt_criacao", nullable = false, updatable = false)
    var dtCriacao: LocalDateTime = LocalDateTime.now()
}
