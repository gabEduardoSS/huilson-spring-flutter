package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.service.ClienteService
import Projeto.de.teste.Back.demo.web.dto.ClienteRequest
import Projeto.de.teste.Back.demo.web.dto.ClienteResponse
import Projeto.de.teste.Back.demo.web.dto.ClienteUpdateRequest
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/clientes")
class ClienteController(private val clienteService: ClienteService) {

    @GetMapping
    fun listar(): List<ClienteResponse> = clienteService.listar()

    @GetMapping("/{id}")
    fun buscar(@PathVariable("id") id: Long): ClienteResponse = clienteService.buscar(id)

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun cadastrar(@Valid @RequestBody req: ClienteRequest): ClienteResponse = clienteService.cadastrar(req)

    @PatchMapping("/{id}")
    fun alterar(
        @PathVariable("id") id: Long,
        @Valid @RequestBody req: ClienteUpdateRequest,
    ): ClienteResponse = clienteService.alterar(id, req)
}
