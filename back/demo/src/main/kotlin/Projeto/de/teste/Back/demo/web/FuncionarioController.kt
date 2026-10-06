package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.service.FuncionarioService
import Projeto.de.teste.Back.demo.web.dto.FuncionarioRequest
import Projeto.de.teste.Back.demo.web.dto.FuncionarioResponse
import Projeto.de.teste.Back.demo.web.dto.FuncionarioUpdateRequest
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/funcionarios")
class FuncionarioController(private val funcionarioService: FuncionarioService) {

    /** Ex.: `GET /api/funcionarios?status=ATIVO&cargo=FINANCEIRO` (ambos opcionais). */
    @GetMapping
    fun listar(
        @RequestParam("status", required = false) status: StatusCadastro?,
        @RequestParam("cargo", required = false) cargo: Cargo?,
    ): List<FuncionarioResponse> = funcionarioService.listar(status, cargo)

    @GetMapping("/{id}")
    fun buscar(@PathVariable("id") id: Long): FuncionarioResponse = funcionarioService.buscar(id)

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun cadastrar(@Valid @RequestBody req: FuncionarioRequest): FuncionarioResponse = funcionarioService.cadastrar(req)

    @PatchMapping("/{id}")
    fun alterar(
        @PathVariable("id") id: Long,
        @Valid @RequestBody req: FuncionarioUpdateRequest,
    ): FuncionarioResponse = funcionarioService.alterar(id, req)

    @PostMapping("/{id}/desativar")
    fun desativar(@PathVariable("id") id: Long): FuncionarioResponse = funcionarioService.desativar(id)

    @PostMapping("/{id}/reativar")
    fun reativar(@PathVariable("id") id: Long): FuncionarioResponse = funcionarioService.reativar(id)
}
