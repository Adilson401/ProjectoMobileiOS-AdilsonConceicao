//
//  MarcacaoFeitaRepository.swift
//  Famor
//
//  Created by Aluno ISTEC on 07/07/2026.
//

import Foundation
import SwiftData

// Repository da lista local de Minhas Consultas.
@MainActor
final class MarcacaoFeitaRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Busca as consultas guardadas para este usuário.
    func buscar(usuarioId: String?) throws -> [MarcacaoFeitaLocalModel] {
        let descriptor = FetchDescriptor<MarcacaoFeitaLocalModel>(
            sortBy: [SortDescriptor(\.ordem, order: .forward)]
        )

        return try modelContext.fetch(descriptor).filter { consulta in
            consulta.usuarioId == usuarioId
        }
    }

    // Actualiza a cache local com a resposta da API.
    func salvar(_ consultas: [MarcacaoFeitaResponse], usuarioId: String?) throws {
        let antigas = try buscar(usuarioId: usuarioId)
        let chavesRecebidas = Set(consultas.map { Self.chave(usuarioId: usuarioId, marcacaoId: $0.id) })

        for antiga in antigas where chavesRecebidas.contains(antiga.chave) == false {
            modelContext.delete(antiga)
        }

        for (index, consulta) in consultas.enumerated() {
            let chave = Self.chave(usuarioId: usuarioId, marcacaoId: consulta.id)
            let local: MarcacaoFeitaLocalModel

            if let existente = antigas.first(where: { $0.chave == chave }) {
                local = existente
            } else {
                local = MarcacaoFeitaLocalModel(
                    chave: chave,
                    usuarioId: usuarioId,
                    marcacaoId: consulta.id,
                    medicoNome: consulta.medicoNome
                )
                modelContext.insert(local)
            }

            local.usuarioId = usuarioId
            local.marcacaoId = consulta.id
            local.medicoNome = consulta.medicoNome
            local.medicoId = textoValido(consulta.medicoId)
            local.especialidade = textoValido(consulta.especialidade)
            local.especialidadeId = textoValido(consulta.especialidadeId)
            local.dataConsulta = consulta.dataConsulta
            local.horaInicio = textoValido(consulta.horaInicio)
            local.horaFim = textoValido(consulta.horaFim)
            local.codigoConfirmacao = textoValido(consulta.codigoConfirmacao)
            local.observacao = textoValido(consulta.observacao)
            local.estado = textoValido(consulta.estado)
            local.estadoCor = textoValido(consulta.estadoCor)
            local.ordem = index
            local.dataLeitura = .now
        }

        try modelContext.save()
    }

    // Apaga a lista local deste usuário.
    func limpar(usuarioId: String?) throws {
        let consultas = try buscar(usuarioId: usuarioId)

        for consulta in consultas {
            modelContext.delete(consulta)
        }

        try modelContext.save()
    }

    // Chave única por usuário e marcação.
    private static func chave(usuarioId: String?, marcacaoId: String) -> String {
        "marcacao-feita-\(usuarioId ?? "sem-usuario")-\(marcacaoId)"
    }

    // Evita guardar texto vazio.
    private func textoValido(_ texto: String?) -> String? {
        guard let texto else { return nil }
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }
}
