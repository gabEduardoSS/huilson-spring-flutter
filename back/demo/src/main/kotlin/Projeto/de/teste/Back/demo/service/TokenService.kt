package Projeto.de.teste.Back.demo.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.security.MessageDigest
import java.time.Instant
import java.util.Base64
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * Gera e valida o TOKEN DE LOGIN que o Flutter recebe em `POST /api/auth/login`.
 *
 * POR QUE NÃO USEI JWT (jjwt)? A dependência está comentada no pom.xml ("a net da faculdade bloqueou").
 * Então aqui o token é montado só com o que já vem no Java (HMAC-SHA256), sem baixar nada.
 * Quando a rede permitir, dá para trocar esta classe por jjwt sem mexer no resto: o resto do
 * sistema só chama `gerar(...)` e `validar(...)`.
 *
 * FORMATO DO TOKEN:   <payload>.<assinatura>
 *   payload    = base64url( "<expiraEmEpochSegundos>|<USUARIO>" )
 *   assinatura = base64url( HMAC-SHA256(payload, app.jwt.secret) )
 *
 * Quem não conhece o `app.jwt.secret` não consegue forjar um token: se alguém alterar o payload
 * (ex.: trocar o usuário ou a validade), a assinatura deixa de bater e o token é recusado.
 * ATENÇÃO: o payload NÃO é criptografado (qualquer um decodifica o base64), então nunca ponha senha nele.
 */
@Service
class TokenService(
    // Segredo usado para assinar. Vem do application.properties (app.jwt.secret) ou da variável JWT_SECRET.
    @Value("\${app.jwt.secret}") segredo: String,
    // Quantas horas o token vale depois do login.
    @Value("\${app.jwt.expiracao-horas:12}") private val horasDeValidade: Long,
) {
    /** Token + o momento em que ele expira (epoch em segundos), para o front saber quando pedir novo login. */
    data class TokenGerado(val token: String, val expiraEm: Long)

    private val chave: SecretKeySpec

    init {
        val bytes = segredo.toByteArray(Charsets.UTF_8)
        // Falha logo na subida do sistema se o segredo for fraco, em vez de rodar inseguro em silêncio.
        require(bytes.size >= 32) { "app.jwt.secret precisa ter pelo menos 32 caracteres." }
        chave = SecretKeySpec(bytes, ALGORITMO)
    }

    /** Cria um token novo para o usuário já autenticado (senha conferida pelo AuthService). */
    fun gerar(usuario: String): TokenGerado {
        val expiraEm = Instant.now().plusSeconds(horasDeValidade * 3600).epochSecond
        val payload = base64.encodeToString("$expiraEm|$usuario".toByteArray(Charsets.UTF_8))
        return TokenGerado(token = "$payload.${assinar(payload)}", expiraEm = expiraEm)
    }

    /**
     * Confere um token recebido no header `Authorization: Bearer <token>`.
     * Devolve o USUÁRIO dono do token, ou `null` se for inválido/adulterado/expirado.
     */
    fun validar(token: String): String? {
        val partes = token.split('.')
        if (partes.size != 2) return null
        val (payload, assinaturaRecebida) = partes

        // 1) A assinatura confere? (comparação em tempo constante, para não vazar informação por tempo de resposta)
        val assinaturaEsperada = assinar(payload)
        if (!MessageDigest.isEqual(assinaturaEsperada.toByteArray(), assinaturaRecebida.toByteArray())) return null

        // 2) O payload é legível?
        val texto = try {
            String(base64Leitor.decode(payload), Charsets.UTF_8)
        } catch (e: IllegalArgumentException) {
            return null
        }
        val separador = texto.indexOf('|')
        if (separador < 0) return null

        // 3) Ainda está dentro da validade?
        val expiraEm = texto.substring(0, separador).toLongOrNull() ?: return null
        if (Instant.now().epochSecond >= expiraEm) return null

        return texto.substring(separador + 1)
    }

    private fun assinar(dado: String): String {
        val mac = Mac.getInstance(ALGORITMO)
        mac.init(chave)
        return base64.encodeToString(mac.doFinal(dado.toByteArray(Charsets.UTF_8)))
    }

    private companion object {
        const val ALGORITMO = "HmacSHA256"
        // base64 "seguro para URL" e sem "=" no fim: não contém "." (usado como separador) nem "/".
        val base64: Base64.Encoder = Base64.getUrlEncoder().withoutPadding()
        val base64Leitor: Base64.Decoder = Base64.getUrlDecoder()
    }
}
