//
//  MarcacaoFeitaLocalModel.swift
//  Famor
//
//  Created by Aluno ISTEC on 07/07/2026.
//

import Foundation
import SwiftData

// Consulta guardada localmente para abrir Minhas Consultas sem comunicacao com a API.
@Model
final class MarcacaoFeitaLocalModel {
    // Chave única para não duplicar consulta no telemóvel.
    @Attribute(.unique) var chave: String

    // Dados principais da consulta guardada.
    var usuarioId: String?
    var marcacaoId: String
    var medicoNome: String
    var medicoId: String?
    var especialidade: String?
    var especialidadeId: String?
    var dataConsulta: Date?
    var horaInicio: String?
    var horaFim: String?
    var codigoConfirmacao: String?
    var observacao: String?
    var estado: String?
    var estadoCor: String?
    var ordem: Int
    var dataLeitura: Date

    // Cria uma consulta local a partir dos dados da API.
    init(
        chave: String,
        usuarioId: String? = nil,
        marcacaoId: String,
        medicoNome: String,
        medicoId: String? = nil,
        especialidade: String? = nil,
        especialidadeId: String? = nil,
        dataConsulta: Date? = nil,
        horaInicio: String? = nil,
        horaFim: String? = nil,
        codigoConfirmacao: String? = nil,
        observacao: String? = nil,
        estado: String? = nil,
        estadoCor: String? = nil,
        ordem: Int = 0,
        dataLeitura: Date = .now
    ) {
        self.chave = chave
        self.usuarioId = usuarioId
        self.marcacaoId = marcacaoId
        self.medicoNome = medicoNome
        self.medicoId = medicoId
        self.especialidade = especialidade
        self.especialidadeId = especialidadeId
        self.dataConsulta = dataConsulta
        self.horaInicio = horaInicio
        self.horaFim = horaFim
        self.codigoConfirmacao = codigoConfirmacao
        self.observacao = observacao
        self.estado = estado
        self.estadoCor = estadoCor
        self.ordem = ordem
        self.dataLeitura = dataLeitura
    }
}
