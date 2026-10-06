package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.service.CompraService
import Projeto.de.teste.Back.demo.web.dto.CompraRequest
import Projeto.de.teste.Back.demo.web.dto.CompraResponse
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/compras")
class CompraController(private val compraService: CompraService) {

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun realizarCompra(@Valid @RequestBody req: CompraRequest): CompraResponse = compraService.realizarCompra(req)
}
