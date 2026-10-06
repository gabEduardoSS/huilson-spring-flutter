package Projeto.de.teste.Back.demo.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
class Beans(
    @Value("\${app.cors.allowed-origins:*}") private val origensPermitidas: String,
) : WebMvcConfigurer {

    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()

    /** Necessário se o Flutter rodar como Web (navegador). Em app mobile/desktop o CORS não é usado. */
    override fun addCorsMappings(registry: CorsRegistry) {
        val origens = origensPermitidas.split(",").map { it.trim() }.filter { it.isNotEmpty() }
        registry.addMapping("/api/**")
            .allowedOriginPatterns(*origens.toTypedArray())
            .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
            .allowedHeaders("*")
    }
}
