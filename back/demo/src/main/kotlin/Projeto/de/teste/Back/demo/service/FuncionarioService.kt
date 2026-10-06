package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.model.Funcionario
import Projeto.de.teste.Back.demo.exception.ConflitoException
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.repository.FuncionarioRepository
import Projeto.de.teste.Back.demo.web.dto.FuncionarioRequest
import Projeto.de.teste.Back.demo.web.dto.FuncionarioResponse
import Projeto.de.teste.Back.demo.web.dto.FuncionarioUpdateRequest
import Projeto.de.teste.Back.demo.web.dto.toResponse
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class FuncionarioService(private val funcionarioRepository: FuncionarioRepository) {

    /** Os dois filtros são opcionais e combináveis (antes eram opções de menu separadas). */
    @Transactional(readOnly = true)
    fun listar(status: StatusCadastro?, cargo: Cargo?): List<FuncionarioResponse> {
        val funcionarios = when {
            status != null && cargo != null -> funcionarioRepository.findByStatusAndCargoOrderByIdAsc(status, cargo)
            status != null -> funcionarioRepository.findByStatusOrderByIdAsc(status)
            cargo != null -> funcionarioRepository.findByCargoOrderByIdAsc(cargo)
            else -> funcionarioRepository.findAllByOrderByIdAsc()
        }
        return funcionarios.map { it.toResponse() }
    }

    @Transactional(readOnly = true)
    fun buscar(id: Long): FuncionarioResponse = obter(id).toResponse()

    @Transactional
    fun cadastrar(req: FuncionarioRequest): FuncionarioResponse {
        val funcionario = Funcionario(
            nome = req.nome!!.trim(),
            cpf = req.cpf!!.somenteDigitos(),
            email = req.email!!.trim(),
            telefone = req.telefone!!.somenteDigitos(),
            cidade = req.cidade!!.trim(),
            endereco = req.endereco!!.trim(),
            dtNasc = req.dtNasc!!,
            salario = req.salario!!,
            turno = req.turno!!,
            cargo = req.cargo!!,
        )
        return funcionarioRepository.save(funcionario).toResponse()
    }

    @Transactional
    fun alterar(id: Long, req: FuncionarioUpdateRequest): FuncionarioResponse {
        val funcionario = obter(id)
        req.nome.limpo()?.let { funcionario.nome = it }
        req.cpf.limpo()?.let { funcionario.cpf = it.somenteDigitos() }
        req.email.limpo()?.let { funcionario.email = it }
        req.telefone.limpo()?.let { funcionario.telefone = it.somenteDigitos() }
        req.cidade.limpo()?.let { funcionario.cidade = it }
        req.endereco.limpo()?.let { funcionario.endereco = it }
        req.dtNasc?.let { funcionario.dtNasc = it }
        req.salario?.let { funcionario.salario = it }
        req.turno?.let { funcionario.turno = it }
        req.cargo?.let { funcionario.cargo = it }
        return funcionario.toResponse()
    }

    @Transactional
    fun desativar(id: Long): FuncionarioResponse = alterarStatus(id, StatusCadastro.DESATIVADO)

    @Transactional
    fun reativar(id: Long): FuncionarioResponse = alterarStatus(id, StatusCadastro.ATIVO)

    private fun alterarStatus(id: Long, novo: StatusCadastro): FuncionarioResponse {
        val funcionario = obter(id)
        if (funcionario.status == novo) {
            throw ConflitoException("O funcionário $id já está ${novo.valorBanco}")
        }
        funcionario.status = novo
        return funcionario.toResponse()
    }

    private fun obter(id: Long): Funcionario = funcionarioRepository.findById(id)
        .orElseThrow { NaoEncontradoException("Funcionário com o ID $id não encontrado") }
}
