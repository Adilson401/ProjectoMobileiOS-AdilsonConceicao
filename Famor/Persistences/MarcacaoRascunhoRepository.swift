//
//  MarcacaoRascunhoRepository.swift
//  Famor
//
//  Created by Aluno ISTEC on 07/07/2026.
//

import Foundation
import SwiftData

// Repository do rascunho local da marcacao.
@MainActor
final class MarcacaoRascunhoRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func buscar(usuarioId: String?) throws -> MarcacaoRascunhoLocalModel? {
        let chave = Self.chave(usuarioId: usuarioId)
        return try modelContext.fetch(FetchDescriptor<MarcacaoRascunhoLocalModel>())
            .first { $0.chave == chave }
    }

    func salvar(
        usuarioId: String?,
        passoAtual: Int,
        especialidadeId: String?,
        especialidadeNome: String?,
        medicoId: String?,
        medicoNome: String?,
        medicoCodigo: String?,
        agendaMedicaId: String?,
        dataConsulta: Date?,
        hora: String?,
        observacoes: String?,
        confirmadoLocalmente: Bool,
        sincronizadoApi: Bool = false,
        marcacaoId: String? = nil,
        codigoConfirmacao: String? = nil,
        estado: String? = nil
    ) throws {
        let chave = Self.chave(usuarioId: usuarioId)
        let rascunho: MarcacaoRascunhoLocalModel

        if let existente = try buscar(usuarioId: usuarioId) {
            rascunho = existente
        } else {
            rascunho = MarcacaoRascunhoLocalModel(chave: chave)
            modelContext.insert(rascunho)
        }

        rascunho.usuarioId = usuarioId
        rascunho.passoAtual = passoAtual
        rascunho.especialidadeId = textoValido(especialidadeId)
        rascunho.especialidadeNome = textoValido(especialidadeNome)
        rascunho.medicoId = textoValido(medicoId)
        rascunho.medicoNome = textoValido(medicoNome)
        rascunho.medicoCodigo = textoValido(medicoCodigo)
        rascunho.agendaMedicaId = textoValido(agendaMedicaId)
        rascunho.dataConsulta = dataConsulta
        rascunho.hora = textoValido(hora)
        rascunho.observacoes = textoValido(observacoes)
        rascunho.confirmadoLocalmente = confirmadoLocalmente
        rascunho.sincronizadoApi = sincronizadoApi
        rascunho.marcacaoId = textoValido(marcacaoId)
        rascunho.codigoConfirmacao = textoValido(codigoConfirmacao)
        rascunho.estado = textoValido(estado)
        rascunho.dataAtualizacao = .now

        try modelContext.save()
    }

    func limpar(usuarioId: String?) throws {
        if let rascunho = try buscar(usuarioId: usuarioId) {
            modelContext.delete(rascunho)
            try modelContext.save()
        }
    }

    func limparTodos() throws {
        let rascunhos = try modelContext.fetch(FetchDescriptor<MarcacaoRascunhoLocalModel>())

        for rascunho in rascunhos {
            modelContext.delete(rascunho)
        }

        try modelContext.save()
    }

    private static func chave(usuarioId: String?) -> String {
        "marcacao-rascunho-\(usuarioId ?? "sem-usuario")"
    }

    private func textoValido(_ texto: String?) -> String? {
        guard let texto else { return nil }
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }
}
