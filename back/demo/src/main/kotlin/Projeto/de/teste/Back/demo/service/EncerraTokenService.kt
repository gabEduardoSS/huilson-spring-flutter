package Projeto.de.teste.Back.demo.service

import org.springframework.stereotype.Service
import java.util.concurrent.ConcurrentHashMap
import org.springframework.beans.factory.annotation.Value

@Service
class RevogacaoTokenService(
    // Quanto tempo de silêncio é permitido. Vem do application.properties (padrão 15).
    @Value("\${app.sessao.inatividade-minutos:15}") minutosDeInatividade: Long,
) {
    private val limiteMs = minutosDeInatividade * 60_000

    // Tokens cancelados (logout ou inatividade).
    private val revogados = ConcurrentHashMap.newKeySet<String>()

    // Token -> hora (em milissegundos) da última requisição dele.
    private val ultimaAtividade = ConcurrentHashMap<String, Long>()

    /** Cancela o token (chamado pelo POST /api/auth/logout). */
    fun revogar(token: String) {
        revogados.add(token)
        ultimaAtividade.remove(token)
    }

    /**
     * Chamado pelo TokenAuthFilter em TODA requisição que chega com token válido.
     * Devolve true se a sessão está viva, e false se foi cancelada ou ficou inativa.
     * Quando devolve true, já registra "agora" como a última atividade (o relógio recomeça).
     */
    fun sessaoAtiva(token: String): Boolean {
        if (token in revogados) return false

        val agora = System.currentTimeMillis()
        val anterior = ultimaAtividade[token]

        // Passou tempo demais desde a última requisição: cancela o token de vez.
        if (anterior != null && agora - anterior > limiteMs) {
            revogar(token)
            return false
        }

        ultimaAtividade[token] = agora
        return true
    }
}