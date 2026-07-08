//
//  MarcacaoRascunhoLocalModel.swift
//  Famor
//
//  Created by Aluno ISTEC on 07/07/2026.
//

import Foundation
import SwiftData

// Rascunho local do fluxo de marcacao para recuperar os passos escolhidos.
@Model
final class MarcacaoRascunhoLocalModel {
    @Attribute(.unique) var chave: String

    var usuarioId: String?
    var passoAtual: Int = 1
    var especialidadeId: String?
    var especialidadeNome: String?
    var medicoId: String?
    var medicoNome: String?
    var medicoCodigo: String?
    var agendaMedicaId: String?
    var dataConsulta: Date?
    var hora: String?
    var observacoes: String?
    var confirmadoLocalmente: Bool = false
    var sincronizadoApi: Bool = false
    var marcacaoId: String?
    var codigoConfirmacao: String?
    var estado: String?
    var dataAtualizacao: Date = Date()

    init(
        chave: String,
        usuarioId: String? = nil,
        passoAtual: Int = 1,
        especialidadeId: String? = nil,
        especialidadeNome: String? = nil,
        medicoId: String? = nil,
        medicoNome: String? = nil,
        medicoCodigo: String? = nil,
        agendaMedicaId: String? = nil,
        dataConsulta: Date? = nil,
        hora: String? = nil,
        observacoes: String? = nil,
        confirmadoLocalmente: Bool = false,
        sincronizadoApi: Bool = false,
        marcacaoId: String? = nil,
        codigoConfirmacao: String? = nil,
        estado: String? = nil,
        dataAtualizacao: Date = .now
    ) {
        self.chave = chave
        self.usuarioId = usuarioId
        self.passoAtual = passoAtual
        self.especialidadeId = especialidadeId
        self.especialidadeNome = especialidadeNome
        self.medicoId = medicoId
        self.medicoNome = medicoNome
        self.medicoCodigo = medicoCodigo
        self.agendaMedicaId = agendaMedicaId
        self.dataConsulta = dataConsulta
        self.hora = hora
        self.observacoes = observacoes
        self.confirmadoLocalmente = confirmadoLocalmente
        self.sincronizadoApi = sincronizadoApi
        self.marcacaoId = marcacaoId
        self.codigoConfirmacao = codigoConfirmacao
        self.estado = estado
        self.dataAtualizacao = dataAtualizacao
    }
}
