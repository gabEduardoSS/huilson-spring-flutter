package Projeto.de.teste.Back.demo.web

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.Cor
import Projeto.de.teste.Back.demo.domain.enums.Formato
import Projeto.de.teste.Back.demo.domain.enums.Material
import Projeto.de.teste.Back.demo.domain.enums.Turno
import Projeto.de.teste.Back.demo.web.dto.OpcoesResponse
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

/** Substitui as listas numeradas que o terminal imprimia ("0 - AZUL_FORTE", ...). O front envia o NOME do valor. */
@RestController
@RequestMapping("/api/opcoes")
class OpcoesController {

    @GetMapping
    fun opcoes() = OpcoesResponse(
        cores = Cor.entries,
        materiais = Material.entries,
        formatos = Formato.entries,
        cargos = Cargo.entries,
        turnos = Turno.entries,
    )
}
