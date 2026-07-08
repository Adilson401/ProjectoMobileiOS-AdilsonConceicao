//
//  EspecialidadeLocalModel.swift
//  Famor
//
//  Created by Aluno ISTEC on 06/07/2026.
//

import Foundation
import SwiftData

// Especialidade guardada no telemovel para abrir a marcacao sem internet.
@Model
final class EspecialidadeLocalModel {
    // O id vem da API, assim nao duplicamos a mesma especialidade.
    @Attribute(.unique) var id: String

    var nome: String
    var ordem: Int
    var dataLeitura: Date

    init(
        id: String,
        nome: String,
        ordem: Int,
        dataLeitura: Date = .now
    ) {
        self.id = id
        self.nome = nome
        self.ordem = ordem
        self.dataLeitura = dataLeitura
    }
}
