package Projeto.de.teste.Back.demo.web.dto

import Projeto.de.teste.Back.demo.domain.enums.Cargo
import Projeto.de.teste.Back.demo.domain.enums.Cor
import Projeto.de.teste.Back.demo.domain.enums.Formato
import Projeto.de.teste.Back.demo.domain.enums.Material
import Projeto.de.teste.Back.demo.domain.enums.StatusFinanceiro
import Projeto.de.teste.Back.demo.domain.enums.TipoMovimentacao
import Projeto.de.teste.Back.demo.domain.enums.TipoPessoa
import Projeto.de.teste.Back.demo.domain.enums.TipoTransacao
import Projeto.de.teste.Back.demo.domain.enums.Turno
import Projeto.de.teste.Back.demo.domain.model.Movimentacao
import Projeto.de.teste.Back.demo.domain.model.Pessoa
import Projeto.de.teste.Back.demo.domain.model.Transacao
import java.math.BigDecimal
import java.time.LocalDate
import java.time.LocalDateTime

data class SaldoResponse(val saldo: BigDecimal)

/** [produto] só vem preenchido na consulta "detalhada". */
data class MovimentacaoResponse(
    val id: Long,
    val produtoId: Long,
    val tipo: TipoMovimentacao,
    val quantidade: Int,
    val descricao: String?,
    val quantidadeAnterior: Int,
    val quantidadePosterior: Int,
    val status: StatusFinanceiro,
    val data: LocalDateTime,
    val produto: ProdutoResponse?,
)

data class PessoaResumo(
    val id: Long,
    val tipo: TipoPessoa,
    val nome: String,
    val cpf: String,
    val email: String,
    val telefone: String,
    val cidade: String,
    val endereco: String,
    val dtNasc: LocalDate?,
)

/** [pessoa] só vem preenchido na consulta "detalhada". */
data class TransacaoResponse(
    val id: Long,
    val pessoaId: Long,
    val tipo: TipoTransacao,
    val valor: BigDecimal,
    val saldoAnterior: BigDecimal,
    val saldoPosterior: BigDecimal,
    val status: StatusFinanceiro,
    val data: LocalDateTime,
    val pessoa: PessoaResumo?,
)

/** Listas de valores aceitos pelos campos enumerados — o Flutter monta os dropdowns a partir daqui. */
data class OpcoesResponse(
    val cores: List<Cor>,
    val materiais: List<Material>,
    val formatos: List<Formato>,
    val cargos: List<Cargo>,
    val turnos: List<Turno>,
)

fun Pessoa.toResumo() = PessoaResumo(
    id = id!!, tipo = tipo, nome = nome, cpf = cpf, email = email, telefone = telefone,
    cidade = cidade, endereco = endereco, dtNasc = dtNasc,
)

fun Movimentacao.toResponse(detalhado: Boolean) = MovimentacaoResponse(
    id = id!!, produtoId = produto.id!!, tipo = tipo, quantidade = quantidade, descricao = descricao,
    quantidadeAnterior = quantidadeAnterior, quantidadePosterior = quantidadePosterior,
    status = status, data = data, produto = if (detalhado) produto.toResponse() else null,
)

fun Transacao.toResponse(detalhado: Boolean) = TransacaoResponse(
    id = id!!, pessoaId = pessoa.id!!, tipo = tipo, valor = valor, saldoAnterior = saldoAnterior,
    saldoPosterior = saldoPosterior, status = status, data = data, pessoa = if (detalhado) pessoa.toResumo() else null,
)
