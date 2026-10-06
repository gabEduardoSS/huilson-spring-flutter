package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.service.ProdutoService
import Projeto.de.teste.Back.demo.web.dto.ProdutoRequest
import Projeto.de.teste.Back.demo.web.dto.ProdutoResponse
import Projeto.de.teste.Back.demo.web.dto.ProdutoUpdateRequest
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

/** Produto = caixa d'água. Reúne o CRUD do projeto aa com o fluxo ativar/desativar do projeto bb. */
@RestController
@RequestMapping("/api/produtos")
class ProdutoController(private val produtoService: ProdutoService) {

    /** `GET /api/produtos` lista todos; `?status=ATIVO` ou `?status=DESATIVADO` filtra. */
    @GetMapping
    fun listar(@RequestParam("status", required = false) status: StatusCadastro?): List<ProdutoResponse> =
        produtoService.listar(status)

    @GetMapping("/{id}")
    fun buscar(@PathVariable("id") id: Long): ProdutoResponse = produtoService.buscar(id)

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun cadastrar(@Valid @RequestBody req: ProdutoRequest): ProdutoResponse = produtoService.cadastrar(req)

    @PatchMapping("/{id}")
    fun alterar(
        @PathVariable("id") id: Long,
        @Valid @RequestBody req: ProdutoUpdateRequest,
    ): ProdutoResponse = produtoService.alterar(id, req)

    @PostMapping("/{id}/desativar")
    fun desativar(@PathVariable("id") id: Long): ProdutoResponse = produtoService.desativar(id)

    @PostMapping("/{id}/reativar")
    fun reativar(@PathVariable("id") id: Long): ProdutoResponse = produtoService.reativar(id)

    /** Exclusão definitiva (do projeto aa). Retorna 409 se o produto já tiver histórico de estoque. */
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun excluir(@PathVariable("id") id: Long) = produtoService.excluir(id)
}
