package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.service.VendaService
import Projeto.de.teste.Back.demo.web.dto.VendaRequest
import Projeto.de.teste.Back.demo.web.dto.VendaResponse
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/vendas")
class VendaController(private val vendaService: VendaService) {

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun realizarVenda(@Valid @RequestBody req: VendaRequest): VendaResponse = vendaService.realizarVenda(req)
}
