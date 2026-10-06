package Projeto.de.teste.Back.demo.service

import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import Projeto.de.teste.Back.demo.domain.model.CaixaDeAgua
import Projeto.de.teste.Back.demo.exception.ConflitoException
import Projeto.de.teste.Back.demo.exception.NaoEncontradoException
import Projeto.de.teste.Back.demo.repository.CaixaDeAguaRepository
import Projeto.de.teste.Back.demo.repository.MovimentacaoRepository
import Projeto.de.teste.Back.demo.web.dto.ProdutoRequest
import Projeto.de.teste.Back.demo.web.dto.ProdutoResponse
import Projeto.de.teste.Back.demo.web.dto.ProdutoUpdateRequest
import Projeto.de.teste.Back.demo.web.dto.toResponse
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class ProdutoService(
    private val produtoRepository: CaixaDeAguaRepository,
    private val movimentacaoRepository: MovimentacaoRepository,
) {
    @Transactional(readOnly = true)
    fun listar(status: StatusCadastro?): List<ProdutoResponse> {
        val produtos = if (status == null) produtoRepository.findAllByOrderByIdAsc()
        else produtoRepository.findByStatusOrderByIdAsc(status)
        return produtos.map { it.toResponse() }
    }

    @Transactional(readOnly = true)
    fun buscar(id: Long): ProdutoResponse = obter(id).toResponse()

    /** Todo produto nasce ativo e com estoque zero; o estoque só muda por compras (entrada) e vendas (saída). */
    @Transactional
    fun cadastrar(req: ProdutoRequest): ProdutoResponse {
        val produto = CaixaDeAgua(
            marca = req.marca!!.trim(),
            modelo = req.modelo!!.trim(),
            dimensao = mutableListOf(req.altura!!, req.largura!!, req.profundidade!!),
            cor = req.cor!!,
            material = req.material!!,
            formato = req.formato!!,
            fornecedor = req.fornecedor!!.trim(),
            preco = req.preco!!,
        )
        return produtoRepository.save(produto).toResponse()
    }

    @Transactional
    fun alterar(id: Long, req: ProdutoUpdateRequest): ProdutoResponse {
        val produto = obter(id)
        req.marca.limpo()?.let { produto.marca = it }
        req.modelo.limpo()?.let { produto.modelo = it }
        if (req.altura != null || req.largura != null || req.profundidade != null) {
            // Cria uma nova lista para o Hibernate perceber a mudança no array.
            produto.dimensao = mutableListOf(
                req.altura ?: produto.altura,
                req.largura ?: produto.largura,
                req.profundidade ?: produto.profundidade,
            )
        }
        req.cor?.let { produto.cor = it }
        req.material?.let { produto.material = it }
        req.formato?.let { produto.formato = it }
        req.fornecedor.limpo()?.let { produto.fornecedor = it }
        req.preco?.let { produto.preco = it }
        return produto.toResponse()
    }

    @Transactional
    fun desativar(id: Long): ProdutoResponse = alterarStatus(id, StatusCadastro.DESATIVADO)

    @Transactional
    fun reativar(id: Long): ProdutoResponse = alterarStatus(id, StatusCadastro.ATIVO)

    /**
     * Exclusão definitiva (funcionalidade "Excluir caixa" do projeto aa).
     * Produto que já teve compra/venda não pode sumir sem quebrar o histórico: nesse caso use [desativar].
     */
    @Transactional
    fun excluir(id: Long) {
        val produto = obter(id)
        if (movimentacaoRepository.existsByProdutoId(id)) {
            throw ConflitoException(
                "O produto $id possui movimentações de estoque e não pode ser excluído; desative-o em vez disso.",
            )
        }
        produtoRepository.delete(produto)
    }

    private fun alterarStatus(id: Long, novo: StatusCadastro): ProdutoResponse {
        val produto = obter(id)
        if (produto.status == novo) {
            throw ConflitoException("O produto $id já está ${novo.valorBanco}")
        }
        produto.status = novo
        return produto.toResponse()
    }

    private fun obter(id: Long): CaixaDeAgua = produtoRepository.findById(id)
        .orElseThrow { NaoEncontradoException("Produto com ID $id não encontrado") }
}
