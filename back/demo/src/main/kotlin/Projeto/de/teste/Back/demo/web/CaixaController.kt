package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.service.CaixaService
import Projeto.de.teste.Back.demo.web.dto.SaldoResponse
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/caixa")
class CaixaController(private val caixaService: CaixaService) {

    @GetMapping("/saldo")
    fun consultarSaldo(): SaldoResponse = caixaService.consultarSaldo()
}
