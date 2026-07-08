//
//  EspecialidadeRepository.swift
//  Famor
//
//  Created by Aluno ISTEC on 06/07/2026.
//

import Foundation
import SwiftData

// Repository cuida das especialidades guardadas no telemovel.
@MainActor
final class EspecialidadeRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Busca as especialidades locais na ordem que veio da API.
    func buscarTodas() throws -> [EspecialidadeLocalModel] {
        let descriptor = FetchDescriptor<EspecialidadeLocalModel>(
            sortBy: [SortDescriptor(\.ordem, order: .forward)]
        )

        return try modelContext.fetch(descriptor)
    }

    // Guarda ou actualiza a lista que veio da API.
    func salvarEspecialidades(_ especialidades: [EspecialidadeNomeResponse]) throws {
        guard especialidades.isEmpty == false else { return }

        let antigas = try buscarTodas()
        let idsRecebidos = Set(especialidades.map(\.id))

        for antiga in antigas where idsRecebidos.contains(antiga.id) == false {
            modelContext.delete(antiga)
        }

        for (index, especialidade) in especialidades.enumerated() {
            if let local = antigas.first(where: { $0.id == especialidade.id }) {
                local.nome = especialidade.nome
                local.ordem = index
                local.dataLeitura = .now
            } else {
                let nova = EspecialidadeLocalModel(
                    id: especialidade.id,
                    nome: especialidade.nome,
                    ordem: index
                )
                modelContext.insert(nova)
            }
        }

        try modelContext.save()
    }

    func limparTudo() throws {
        let especialidades = try buscarTodas()

        for especialidade in especialidades {
            modelContext.delete(especialidade)
        }

        try modelContext.save()
    }
}
