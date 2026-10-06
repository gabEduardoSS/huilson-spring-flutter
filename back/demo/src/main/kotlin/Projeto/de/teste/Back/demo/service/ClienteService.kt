package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.model.Cliente
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.repository.ClienteRepository
import Projeto.de.teste.Back.demo.web.dto.ClienteRequest
import Projeto.de.teste.Back.demo.web.dto.ClienteResponse
import Projeto.de.teste.Back.demo.web.dto.ClienteUpdateRequest
import Projeto.de.teste.Back.demo.web.dto.toResponse
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class ClienteService(private val clienteRepository: ClienteRepository) {

    @Transactional(readOnly = true)
    fun listar(): List<ClienteResponse> = clienteRepository.findAllByOrderByIdAsc().map { it.toResponse() }

    @Transactional(readOnly = true)
    fun buscar(id: Long): ClienteResponse = obter(id).toResponse()

    @Transactional
    fun cadastrar(req: ClienteRequest): ClienteResponse {
        val cliente = Cliente(
            nome = req.nome!!.trim(),
            cpf = req.cpf!!.somenteDigitos(),
            email = req.email!!.trim(),
            telefone = req.telefone!!.somenteDigitos(),
            cidade = req.cidade!!.trim(),
            endereco = req.endereco!!.trim(),
            dtNasc = req.dtNasc,
        )
        return clienteRepository.save(cliente).toResponse()
    }

    @Transactional
    fun alterar(id: Long, req: ClienteUpdateRequest): ClienteResponse {
        val cliente = obter(id)
        req.nome.limpo()?.let { cliente.nome = it }
        req.cpf.limpo()?.let { cliente.cpf = it.somenteDigitos() }
        req.email.limpo()?.let { cliente.email = it }
        req.telefone.limpo()?.let { cliente.telefone = it.somenteDigitos() }
        req.cidade.limpo()?.let { cliente.cidade = it }
        req.endereco.limpo()?.let { cliente.endereco = it }
        req.dtNasc?.let { cliente.dtNasc = it }
        req.dividasAbertas?.let { cliente.dividasAbertas = it }
        return cliente.toResponse()
    }

    private fun obter(id: Long): Cliente = clienteRepository.findById(id)
        .orElseThrow { NaoEncontradoException("Cliente com o ID $id não encontrado") }
}
