package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import Projeto.de.teste.Back.demo.service.ConsultaService
import Projeto.de.teste.Back.demo.web.dto.MovimentacaoResponse
import Projeto.de.teste.Back.demo.web.dto.TransacaoResponse
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/consultas")
class ConsultaController(private val consultaService: ConsultaService) {

    /** `?tipo=ENTRADA|SAIDA` filtra; `?detalhado=true` inclui os dados completos do produto. */
    @GetMapping("/movimentacoes")
    fun movimentacoes(
        @RequestParam("tipo", required = false) tipo: TipoMovimentacao?,
        @RequestParam("detalhado", defaultValue = "false") detalhado: Boolean,
    ): List<MovimentacaoResponse> = consultaService.movimentacoes(tipo, detalhado)

    /** `?tipo=ENTRADA|SAIDA` filtra; `?detalhado=true` inclui os dados da pessoa envolvida. */
    @GetMapping("/transacoes")
    fun transacoes(
        @RequestParam("tipo", required = false) tipo: TipoTransacao?,
        @RequestParam("detalhado", defaultValue = "false") detalhado: Boolean,
    ): List<TransacaoResponse> = consultaService.transacoes(tipo, detalhado)
}
