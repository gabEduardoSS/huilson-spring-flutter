package Projeto.de.teste.Back.demo.domain.model

import Projeto.de.teste.Back.demo.domain.enums.StatusCadastro
import jakarta.persistence.AttributeConverter
import jakarta.persistence.Converter

/** Grava "ativo"/"desativado" (como no projeto antigo) mas expõe um enum tipado no código. */
@Converter
class StatusCadastroConverter : AttributeConverter<StatusCadastro, String> {
    override fun convertToDatabaseColumn(attribute: StatusCadastro?): String? = attribute?.valorBanco

    override fun convertToEntityAttribute(dbData: String?): StatusCadastro? = dbData?.let { StatusCadastro.deBanco(it) }
}
