//
//  PerfilLocalModel.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import Foundation
import SwiftData

// Perfil guardado localmente depois da primeira leitura da API.
@Model
final class PerfilLocalModel {
    // Chave fixa para nao duplicar o perfil no telemovel.
    @Attribute(.unique) var chave: String

    var usuarioId: String?
    var perfilId: String?
    var nome: String
    var email: String
    var morada: String?
    var funcao: String?
    var perfil: String?
    var status: String?
    var dataRegisto: Date?
    var totalConsultas: Int
    var concluidas: Int
    var canceladas: Int
    var dataLeitura: Date

    init(
        chave: String = "perfil-primeira-leitura",
        usuarioId: String? = nil,
        perfilId: String? = nil,
        nome: String,
        email: String,
        morada: String? = nil,
        funcao: String? = nil,
        perfil: String? = nil,
        status: String? = nil,
        dataRegisto: Date? = nil,
        totalConsultas: Int = 0,
        concluidas: Int = 0,
        canceladas: Int = 0,
        dataLeitura: Date = .now
    ) {
        self.chave = chave
        self.usuarioId = usuarioId
        self.perfilId = perfilId
        self.nome = nome
        self.email = email
        self.morada = morada
        self.funcao = funcao
        self.perfil = perfil
        self.status = status
        self.dataRegisto = dataRegisto
        self.totalConsultas = totalConsultas
        self.concluidas = concluidas
        self.canceladas = canceladas
        self.dataLeitura = dataLeitura
    }

    // Converte o local para o formato usado pela tela.
    func toPerfilResponse() -> PerfilUsuarioResponse {
        PerfilUsuarioResponse(
            id: perfilId,
            nome: nome,
            email: email,
            morada: morada,
            funcao: funcao,
            perfil: perfil,
            status: status,
            dataRegisto: dataRegisto
        )
    }

    // Converte os totais locais para o formato usado pela tela.
    func toTotaisResponse() -> TotaisConsultasResponse {
        TotaisConsultasResponse(
            totalConsultas: totalConsultas,
            concluidas: concluidas,
            canceladas: canceladas
        )
    }
}
